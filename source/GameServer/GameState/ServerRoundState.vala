using Gee;

namespace GameServer
{
    class ServerRoundState
    {
        public signal void game_initial_draw(int player_index, ArrayList<Tile> hand);
        public signal void game_draw_tile(int player_index, Tile tile);
        public signal void game_draw_dead_tile(int player_index, Tile tile);
        public signal void game_discard_tile(Tile tile);
        public signal void game_flip_dora(Tile tile);
        public signal void game_flip_ura_dora(ArrayList<Tile> tiles);

        public signal void game_ron(int player_index, ArrayList<Tile> hand, int discard_player_index, Scoring score);
        public signal void game_tsumo(int player_index, ArrayList<Tile> hand, Scoring score);
        public signal void game_riichi(int player_index);
        public signal void game_late_kan(Tile tile);
        public signal void game_closed_kan(ArrayList<Tile> tiles);
        public signal void game_open_kan(int player_index, ArrayList<Tile> tiles);
        public signal void game_pon(int player_index, ArrayList<Tile> tiles);
        public signal void game_chii(int player_index, ArrayList<Tile> tiles);

        public signal void game_get_call_decision(int receiver);
        public signal void game_get_turn_decision(int player_index);
        public signal void game_draw(int[] tenpai_indices, ArrayList<Tile> all_tiles);

        private ServerRoundStateValidator validator;
        private int decision_time;
        private float timeout;
        private float current_time;

        public ServerRoundState(Wind round_wind, int dealer, int wall_index, Rand rnd, bool[] can_riichi, int decision_time)
        {
            validator = new ServerRoundStateValidator(dealer, wall_index, rnd, round_wind, can_riichi);
            this.decision_time = decision_time;
        }

        public void process(float time)
        {
            current_time = time;

            if (timeout == 0 || decision_time <= 0 || current_time < timeout)
                return;

            timeout = 0;
            default_action();
        }

        public void start(float time)
        {
            current_time = time;

            validator.start();
            initial_draw();
            game_flip_dora(validator.newest_dora);
            next_turn();
        }

        public bool client_tile_discard(int player_index, int tile_ID)
        {
            if (!validator.is_players_turn(player_index))
            {
                print("client_tile_discard: Not players turn\n");
                return false;
            }

            if (!validator.discard_tile(tile_ID))
            {
                print("client_tile_discard: Player can't discard selected tile");
                return false;
            }

            tile_discard(validator.get_tile(tile_ID));
            return true;
        }

        public bool client_no_call(int player_index)
        {
            if (!validator.can_call(player_index))
            {
                print("client_no_call: Player trying to do invalid no call\n");
                return false;
            }

            validator.no_call(player_index);
            check_calls_done();

            return true;
        }

        public bool client_ron(int player_index)
        {
            if (!validator.can_call(player_index))
                return false;

            if (!validator.decide_ron(player_index))
            {
                print("client_ron: Player trying to do invalid ron\n");
                return false;
            }

            check_calls_done();
            return true;
        }

        public bool client_tsumo(int player_index)
        {
            if (!validator.is_players_turn(player_index))
            {
                print("client_tsumo: Not players turn\n");
                return false;
            }

            if (!validator.tsumo())
            {
                print("client_tsumo: Player trying to do invalid tsumo\n");
                return false;
            }

            ServerRoundStatePlayer player = validator.get_player(player_index);

            if (player.in_riichi)
                game_flip_ura_dora(validator.ura_dora);
            game_tsumo(player.index, player.hand, validator.get_tsumo_score());
            game_over();
            return true;
        }

        public bool client_riichi(int player_index)
        {
            if (!validator.is_players_turn(player_index))
            {
                print("client_riichi: Not players turn\n");
                return false;
            }

            if (!validator.riichi())
            {
                print("client_riichi: Player can't declare riichi\n");
                return false;
            }

            game_riichi(player_index);
            return true;
        }

        public bool client_late_kan(int player_index, int tile_ID)
        {
            if (!validator.is_players_turn(player_index))
            {
                print("client_late_kan: Not players turn\n");
                return false;
            }

            if (!validator.do_late_kan(tile_ID))
            {
                print("client_late_kan: Player trying to do invalid late kan\n");
                return false;
            }

            Tile tile = validator.get_tile(tile_ID);

            game_late_kan(tile);
            kan(player_index);
            turn_decision(player_index);

            return true;
        }

        public bool client_closed_kan(int player_index, TileType type)
        {
            if (!validator.is_players_turn(player_index))
            {
                print("client_closed_kan: Not players turn\n");
                return false;
            }

            ArrayList<Tile>? tiles = validator.do_closed_kan(type);

            if (tiles == null)
            {
                print("client_closed_kan: Player trying to do invalid closed kan\n");
                return false;
            }

            game_closed_kan(tiles);
            kan(player_index);
            turn_decision(player_index);

            return true;
        }

        public bool client_open_kan(int player_index)
        {
            if (!validator.can_call(player_index))
                return false;

            if (!validator.decide_open_kan(player_index))
            {
                print("client_open_kan: Player trying to do invalid open kan\n");
                return false;
            }

            check_calls_done();

            return true;
        }

        public bool client_pon(int player_index)
        {
            if (!validator.can_call(player_index))
                return false;

            if (!validator.decide_pon(player_index))
            {
                print("client_pon: Player trying to do invalid pon\n");
                return false;
            }

            check_calls_done();

            return true;
        }

        public bool client_chii(int player_index, int tile_1_ID, int tile_2_ID)
        {
            if (!validator.can_call(player_index))
                return false;

            if (!validator.decide_chii(player_index, tile_1_ID, tile_2_ID))
            {
                print("client_chii: Player trying to do invalid chii\n");
                return false;
            }

            check_calls_done();

            return true;
        }

        /////////////////////

        private void tile_discard(Tile tile)
        {
            game_discard_tile(tile);

            var call_players = validator.do_player_calls();

            if (call_players.size == 0)
            {
                next_turn();
                return;
            }

            call_decision(call_players);
        }

        private void check_calls_done()
        {
            if (!validator.calls_finished)
                return;

            CallResult? result = validator.get_call();

            if (result == null)
            {
                next_turn();
                return;
            }

            ServerRoundStatePlayer discarder = result.discarder;
            ServerRoundStatePlayer caller = result.caller;

            if (result.call_type == CallDecisionType.CHII)
            {
                game_chii(caller.index, result.tiles);
            }
            else if (result.call_type == CallDecisionType.PON)
            {
                game_pon(caller.index, result.tiles);
            }
            else if (result.call_type == CallDecisionType.KAN)
            {
                game_open_kan(caller.index, result.tiles);
                kan(caller.index);
            }
            else if (result.call_type == CallDecisionType.RON)
            {
                // Game over
                if (caller.in_riichi)
                    game_flip_ura_dora(validator.ura_dora);
                game_ron(caller.index, caller.hand, discarder.index, validator.get_ron_score());
                game_over();
                return;
            }

            turn_decision(caller.index);
        }

        private void turn_decision(int player_index)
        {
            game_get_turn_decision(player_index);
            reset_timeout();
        }

        private void call_decision(ArrayList<ServerRoundStatePlayer> players)
        {
            foreach (var player in players)
                game_get_call_decision(player.index);
            reset_timeout();
        }

        private void kan(int player_index)
        {
            ServerRoundStatePlayer player = validator.get_player(player_index);

            game_flip_dora(validator.newest_dora);
            game_draw_dead_tile(player_index, player.newest_tile);
        }

        private void reset_timeout()
        {
            timeout = current_time + decision_time;
        }

        private void default_action()
        {
            // Waiting for call decisions
            if (!validator.calls_finished)
            {
                validator.default_call_decisions();
                check_calls_done();
            }
            else // Waiting for turn decision
            {
                Tile tile = validator.default_tile_discard();
                tile_discard(tile);
            }
        }

        private void next_turn()
        {
            // Game over
            if (validator.game_draw)
            {
                draw_situation();
                return;
            }

            Tile tile = validator.draw_wall();
            ServerRoundStatePlayer player = validator.get_current_player();
            game_draw_tile(player.index, tile);
            turn_decision(player.index);

        }

        private void draw_situation()
        {
            ArrayList<ServerRoundStatePlayer> tenpai_players = validator.get_tenpai_players();
            ArrayList<Tile> tiles = new ArrayList<Tile>();

            int[] tenpai_indices = new int[tenpai_players.size];
            for (int i = 0; i < tenpai_players.size; i++)
            {
                tenpai_indices[i] = tenpai_players[i].index;
                tiles.add_all(tenpai_players[i].hand);
            }

            game_draw(tenpai_indices, tiles);
            game_over();
        }

        private void initial_draw()
        {
            foreach (ServerRoundStatePlayer player in validator.players)
                game_initial_draw(player.index, player.hand);
        }

        private void game_over()
        {
            timeout = 0;
        }
    }
}
