using Gee;

public class RoundState
{
    private ClientRoundState state;
    private State action_state;
    private ServerMessageParser parser = new ServerMessageParser();

    private ArrayList<TileSelectionGroup> selection_groups = new ArrayList<TileSelectionGroup>();

    public signal void send_message(ClientMessage message);

    public signal void set_chii_state(bool enabled);
    public signal void set_pon_state(bool enabled);
    public signal void set_kan_state(bool enabled);
    public signal void set_riichi_state(bool enabled);
    public signal void set_tsumo_state(bool enabled);
    public signal void set_ron_state(bool enabled);
    public signal void set_continue_state(bool enabled);

    public signal void set_tile_select_state(bool enabled);
    public signal void set_tile_select_groups(ArrayList<TileSelectionGroup>? selection_groups);

    public bool finished { get; private set; }
    public RoundFinishResult result { get; private set; }

    public signal void declare_riichi(int player_index);

    public RoundState(RoundStartInfo info, int player_index, Wind round_wind, int dealer_index, bool[] can_riichi)
    {
        state = new ClientRoundState(player_index, round_wind, dealer_index, can_riichi);
        action_state = State.DONE;

        parser.connect(server_turn_decision, typeof(ServerMessageTurnDecision));
        parser.connect(server_call_decision, typeof(ServerMessageCallDecision));

        parser.connect(server_tile_assignment, typeof(ServerMessageTileAssignment));
        parser.connect(server_tile_draw, typeof(ServerMessageTileDraw));
        parser.connect(server_tile_discard, typeof(ServerMessageTileDiscard));
        parser.connect(server_flip_dora, typeof(ServerMessageFlipDora));
        parser.connect(server_flip_ura_dora, typeof(ServerMessageFlipUraDora));

        parser.connect(server_draw, typeof(ServerMessageDraw));
        parser.connect(server_ron, typeof(ServerMessageRon));
        parser.connect(server_tsumo, typeof(ServerMessageTsumo));
        parser.connect(server_riichi, typeof(ServerMessageRiichi));
        parser.connect(server_late_kan, typeof(ServerMessageLateKan));
        parser.connect(server_closed_kan, typeof(ServerMessageClosedKan));
        parser.connect(server_open_kan, typeof(ServerMessageOpenKan));
        parser.connect(server_pon, typeof(ServerMessagePon));
        parser.connect(server_chii, typeof(ServerMessageChii));
    }

    public void receive_message(ServerMessage message)
    {
        parser.execute(message);
    }

    private void decision_finished()
    {
        action_state = State.DONE;

        set_chii_state(false);
        set_pon_state(false);
        set_kan_state(false);
        set_riichi_state(false);
        set_tsumo_state(false);
        set_ron_state(false);
        set_continue_state(false);
        set_tile_select_state(false);
    }

    private void do_riichi(Tile tile)
    {
        ClientMessageRiichi message = new ClientMessageRiichi();
        send_message(message);

        do_discard_tile(tile);
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

    private void do_chii(Tile tile_1, Tile tile_2)
    {
        ClientMessageChii message = new ClientMessageChii(tile_1.ID, tile_2.ID);
        send_message(message);
    }

    private void do_turn_decision()
    {
        action_state = State.TURN;

        bool can_kan = state.self.can_closed_kan() || state.self.can_late_kan();
        bool can_riichi = state.self.can_riichi();
        bool can_tsumo = state.can_tsumo(state.self);

        set_chii_state(false);
        set_pon_state(false);
        set_kan_state(can_kan);
        set_riichi_state(can_riichi);
        set_tsumo_state(can_tsumo);
        set_ron_state(false);
        set_continue_state(false);

        if (state.self.in_riichi)
        {
            ArrayList<Tile> list = new ArrayList<Tile>();
            list.add(state.self.last_drawn_tile);

            selection_groups.clear();
            selection_groups.add(new TileSelectionGroup(list, list, TileSelectionGroup.GroupType.RIICHI_WAIT));
            set_tile_select_groups(selection_groups);
        }
        else
            set_tile_select_groups(null);

        set_tile_select_state(true);
    }

    private void do_call_decision(Tile tile, ClientRoundStatePlayer discard_player)
    {
        action_state = State.CALL;

        bool can_chii = state.can_chii(tile, state.self, discard_player);
        bool can_pon = TileRules.can_pon(state.self.hand, tile);
        bool can_kan = TileRules.can_open_kan(state.self.hand, tile);
        bool can_ron = state.can_ron(state.self, tile);

        set_chii_state(can_chii);
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
        ClientMessageTileDiscard message = new ClientMessageTileDiscard(tile.ID);
        send_message(message);
    }

    private void do_select_chii(Tile tile)
    {
        foreach (TileSelectionGroup group in selection_groups)
        {
            if (group.group_type != TileSelectionGroup.GroupType.CHII)
                continue;

            foreach (Tile t in group.selection_tiles)
            {
                if (t.ID == tile.ID)
                {
                    decision_finished();
                    do_chii(group.highlight_tiles[1], group.highlight_tiles[2]);
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

    private void do_select_riichi(Tile tile)
    {
        foreach (TileSelectionGroup group in selection_groups)
        {
            if (group.group_type != TileSelectionGroup.GroupType.RIICHI)
                continue;

            foreach (Tile t in group.selection_tiles)
            {
                if (t.ID == tile.ID)
                {
                    decision_finished();
                    do_riichi(tile);
                    return;
                }
            }
        }
    }

    private void do_select_discard_tile(Tile tile)
    {
        decision_finished();
        do_discard_tile(tile);
    }

    /////////////////////////

    public void client_chii()
    {
        if (action_state == State.CALL)
        {
            ArrayList<ArrayList<Tile>> groups = TileRules.get_chii_groups(state.self.hand, state.discard_tile);

            if (groups.size == 1)
            {
                decision_finished();

                Tile tile_1 = groups[0][0];
                Tile tile_2 = groups[0][1];
                do_chii(tile_1, tile_2);
            }
            else if (groups.size > 1)
            {
                action_state = State.SELECT_CHII;

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

                    selection_groups.add(new TileSelectionGroup(selection, highlight, TileSelectionGroup.GroupType.CHII));
                }

                set_pon_state(false);
                set_kan_state(false);
                set_ron_state(false);
                set_continue_state(false);
                set_tile_select_state(true);
                set_tile_select_groups(selection_groups);
            }
        }
        else if (action_state == State.SELECT_CHII)
        {
            do_call_decision(state.discard_tile, state.discard_player);
        }
    }

    public void client_pon()
    {
        if (action_state != State.CALL)
            return;

        decision_finished();

        ClientMessagePon message = new ClientMessagePon();
        send_message(message);
    }

    public void client_kan()
    {
        if (action_state == State.CALL)
        {
            decision_finished();

            ClientMessageOpenKan message = new ClientMessageOpenKan();
            send_message(message);
        }
        else if (action_state == State.TURN)
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
                action_state = State.SELECT_KAN;
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
        else if (action_state == State.SELECT_KAN)
        {
            do_turn_decision();
        }
    }

    public void client_riichi()
    {
        if (action_state == State.TURN)
        {
            ArrayList<Tile> tiles = state.get_tenpai_tiles(state.self);
            if (tiles.size == 1)
            {
                decision_finished();
                do_riichi(tiles[0]);
            }
            else if (tiles.size > 1)
            {
                action_state = State.SELECT_RIICHI;
                selection_groups.clear();

                foreach (Tile tile in tiles)
                {
                    ArrayList<Tile> list = new ArrayList<Tile>();
                    list.add(tile);
                    selection_groups.add(new TileSelectionGroup(list, list, TileSelectionGroup.GroupType.RIICHI));
                }

                set_kan_state(false);
                set_tsumo_state(false);
                set_tile_select_groups(selection_groups);
            }
        }
        else if (action_state == State.SELECT_RIICHI)
        {
            do_turn_decision();
        }
    }

    public void client_tsumo()
    {
        if (action_state != State.TURN)
            return;

        decision_finished();

        ClientMessageTsumo message = new ClientMessageTsumo();
        send_message(message);
    }

    public void client_ron()
    {
        if (action_state != State.CALL)
            return;

        decision_finished();

        ClientMessageRon message = new ClientMessageRon();
        send_message(message);
    }

    public void client_continue()
    {
        if (action_state != State.CALL)
            return;

        decision_finished();

        ClientMessageNoCall message = new ClientMessageNoCall();
        send_message(message);
    }

    public void client_tile_selected(Tile tile)
    {
        if (action_state == State.TURN)
            do_select_discard_tile(tile);
        else if (action_state == State.SELECT_CHII)
            do_select_chii(tile);
        else if (action_state == State.SELECT_KAN)
            do_select_kan(tile);
        else if (action_state == State.SELECT_RIICHI)
            do_select_riichi(tile);
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
        state.tile_draw(draw.player_index, draw.tile_ID);
    }

    private void server_tile_discard(ServerMessage message)
    {
        ServerMessageTileDiscard discard = (ServerMessageTileDiscard)message;
        state.tile_discard(discard.player_index, discard.tile_ID);
    }

    private void server_flip_dora(ServerMessage message)
    {
        ServerMessageFlipDora dora = (ServerMessageFlipDora)message;
        state.flip_dora(dora.tile_ID);
    }

    private void server_flip_ura_dora(ServerMessage message)
    {
        ServerMessageFlipUraDora dora = (ServerMessageFlipUraDora)message;
        state.flip_ura_dora(dora.tile_ID);
    }

    private void server_draw(ServerMessage message)
    {
        ServerMessageDraw draw = (ServerMessageDraw)message;

        finished = true;
        result = new RoundFinishResult.draw(draw.get_tenpai_indices());
    }

    private void server_ron(ServerMessage message)
    {
        decision_finished();

        ServerMessageRon ron = (ServerMessageRon)message;
        ClientRoundStatePlayer player = state.get_player(ron.player_index);
        Tile tile = state.get_tile(ron.tile_ID);

        finished = true;
        Scoring score = state.get_ron_score(player, tile);
        result = new RoundFinishResult.ron(score, ron.player_index, ron.discard_player_index);
    }

    private void server_tsumo(ServerMessage message)
    {
        ServerMessageTsumo tsumo = (ServerMessageTsumo)message;
        ClientRoundStatePlayer player = state.get_player(tsumo.player_index);

        finished = true;
        Scoring score = state.get_tsumo_score(player);
        result = new RoundFinishResult.tsumo(score, tsumo.player_index);
    }

    private void server_riichi(ServerMessage message)
    {
        ServerMessageRiichi riichi = (ServerMessageRiichi)message;
        state.riichi(riichi.player_index);

        declare_riichi(riichi.player_index);
    }

    private void server_late_kan(ServerMessage message)
    {
        ServerMessageLateKan kan = (ServerMessageLateKan)message;
        state.late_kan(kan.player_index, kan.tile_ID);
    }

    private void server_closed_kan(ServerMessage message)
    {
        ServerMessageClosedKan kan = (ServerMessageClosedKan)message;
        state.closed_kan(kan.player_index, kan.get_type_enum());
    }

    private void server_open_kan(ServerMessage message)
    {
        ServerMessageOpenKan kan = (ServerMessageOpenKan)message;
        state.open_kan(kan.player_index, kan.discard_player_index, kan.tile_ID, kan.tile_1_ID, kan.tile_2_ID, kan.tile_3_ID);

        decision_finished();
    }

    private void server_pon(ServerMessage message)
    {
        ServerMessagePon pon = (ServerMessagePon)message;
        state.pon(pon.player_index, pon.discard_player_index, pon.tile_ID, pon.tile_1_ID, pon.tile_2_ID);

        decision_finished();
    }

    private void server_chii(ServerMessage message)
    {
        ServerMessageChii chii = (ServerMessageChii)message;
        state.chii(chii.player_index, chii.discard_player_index, chii.tile_ID, chii.tile_1_ID, chii.tile_2_ID);
    }

    ////////////////////////

    public void server_turn_decision(ServerMessage message)
    {
        do_turn_decision();
    }

    public void server_call_decision(ServerMessage message)
    {
        ServerMessageCallDecision call = (ServerMessageCallDecision)message;
        ClientRoundStatePlayer player = state.get_player(call.player_index);
        Tile tile = state.get_tile(call.tile_ID);

        do_call_decision(tile, player);
    }

    ////////////////////////

    private enum State
    {
        SELECT_CHII,
        SELECT_KAN,
        SELECT_RIICHI,
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
        CHII,
        CLOSED_KAN,
        LATE_KAN,
        RIICHI,
        RIICHI_WAIT
    }
}
