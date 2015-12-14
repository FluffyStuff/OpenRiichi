using Gee;

namespace GameServer
{
    class ServerRoundStateValidator
    {
        private RoundState state;
        private ActionState action_state = ActionState.STARTING;

        public ServerRoundStateValidator(int dealer, int wall_index, Rand rnd, Wind round_wind, bool[] can_riichi)
        {
            state = new RoundState.server(round_wind, dealer, wall_index, rnd, can_riichi);

            players = new ServerRoundStatePlayer[4];

            for (int i = 0; i < players.length; i++)
                players[i] = new ServerRoundStatePlayer(state.get_player(i));
        }

        public void start()
        {
            state.start();
        }

        public Tile draw_wall()
        {
            action_state = ActionState.WAITING_TURN;
            return state.tile_draw();
        }

        public bool discard_tile(int tile_ID)
        {
            return state.tile_discard(tile_ID);
        }

        public ArrayList<ServerRoundStatePlayer> get_tenpai_players()
        {
            ArrayList<ServerRoundStatePlayer> players = new ArrayList<ServerRoundStatePlayer>();

            foreach (var player in state.get_tenpai_players())
                players.add(this.players[player.index]);

            return players;
        }

        public ServerRoundStatePlayer get_current_player()
        {
            return players[state.current_player.index];
        }

        public bool is_players_turn(int index)
        {
            return state.current_player.index == index && action_state == ActionState.WAITING_TURN;
        }

        public Tile get_tile(int tile_ID)
        {
            return state.get_tile(tile_ID);
        }

        public ServerRoundStatePlayer? get_player(int player_index)
        {
            foreach (ServerRoundStatePlayer player in players)
                if (player.index == player_index)
                    return player;
            return null;
        }

        public ArrayList<ServerRoundStatePlayer> do_player_calls()
        {
            ArrayList<ServerRoundStatePlayer> players = new ArrayList<ServerRoundStatePlayer>();

            foreach (ServerRoundStatePlayer player in this.players)
            {
                if (player.index == state.current_player.index)
                    continue;

                if (state.can_ron(player.player) ||
                    state.can_pon(player.player) ||
                    state.can_chii(player.player))
                {
                    player.state = PlayerState.WAITING_CALL;
                    players.add(player);
                }
            }

            if (players.size != 0)
                action_state = ActionState.WAITING_CALLS;

            return players;
        }

        public bool can_call(int player_index)
        {
            return
                action_state == ActionState.WAITING_CALLS &&
                get_player(player_index).state == PlayerState.WAITING_CALL;
        }

        public void no_call(int player_index)
        {
            ServerRoundStatePlayer player = get_player(player_index);
            player.state = PlayerState.DONE;
            player.call_decision = null;
        }

        public bool riichi()
        {
            return state.riichi();
        }

        public Scoring get_ron_score()
        {
            return state.get_ron_score();
        }

        public Scoring get_tsumo_score()
        {
            return state.get_tsumo_score();
        }

        public bool decide_ron(int player_index)
        {
            ServerRoundStatePlayer player = get_player(player_index);

            if (!state.can_ron(player.player))
                return false;

            player.state = PlayerState.DONE;
            player.call_decision = new RoundStateCallDecision(CallDecisionType.RON, null);

            return true;
        }

        public bool tsumo()
        {
            if (!state.can_tsumo())
                return false;

            state.tsumo();
            action_state = ActionState.FINISHED;

            return true;
        }

        public ArrayList<Tile>? do_closed_kan(TileType type)
        {
            return state.closed_kan(type);
        }

        public bool do_late_kan(int tile_ID)
        {
            return state.late_kan(tile_ID) != null;
        }

        public bool decide_open_kan(int player_index)
        {
            ServerRoundStatePlayer player = get_player(player_index);

            if (!state.can_open_kan(player.player))
                return false;

            player.state = PlayerState.DONE;
            var tiles = player.get_open_kan_tiles(state.discard_tile);
            player.call_decision = new RoundStateCallDecision(CallDecisionType.KAN, tiles);

            return true;
        }

        public bool decide_pon(int player_index)
        {
            ServerRoundStatePlayer player = get_player(player_index);

            if (!state.can_pon(player.player))
                return false;

            var tiles = player.get_pon_tiles(state.discard_tile);
            player.state = PlayerState.DONE;
            player.call_decision = new RoundStateCallDecision(CallDecisionType.PON, tiles);

            return true;
        }

        public bool decide_chii(int player_index, int tile_1_ID, int tile_2_ID)
        {
            ServerRoundStatePlayer player = get_player(player_index);

            Tile tile_1 = get_tile(tile_1_ID);
            Tile tile_2 = get_tile(tile_2_ID);

            if (!state.can_chii_with(player.player, tile_1, tile_2))
                return false;

            ArrayList<Tile> tiles = new ArrayList<Tile>();
            tiles.add(tile_1);
            tiles.add(tile_2);

            player.state = PlayerState.DONE;
            player.call_decision = new RoundStateCallDecision(CallDecisionType.CHII, tiles);

            return true;
        }

        public void game_draw()
        {
            state.game_draw();
        }

        public CallResult? get_call()
        {
            CallResult? result = null;

            for (int i = 0; i < players.length - 1; i++)
            {
                int index = (state.current_player.index + 1 + i) % 4;
                ServerRoundStatePlayer player = get_player(index);

                if (player.call_decision != null)
                {
                    bool use = false;
                    if (result == null)
                        use = true;
                    else if (player.call_decision.call_type == CallDecisionType.RON && result.call_type != CallDecisionType.RON)
                        use = true;
                    else if (result.call_type == CallDecisionType.CHII)
                        use = true;

                    if (use)
                        result = new CallResult(player, get_player(state.current_player.index), state.discard_tile, player.call_decision.tiles, player.call_decision.call_type);
                }

                player.call_decision = null;
                player.state = PlayerState.DONE;
            }

            bool ron = false;
            if (result != null)
            {
                if (result.call_type == CallDecisionType.RON)
                {
                    state.ron(result.caller.index);
                    ron = true;
                }
                else if (result.call_type == CallDecisionType.KAN)
                    state.open_kan(result.caller.index, result.tiles[0].ID, result.tiles[1].ID, result.tiles[2].ID);
                else if (result.call_type == CallDecisionType.PON)
                    state.pon(result.caller.index, result.tiles[0].ID, result.tiles[1].ID);
                else if (result.call_type == CallDecisionType.CHII)
                    state.chii(result.caller.index, result.tiles[0].ID, result.tiles[1].ID);
            }

            action_state = ron ? ActionState.FINISHED : ActionState.WAITING_TURN;
            return result;
        }

        public ServerRoundStatePlayer[] players { get; private set; }

        public bool calls_finished
        {
            get
            {
                foreach (ServerRoundStatePlayer player in players)
                    if (player.state == PlayerState.WAITING_CALL)
                        return false;
                return true;
            }
        }

        public Tile newest_dora { get { return state.newest_dora; } }

        public ArrayList<Tile> ura_dora
        {
            get
            {
                return state.ura_dora;
            }
        }

        public bool game_over { get { return state.game_over; } }
        public bool tiles_empty { get { return state.tiles_empty; } }

        private enum ActionState
        {
            STARTING,
            WAITING_CALLS,
            WAITING_TURN,
            FINISHED
        }
    }

    class CallResult
    {
        public CallResult(ServerRoundStatePlayer caller, ServerRoundStatePlayer discarder, Tile discard_tile, ArrayList<Tile>? tiles, CallDecisionType call_type)
        {
            this.caller = caller;
            this.discarder = discarder;
            this.discard_tile = discard_tile;
            this.tiles = tiles;
            this.call_type = call_type;
        }

        public ServerRoundStatePlayer caller { get; private set; }
        public ServerRoundStatePlayer discarder { get; private set; }
        public Tile discard_tile { get; private set; }
        public ArrayList<Tile>? tiles { get; private set; }
        public CallDecisionType call_type { get; private set; }
    }
}
