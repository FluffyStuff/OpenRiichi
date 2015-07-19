using Gee;

public class GameState
{
    private ClientGameState state;
    private State game_state;
    private ServerMessageParser parser = new ServerMessageParser();

    private ArrayList<TileSelectionGroup> selection_groups = new ArrayList<TileSelectionGroup>();

    public signal void send_message(ClientMessage message);

    public signal void set_chi_state(bool enabled);
    public signal void set_pon_state(bool enabled);
    public signal void set_kan_state(bool enabled);
    public signal void set_riichi_state(bool enabled);
    public signal void set_tsumo_state(bool enabled);
    public signal void set_ron_state(bool enabled);
    public signal void set_continue_state(bool enabled);

    public signal void set_tile_select_state(bool enabled);
    public signal void set_tile_select_groups(ArrayList<TileSelectionGroup>? selection_groups);

    public GameState(GameStartState state)
    {
        this.state = new ClientGameState(state.player_ID);
        game_state = State.DONE;

        parser.connect(server_turn_decision, typeof(ServerMessageTurnDecision));
        parser.connect(server_call_decision, typeof(ServerMessageCallDecision));

        parser.connect(server_tile_assignment, typeof(ServerMessageTileAssignment));
        parser.connect(server_tile_draw, typeof(ServerMessageTileDraw));
        parser.connect(server_tile_discard, typeof(ServerMessageTileDiscard));
        parser.connect(server_flip_dora, typeof(ServerMessageFlipDora));

        parser.connect(server_ron, typeof(ServerMessageRon));
        parser.connect(server_late_kan, typeof(ServerMessageLateKan));
        parser.connect(server_closed_kan, typeof(ServerMessageClosedKan));
        parser.connect(server_open_kan, typeof(ServerMessageOpenKan));
        parser.connect(server_pon, typeof(ServerMessagePon));
        parser.connect(server_chi, typeof(ServerMessageChi));
    }

    public void receive_message(ServerMessage message)
    {
        parser.execute(message);
    }

    private void decision_finished()
    {
        game_state = State.DONE;

        set_chi_state(false);
        set_pon_state(false);
        set_kan_state(false);
        set_riichi_state(false);
        set_tsumo_state(false);
        set_ron_state(false);
        set_continue_state(false);
        set_tile_select_state(false);
    }

    private void do_late_kan(Tile tile)
    {
        ClientMessageLateKan message = new ClientMessageLateKan(tile.ID);
        send_message(message);
    }

    private void do_closed_kan(TileType type)
    {
        ClientMessageClosedKan message = new ClientMessageClosedKan(type);
        send_message(message);
    }

    private void do_chi(Tile tile_1, Tile tile_2)
    {
        ClientMessageChi message = new ClientMessageChi(tile_1.ID, tile_2.ID);
        send_message(message);
    }

    private void do_turn_decision()
    {
        game_state = State.TURN;

        bool can_kan = TileRules.can_closed_kan(state.self.hand) || TileRules.can_late_kan(state.self.hand, state.self.calls);
        bool can_riichi = false;
        bool can_tsumo = false;

        set_chi_state(false);
        set_pon_state(false);
        set_kan_state(can_kan);
        set_riichi_state(can_riichi);
        set_tsumo_state(can_tsumo);
        set_ron_state(false);
        set_continue_state(false);
        set_tile_select_state(true);
        set_tile_select_groups(null);
    }

    private void do_call_decision(Tile tile, ClientGameStatePlayer discard_player)
    {
        game_state = State.CALL;

        bool can_chi = state.can_chi(tile, state.self, discard_player);
        bool can_pon = TileRules.can_pon(state.self.hand, tile);
        bool can_kan = TileRules.can_open_kan(state.self.hand, tile);
        bool can_ron = false;

        set_chi_state(can_chi);
        set_pon_state(can_pon);
        set_kan_state(can_kan);
        set_riichi_state(false);
        set_tsumo_state(false);
        set_ron_state(can_ron);
        set_continue_state(true);
        set_tile_select_state(false);
    }

    private void do_discard_tile(Tile tile)
    {
        if (!state.self.has_tile(tile))
            return;

        decision_finished();

        ClientMessageTileDiscard message = new ClientMessageTileDiscard(tile.ID);
        send_message(message);
    }

    private void do_select_chi(Tile tile)
    {
        foreach (TileSelectionGroup group in selection_groups)
        {
            if (group.group_type != TileSelectionGroup.GroupType.CHI)
                continue;

            foreach (Tile t in group.selection_tiles)
            {
                if (t.ID == tile.ID)
                {
                    decision_finished();
                    do_chi(group.highlight_tiles[1], group.highlight_tiles[2]);
                    return;
                }
            }
        }
    }

    private void do_select_kan(Tile tile)
    {
        foreach (TileSelectionGroup group in selection_groups)
        {
            foreach (Tile t in group.selection_tiles)
            {
                if (t.ID == tile.ID)
                {
                    decision_finished();

                    if (group.group_type == TileSelectionGroup.GroupType.LATE_KAN)
                        do_late_kan(tile);
                    else if (group.group_type == TileSelectionGroup.GroupType.CLOSED_KAN)
                        do_closed_kan(tile.tile_type);

                    return;
                }
            }
        }
    }

    /////////////////////////

    public void client_chi()
    {
        if (game_state == State.CALL)
        {
            ArrayList<ArrayList<Tile>> groups = TileRules.get_chi_groups(state.self.hand, state.discard_tile);

            if (groups.size == 1)
            {
                decision_finished();

                Tile tile_1 = groups[0][0];
                Tile tile_2 = groups[0][1];
                do_chi(tile_1, tile_2);
            }
            else if (groups.size > 1)
            {
                game_state = State.SELECT_CHI;

                selection_groups.clear();

                foreach (ArrayList<Tile> group in groups)
                {
                    ArrayList<Tile> selection = new ArrayList<Tile>();
                    selection.add_all(group);
                    ArrayList<Tile> highlight = new ArrayList<Tile>();
                    highlight.add(state.discard_tile);
                    highlight.add_all(group);

                    foreach (TileSelectionGroup g in selection_groups)
                        foreach (Tile t in g.selection_tiles)
                            selection.remove(t);

                    selection_groups.add(new TileSelectionGroup(selection, highlight, TileSelectionGroup.GroupType.CHI));
                }

                set_pon_state(false);
                set_kan_state(false);
                set_ron_state(false);
                set_continue_state(false);
                set_tile_select_state(true);
                set_tile_select_groups(selection_groups);
            }
        }
        else if (game_state == State.SELECT_CHI)
        {
            do_call_decision(state.discard_tile, state.discard_player);
        }
    }

    public void client_pon()
    {
        if (game_state != State.CALL)
            return;

        decision_finished();

        ClientMessagePon message = new ClientMessagePon();
        send_message(message);
    }

    public void client_kan()
    {
        if (game_state == State.CALL)
        {
            decision_finished();

            ClientMessageOpenKan message = new ClientMessageOpenKan();
            send_message(message);
        }
        else if (game_state == State.TURN)
        {
            ArrayList<ArrayList<Tile>> closed_kans = TileRules.get_closed_kan_groups(state.self.hand);
            ArrayList<Tile> late_kans = TileRules.get_late_kan_tiles(state.self.hand, state.self.calls);

            if (closed_kans.size == 1 && late_kans.size == 0)
            {
                decision_finished();
                do_closed_kan(closed_kans[0][0].tile_type);
            }
            else if (closed_kans.size == 0 && late_kans.size == 1)
            {
                decision_finished();
                do_late_kan(late_kans[0]);
            }
            else
            {
                game_state = State.SELECT_KAN;
                selection_groups.clear();

                foreach (Tile tile in late_kans)
                {
                    ArrayList<Tile> selection = new ArrayList<Tile>();
                    selection.add(tile);

                    ArrayList<Tile> highlight = new ArrayList<Tile>();
                    highlight.add(tile);
                    highlight.add_all(state.self.get_late_kan_tiles(tile));

                    selection_groups.add(new TileSelectionGroup(selection, highlight, TileSelectionGroup.GroupType.LATE_KAN));
                }

                foreach (ArrayList<Tile> tiles in closed_kans)
                {
                    ArrayList<Tile> selection = new ArrayList<Tile>();
                    selection.add_all(tiles);
                    ArrayList<Tile> highlight = new ArrayList<Tile>();
                    highlight.add_all(tiles);

                    selection_groups.add(new TileSelectionGroup(selection, highlight, TileSelectionGroup.GroupType.CLOSED_KAN));
                }

                set_riichi_state(false);
                set_tsumo_state(false);
                set_tile_select_groups(selection_groups);
            }
        }
        else if (game_state == State.SELECT_KAN)
        {
            do_turn_decision();
            set_tile_select_groups(null);
        }
    }

    public void client_riichi()
    {
        if (game_state != State.TURN)
            return;

        set_kan_state(false);
        set_riichi_state(false);
        set_tsumo_state(false);
    }

    public void client_tsumo()
    {
        if (game_state != State.TURN)
            return;

        decision_finished();
    }

    public void client_ron()
    {
        if (game_state != State.CALL)
            return;

        decision_finished();
    }

    public void client_continue()
    {
        if (game_state != State.CALL)
            return;

        decision_finished();

        ClientMessageNoCall message = new ClientMessageNoCall();
        send_message(message);
    }

    public void client_tile_selected(Tile tile)
    {
        if (game_state == State.TURN)
            do_discard_tile(tile);
        else if (game_state == State.SELECT_CHI)
            do_select_chi(tile);
        else if (game_state == State.SELECT_KAN)
            do_select_kan(tile);
    }

    ////////////////////////

    private void server_tile_assignment(ServerMessage message)
    {
        ServerMessageTileAssignment tile = (ServerMessageTileAssignment)message;
        state.tile_assign(tile.get_tile());
    }

    private void server_tile_draw(ServerMessage message)
    {
        ServerMessageTileDraw draw = (ServerMessageTileDraw)message;
        state.tile_draw(draw.player_ID, draw.tile_ID);
    }

    private void server_tile_discard(ServerMessage message)
    {
        ServerMessageTileDiscard discard = (ServerMessageTileDiscard)message;
        state.tile_discard(discard.player_ID, discard.tile_ID);
    }

    private void server_flip_dora(ServerMessage message)
    {

    }

    private void server_ron(ServerMessage message)
    {
        ServerMessageRon ron = (ServerMessageRon)message;

        decision_finished();
    }

    private void server_late_kan(ServerMessage message)
    {
        ServerMessageLateKan kan = (ServerMessageLateKan)message;
        state.late_kan(kan.player_ID, kan.tile_ID);
    }

    private void server_closed_kan(ServerMessage message)
    {
        ServerMessageClosedKan kan = (ServerMessageClosedKan)message;
        state.closed_kan(kan.player_ID, kan.get_type_enum());
    }

    private void server_open_kan(ServerMessage message)
    {
        ServerMessageOpenKan kan = (ServerMessageOpenKan)message;
        state.open_kan(kan.player_ID, kan.discard_player_ID, kan.tile_ID, kan.tile_1_ID, kan.tile_2_ID, kan.tile_3_ID);

        decision_finished();
    }

    private void server_pon(ServerMessage message)
    {
        ServerMessagePon pon = (ServerMessagePon)message;
        state.pon(pon.player_ID, pon.player_ID, pon.tile_ID, pon.tile_1_ID, pon.tile_2_ID);

        decision_finished();
    }

    private void server_chi(ServerMessage message)
    {
        ServerMessageChi chi = (ServerMessageChi)message;
        state.chi(chi.player_ID, chi.player_ID, chi.tile_ID, chi.tile_1_ID, chi.tile_2_ID);
    }

    ////////////////////////

    public void server_turn_decision(ServerMessage message)
    {
        do_turn_decision();
    }

    public void server_call_decision(ServerMessage message)
    {
        ServerMessageCallDecision call = (ServerMessageCallDecision)message;
        ClientGameStatePlayer player = state.get_player(call.player_ID);
        Tile tile = state.get_tile(call.tile_ID);

        do_call_decision(tile, player);
    }

    ////////////////////////

    private enum State
    {
        SELECT_CHI,
        SELECT_KAN,
        CALL,
        TURN,
        DONE
    }
}

public class TileSelectionGroup
{
    public TileSelectionGroup(ArrayList<Tile> selection_tiles, ArrayList<Tile> highlight_tiles, GroupType group_type)
    {
        this.selection_tiles = selection_tiles;
        this.highlight_tiles = highlight_tiles;
        this.group_type = group_type;
    }

    public ArrayList<Tile> selection_tiles { get; private set; }
    public ArrayList<Tile> highlight_tiles { get; private set; }
    public GroupType group_type { get; private set; }

    public enum GroupType
    {
        CHI,
        CLOSED_KAN,
        LATE_KAN
    }
}
