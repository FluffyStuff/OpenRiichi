using Gee;

namespace GameServer
{
    class ServerRoundStateValidator
    {
        private RoundState state;
        private ActionState action_state = ActionState.STARTING;
        private ServerSettings settings;

        public ServerRoundStateValidator(ServerSettings settings, int dealer, int wall_index, Random rnd, Wind round_wind, bool[] can_riichi, Tile[]? tiles)
        {
            this.settings = settings;

            if (tiles == null)
                state = new RoundState.server(settings, round_wind, dealer, wall_index, rnd, can_riichi);
            else
                state = new RoundState.custom(settings, round_wind, dealer, wall_index, can_riichi, tiles);

            players = new ServerRoundStatePlayer[4];

            for (int i = 0; i < players.length; i++)
                players[i] = new ServerRoundStatePlayer(state.get_player(i));
        }

        public void start()
        {
            state.start();
            action_state = ActionState.WAITING_TURN;
        }

        public Tile draw_wall()
        {
            return state.tile_draw();
        }

        public bool discard_tile(int tile_ID)
        {
            if (state.tile_discard(tile_ID))
            {
                chankan_call = false;
                return true;
            }

            return false;
        }

        public int[] get_nagashi_indices()
        {
            return state.get_nagashi_indices();
        }

        public ArrayList<ServerRoundStatePlayer> get_tenpai_players()
        {
            ArrayList<ServerRoundStatePlayer> players = new ArrayList<ServerRoundStatePlayer>();

            if (state.game_draw_type == GameDrawType.NONE ||
                state.game_draw_type == GameDrawType.EMPTY_WALL ||
                state.game_draw_type == GameDrawType.FOUR_RIICHI ||
                state.game_draw_type == GameDrawType.TRIPLE_RON)
            {
                foreach (var player in state.get_tenpai_players())
                    players.add(this.players[player.index]);
            }
            else if (state.game_draw_type == GameDrawType.VOID_HAND)
                players.add(get_current_player());

            return players;
        }

        public ServerRoundStatePlayer get_current_player()
        {
            return get_player(state.current_player.index);
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
                if (player.index == state.current_player.index || player.disconnected)
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
            else
                state.calls_finished();

            return players;
        }

        public void default_call_decisions()
        {
            foreach (ServerRoundStatePlayer player in players)
                if (player.state == PlayerState.WAITING_CALL)
                    no_call(player.index);
        }

        public Tile default_tile_discard()
        {
            ServerRoundStatePlayer player = get_current_player();
            Tile tile = player.default_discard_tile;

            discard_tile(tile.ID);
            return tile;
        }

        public bool void_hand()
        {
            if (!state.can_void_hand())
                return false;

            state.void_hand();
            action_state = ActionState.FINISHED;

            return true;
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

        public bool riichi(bool open)
        {
            if (open && settings.open_riichi != Options.OnOffEnum.ON)
                return false;

            return state.riichi(open);
        }

        public Scoring[] get_ron_score()
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
            ArrayList<Tile>? tiles = state.closed_kan(type);
            if (tiles != null)
                chankan_call = true;

            return tiles;
        }

        public bool do_late_kan(int tile_ID)
        {
            if (state.late_kan(tile_ID) != null)
            {
                chankan_call = true;
                return true;
            }

            return false;
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

        public CallResult? get_call()
        {
            ArrayList<ServerRoundStatePlayer> ron_players = new ArrayList<ServerRoundStatePlayer>();
            ServerRoundStatePlayer? kan_pon_player = null;
            ServerRoundStatePlayer? chii_player = null;

            for (int i = 0; i < players.length - 1; i++)
            {
                int index = (state.current_player.index + 1 + i) % 4;
                ServerRoundStatePlayer player = get_player(index);

                if (player.call_decision != null)
                {
                    if (player.call_decision.call_type == CallDecisionType.RON)
                        ron_players.add(player);
                    else if (player.call_decision.call_type == CallDecisionType.KAN || player.call_decision.call_type == CallDecisionType.PON)
                        kan_pon_player = player;
                    else if (player.call_decision.call_type == CallDecisionType.CHII)
                        chii_player = player;
                }
            }

            if (ron_players.size > 1)
            {
                if (ron_players.size == 3 && settings.triple_ron_draw == Options.OnOffEnum.ON) {} // Empty
                else if (settings.multiple_ron != Options.OnOffEnum.ON)
                {
                    var p = ron_players[0];
                    ron_players.clear();
                    ron_players.add(p);
                }
            }

            CallResult? result = null;

            if (ron_players.size > 0)
            {
                result = new CallResult
                (
                    ron_players.to_array(),
                    get_player(state.current_player.index),
                    state.discard_tile,
                    null,
                    CallDecisionType.RON,
                    state.riichi_return_index,
                    ron_players.size >= 3 && settings.triple_ron_draw == Options.OnOffEnum.ON
                );
            }
            else
            {
                ServerRoundStatePlayer? player = null;
                if (kan_pon_player != null)
                    player = kan_pon_player;
                else if (chii_player != null)
                    player = chii_player;

                if (player != null)
                {
                    result = new CallResult
                    (
                        new ServerRoundStatePlayer[] { player },
                        get_player(state.current_player.index),
                        state.discard_tile,
                        player.call_decision.tiles,
                        player.call_decision.call_type,
                        state.riichi_return_index,
                        false
                    );
                }
            }

            foreach (ServerRoundStatePlayer player in players)
            {
                player.call_decision = null;
                player.state = PlayerState.DONE;
            }

            if (result != null)
            {
                if (result.call_type == CallDecisionType.RON)
                {
                    int[] indices = new int[result.callers.length];
                    for (int i = 0; i < indices.length; i++)
                        indices[i] = result.callers[i].index;

                    if (!result.draw)
                        state.ron(indices);
                    else
                        state.triple_ron();
                }
                else if (result.call_type == CallDecisionType.KAN)
                    state.open_kan(result.callers[0].index, result.tiles[0].ID, result.tiles[1].ID, result.tiles[2].ID);
                else if (result.call_type == CallDecisionType.PON)
                    state.pon(result.callers[0].index, result.tiles[0].ID, result.tiles[1].ID);
                else if (result.call_type == CallDecisionType.CHII)
                    state.chii(result.callers[0].index, result.tiles[0].ID, result.tiles[1].ID);
            }
            else
                state.calls_finished();

            action_state = ron_players.size > 0 ? ActionState.FINISHED : ActionState.WAITING_TURN;
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
        public ArrayList<Tile> ura_dora{ get { return state.ura_dora; } }
        public Tile[] tiles { get { return state.tiles; } }
        public bool game_over { get { return state.game_over; } }
        public bool game_draw { get { return state.game_draw_type != GameDrawType.NONE; } }
        public GameDrawType game_draw_type { get { return state.game_draw_type; } }
        public bool tiles_empty { get { return state.tiles_empty; } }
        public bool chankan_call { get; private set; }

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
        public CallResult
        (
            ServerRoundStatePlayer[] callers,
            ServerRoundStatePlayer discarder,
            Tile discard_tile,
            ArrayList<Tile>? tiles,
            CallDecisionType call_type,
            int riichi_return_index,
            bool draw
        )
        {
            this.callers = callers;
            this.discarder = discarder;
            this.discard_tile = discard_tile;
            this.tiles = tiles;
            this.call_type = call_type;
            this.riichi_return_index = riichi_return_index;
            this.draw = draw;
        }

        public ServerRoundStatePlayer[] callers { get; private set; }
        public ServerRoundStatePlayer discarder { get; private set; }
        public Tile discard_tile { get; private set; }
        public ArrayList<Tile>? tiles { get; private set; }
        public CallDecisionType call_type { get; private set; }
        public int riichi_return_index { get; private set; }
        public bool draw { get; private set; }
    }
}
