using Gee;

public class ClientRoundState : Object
{
    private RoundState state;
    private State action_state;
    private ServerMessageParser parser = new ServerMessageParser();
    private bool self_active;

    private ArrayList<TileSelectionGroup> selection_groups = new ArrayList<TileSelectionGroup>();

    public signal void do_action(ClientAction action);

    public signal void set_chii_state(bool enabled);
    public signal void set_pon_state(bool enabled);
    public signal void set_kan_state(bool enabled);
    public signal void set_riichi_state(bool enabled);
    public signal void set_tsumo_state(bool enabled);
    public signal void set_ron_state(bool enabled);
    public signal void set_timer_state(bool enabled);
    public signal void set_continue_state(bool enabled);
    public signal void set_void_hand_state(bool enabled);
    public signal void set_furiten_state(bool enabled);

    public signal void set_tile_select_state(bool enabled);
    public signal void set_tile_select_groups(ArrayList<TileSelectionGroup>? selection_groups);

    public bool finished { get; private set; }
    public RoundFinishResult result { get; private set; }

    public signal void game_finished(RoundFinishResult result);
    public signal void game_tile_assignment(Tile tile);
    public signal void game_tile_draw(int player_index);
    public signal void game_dead_tile_draw(int player_index);
    public signal void game_tile_discard(int player_index, int tile_ID);
    public signal void game_flip_dora();
    public signal void game_riichi(int player_index, bool open);
    public signal void game_late_kan(int player_index, int tile_ID);
    public signal void game_closed_kan(int player_index, TileType type);
    public signal void game_open_kan(int player_index, int discard_player_index, int tile_ID, int tile_1_ID, int tile_2_ID, int tile_3_ID);
    public signal void game_pon(int player_index, int discard_player_index, int tile_ID, int tile_1_ID, int tile_2_ID);
    public signal void game_chii(int player_index, int discard_player_index, int tile_ID, int tile_1_ID, int tile_2_ID);

    public ClientRoundState(RoundStartInfo info, ServerSettings settings, int player_index, Wind round_wind, int dealer_index, bool[] can_riichi)
    {
        state = new RoundState(settings, player_index, round_wind, dealer_index, info.wall_index, can_riichi);
        state.start();
        action_state = State.DONE;
        self_active = player_index != -1;

        parser.connect(server_turn_decision, typeof(ServerMessageTurnDecision));
        parser.connect(server_call_decision, typeof(ServerMessageCallDecision));

        parser.connect(server_tile_assignment, typeof(ServerMessageTileAssignment));
        parser.connect(server_tile_draw, typeof(ServerMessageTileDraw));
        parser.connect(server_tile_discard, typeof(ServerMessageTileDiscard));

        parser.connect(server_draw, typeof(ServerMessageDraw));
        parser.connect(server_ron, typeof(ServerMessageRon));
        parser.connect(server_tsumo, typeof(ServerMessageTsumo));
        parser.connect(server_riichi, typeof(ServerMessageRiichi));
        parser.connect(server_late_kan, typeof(ServerMessageLateKan));
        parser.connect(server_closed_kan, typeof(ServerMessageClosedKan));
        parser.connect(server_open_kan, typeof(ServerMessageOpenKan));
        parser.connect(server_pon, typeof(ServerMessagePon));
        parser.connect(server_chii, typeof(ServerMessageChii));
        parser.connect(server_calls_finished, typeof(ServerMessageCallsFinished));
    }

    public void receive_message(ServerMessage message)
    {
        parser.execute(message);
    }

    public void disconnected()
    {
        decision_finished();
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
        set_void_hand_state(false);
        set_timer_state(false);
        set_tile_select_state(false);
    }

    private void do_riichi(Tile tile, bool open)
    {
        do_action(new RiichiClientAction(open));
        do_discard_tile(tile);
    }

    private void do_late_kan(Tile tile)
    {
        do_action(new LateKanClientAction(tile.ID));
    }

    private void do_closed_kan(TileType type)
    {
        do_action(new ClosedKanClientAction(type));
    }

    private void do_chii(Tile tile_1, Tile tile_2)
    {
        do_action(new ChiiClientAction(tile_1.ID, tile_2.ID));
    }

    private void do_turn_decision()
    {
        action_state = State.TURN;

        bool can_kan = state.can_closed_kan() || state.can_late_kan();
        bool can_riichi = state.can_riichi();
        bool can_tsumo = state.can_tsumo();
        bool can_void_hand = state.can_void_hand();

        set_chii_state(false);
        set_pon_state(false);
        set_kan_state(can_kan);
        set_riichi_state(can_riichi);
        set_tsumo_state(can_tsumo);
        set_ron_state(false);
        set_continue_state(false);
        set_void_hand_state(can_void_hand);
        set_timer_state(true);

        selection_groups.clear();

        ArrayList<Tile> discard_tiles = state.current_player.get_discard_tiles();
        foreach (Tile tile in discard_tiles)
        {
            ArrayList<Tile> t = new ArrayList<Tile>();
            t.add(tile);
            selection_groups.add(new TileSelectionGroup(t, t, TileSelectionGroup.GroupType.DISCARD));
        }

        set_tile_select_groups(selection_groups);

        //set_tile_select_state(true);
    }

    private void do_call_decision(Tile tile, RoundStatePlayer discard_player)
    {
        action_state = State.CALL;

        bool can_chii = state.can_chii(state.self);
        bool can_pon = state.can_pon(state.self);
        bool can_kan = state.can_open_kan(state.self);
        bool can_ron = state.can_ron(state.self);

        set_chii_state(can_chii);
        set_pon_state(can_pon);
        set_kan_state(can_kan);
        set_riichi_state(false);
        set_tsumo_state(false);
        set_ron_state(can_ron);
        set_continue_state(true);
        set_void_hand_state(false);
        set_timer_state(true);
        set_tile_select_state(false);
    }

    private void do_discard_tile(Tile tile)
    {
        do_action(new TileDiscardClientAction(tile.ID));
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

    private void do_select_riichi(Tile tile, bool open)
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
                    do_riichi(tile, open);
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

    private void check_furiten()
    {
        if (!self_active)
            return;

        set_furiten_state(state.self.in_furiten());
    }

    /////////////////////////

    public void client_chii()
    {
        if (action_state == State.CALL)
        {
            ArrayList<ArrayList<Tile>> groups = state.get_chii_groups(state.self);

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
            do_call_decision(state.discard_tile, state.current_player);
        }
    }

    public void client_pon()
    {
        if (action_state != State.CALL)
            return;

        decision_finished();

        do_action(new PonClientAction());
    }

    public void client_kan()
    {
        if (action_state == State.CALL)
        {
            decision_finished();

            do_action(new OpenKanClientAction());
        }
        else if (action_state == State.TURN)
        {
            ArrayList<ArrayList<Tile>> closed_kans = state.self.get_closed_kan_groups();
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
                set_void_hand_state(false);
                set_tile_select_groups(selection_groups);
            }
        }
        else if (action_state == State.SELECT_KAN)
        {
            do_turn_decision();
        }
    }

    public void client_riichi(bool open)
    {
        if (action_state == State.TURN)
        {
            ArrayList<Tile> tiles = state.get_tenpai_tiles(state.self);
            if (tiles.size == 1)
            {
                decision_finished();
                do_riichi(tiles[0], open);
            }
            else if (tiles.size > 1)
            {
                if (open)
                    action_state = State.SELECT_OPEN_RIICHI;
                else
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
                set_void_hand_state(false);
                set_tile_select_groups(selection_groups);
            }
        }
        else if (action_state == State.SELECT_RIICHI || action_state == State.SELECT_OPEN_RIICHI)
        {
            do_turn_decision();
        }
    }

    public void client_tsumo()
    {
        if (action_state != State.TURN)
            return;

        decision_finished();
        do_action(new TsumoClientAction());
    }

    public void client_ron()
    {
        if (action_state != State.CALL)
            return;

        decision_finished();
        do_action(new RonClientAction());
    }

    public void client_continue()
    {
        if (action_state != State.CALL)
            return;

        decision_finished();
        do_action(new NoCallClientAction());
    }

    public void client_void_hand()
    {
        if (action_state != State.TURN)
            return;

        decision_finished();
        do_action(new VoidHandClientAction());
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
            do_select_riichi(tile, false);
        else if (action_state == State.SELECT_OPEN_RIICHI)
            do_select_riichi(tile, true);
    }

    ////////////////////////

    private void server_tile_assignment(ServerMessage message)
    {
        ServerMessageTileAssignment tile = (ServerMessageTileAssignment)message;
        Tile t = tile.tile;
        state.tile_assign(t);
        game_tile_assignment(t);
    }

    private void server_tile_draw(ServerMessage message)
    {
        decision_finished();

        state.tile_draw();
        game_tile_draw(state.current_player.index);
    }

    private void server_tile_discard(ServerMessage message)
    {
        decision_finished();

        ServerMessageTileDiscard discard = (ServerMessageTileDiscard)message;
        state.tile_discard(discard.tile_ID);
        game_tile_discard(state.current_player.index, discard.tile_ID);
    }

    private void server_draw(ServerMessage message)
    {
        decision_finished();

        ServerMessageDraw draw = (ServerMessageDraw)message;

        if (draw.void_hand)
            state.void_hand();
        else if (draw.triple_ron)
            state.triple_ron();

        int[] tenpai = draw.get_tenpai_indices();
        int[] nagashi = state.get_nagashi_indices();
        result = new RoundFinishResult.draw(tenpai, nagashi, state.game_draw_type);
        finished = true;
        game_finished(result);
    }

    private void server_ron(ServerMessage message)
    {
        finished = true;
        decision_finished();

        ServerMessageRon ron = (ServerMessageRon)message;
        int discard_index = state.current_player.index;
        int[] winner_indices = ron.get_player_indices();

        state.ron(winner_indices);
        Scoring[] scores = state.get_ron_score();
        result = new RoundFinishResult.ron(scores, winner_indices, discard_index, state.discard_tile.ID, state.riichi_return_index);

        finished = true;
        game_finished(result);
    }

    private void server_tsumo(ServerMessage message)
    {
        state.tsumo();
        Scoring score = state.get_tsumo_score();
        result = new RoundFinishResult.tsumo(score, state.current_player.index);
        finished = true;
        game_finished(result);
    }

    private void server_riichi(ServerMessage message)
    {
        ServerMessageRiichi riichi = (ServerMessageRiichi)message;
        state.riichi(riichi.open);
        game_riichi(state.current_player.index, riichi.open);
    }

    private void server_late_kan(ServerMessage message)
    {
        ServerMessageLateKan kan = (ServerMessageLateKan)message;
        state.late_kan(kan.tile_ID);
        game_late_kan(state.current_player.index, kan.tile_ID);
    }

    private void server_closed_kan(ServerMessage message)
    {
        ServerMessageClosedKan kan = (ServerMessageClosedKan)message;
        TileType type = kan.tile_type;
        state.closed_kan(type);
        game_closed_kan(state.current_player.index, type);
    }

    private void server_open_kan(ServerMessage message)
    {
        decision_finished();

        ServerMessageOpenKan kan = (ServerMessageOpenKan)message;
        int discard_index = state.current_player.index;
        state.open_kan(kan.player_index, kan.tile_1_ID, kan.tile_2_ID, kan.tile_3_ID);

        game_open_kan(state.current_player.index, discard_index, state.discard_tile.ID, kan.tile_1_ID, kan.tile_2_ID, kan.tile_3_ID);

        check_furiten();
    }

    private void server_pon(ServerMessage message)
    {
        decision_finished();

        ServerMessagePon pon = (ServerMessagePon)message;
        int discard_index = state.current_player.index;
        state.pon(pon.player_index, pon.tile_1_ID, pon.tile_2_ID);

        game_pon(state.current_player.index, discard_index, state.discard_tile.ID, pon.tile_1_ID, pon.tile_2_ID);

        check_furiten();
    }

    private void server_chii(ServerMessage message)
    {
        decision_finished();

        ServerMessageChii chii = (ServerMessageChii)message;
        int discard_index = state.current_player.index;
        state.chii(chii.player_index, chii.tile_1_ID, chii.tile_2_ID);

        game_chii(state.current_player.index, discard_index, state.discard_tile.ID, chii.tile_1_ID, chii.tile_2_ID);

        check_furiten();
    }

    public void server_calls_finished(ServerMessage message)
    {
        decision_finished();

        bool kan = state.chankan_call != ChankanCall.NONE;
        state.calls_finished();

        if (kan)
            game_dead_tile_draw(state.current_player.index);

        check_furiten();
    }

    public void server_turn_decision(ServerMessage message)
    {
        do_turn_decision();
    }

    public void server_call_decision(ServerMessage message)
    {
        Tile tile = state.discard_tile;
        var player = state.current_player;

        do_call_decision(tile, player);
    }

    ////////////////////////

    private enum State
    {
        SELECT_CHII,
        SELECT_KAN,
        SELECT_RIICHI,
        SELECT_OPEN_RIICHI,
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
        DISCARD,
        CHII,
        CLOSED_KAN,
        LATE_KAN,
        RIICHI
    }
}
