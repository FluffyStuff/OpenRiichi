using Gee;

namespace GameServer
{
    class ServerRoundState
    {
        public signal void game_initial_draw(int player_index, ArrayList<Tile> hand);
        public signal void game_draw_tile(int player_index, Tile tile, bool open);
        public signal void game_draw_dead_tile(int player_index, Tile tile, bool open);
        public signal void game_discard_tile(Tile tile);
        public signal void game_flip_dora(Tile tile);
        public signal void game_flip_ura_dora(ArrayList<Tile> tiles);

        public signal void game_ron(int[] player_indices, ArrayList<Tile>[] hand, int discard_player_index, Tile discard_tile, int riichi_return_index, Scoring[] scores);
        public signal void game_tsumo(int player_index, ArrayList<Tile> hand, Scoring score);
        public signal void game_riichi(int player_index, bool open, ArrayList<Tile> hand);
        public signal void game_late_kan(Tile tile);
        public signal void game_closed_kan(ArrayList<Tile> tiles);
        public signal void game_open_kan(int player_index, ArrayList<Tile> tiles);
        public signal void game_pon(int player_index, ArrayList<Tile> tiles);
        public signal void game_chii(int player_index, ArrayList<Tile> tiles);
        public signal void game_calls_finished();

        public signal void game_get_call_decision(int receiver);
        public signal void game_get_turn_decision(int player_index);
        public signal void game_draw(int[] tenpai_indices, int[] nagashi_indices, GameDrawType draw_type, ArrayList<Tile> all_tiles);

        public signal void log(GameLogLine line);

        private void debug_log(string log)
        {
            Environment.log(LogType.DEBUG, "ServerRoundState", log);
        }

        public Tile[] tiles { get { return validator.tiles; } }

        private ServerRoundStateValidator validator;
        private int dealer;
        private int wall_index;
        private int decision_time;
        private float timeout;
        private float current_time;

        public ServerRoundState(ServerSettings settings, Wind round_wind, int dealer, int wall_index, Random rnd, bool[] can_riichi, int decision_time, Tile[]? tiles)
        {
            validator = new ServerRoundStateValidator(settings, dealer, wall_index, rnd, round_wind, can_riichi, tiles);
            this.dealer = dealer;
            this.wall_index = wall_index;
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

        public void set_disconnected(int index)
        {
            validator.get_player(index).disconnected = true;
        }

        public void start(float time)
        {
            /*log("Round start(dealer:" + dealer.to_string() + ",wall_index:" + wall_index.to_string() + ")");
            log(new RoundStartGameLogLine(DateTime timestamp, RoundStartInfo info));
            var str = new StringBuilder();
            str.append("TileSeeds(");

            bool first = true;
            foreach (Tile tile in validator.tiles)
            {
                if (first)
                    first = false;
                else
                    str.append(";");
                str.append(tile.ID.to_string());
                str.append(",");
                str.append(tile.tile_type.to_string());
                str.append(",");
                str.append(tile.dora.to_string());
            }

            str.append(")");
            log(str.str);*/

            //log(new TileSeedsGameLogLine(new TimeStamp.now(), validator.tiles));

            current_time = time;

            validator.start();
            initial_draw();
            game_flip_dora(validator.newest_dora);
            next_turn();
        }

        public bool client_void_hand(int player_index)
        {
            if (!validator.is_players_turn(player_index))
            {
                debug_log("client_void_hand(" + player_index.to_string() + "): Not players turn");
                return false;
            }

            if (!validator.void_hand())
            {
                debug_log("client_void_hand(" + player_index.to_string() + "): Player trying to do invalid void hand");
                return false;
            }

            //log("client_void_hand(" + player_index.to_string() + "): Called void hand");
            log(new ClientVoidHandGameLogLine(new TimeStamp.now(), player_index));
            draw_situation();
            return true;
        }

        public bool client_tile_discard(int player_index, int tile_ID)
        {
            if (!validator.is_players_turn(player_index))
            {
                debug_log("client_tile_discard(" + player_index.to_string() + "): Not players turn");
                return false;
            }

            if (!validator.discard_tile(tile_ID))
            {
                debug_log("client_tile_discard(" + player_index.to_string() + "): Player can't discard selected tile(" + tile_ID.to_string() + ")");
                return false;
            }

            //log("client_tile_discard(" + player_index.to_string() + "): Tile discarded(" + tile_ID.to_string() + ")");
            log(new ClientTileDiscardGameLogLine(new TimeStamp.now(), player_index, tile_ID));
            tile_discard(validator.get_tile(tile_ID));
            return true;
        }

        public bool client_no_call(int player_index)
        {
            if (!validator.can_call(player_index))
            {
                debug_log("client_no_call(" + player_index.to_string() + "): Player trying to do invalid no call");
                return false;
            }

            //log("client_no_call(" + player_index.to_string() + "): Player no call");
            log(new ClientNoCallGameLogLine(new TimeStamp.now(), player_index));
            validator.no_call(player_index);
            check_calls_done();

            return true;
        }

        public bool client_ron(int player_index)
        {
            if (!validator.can_call(player_index))
            {
                debug_log("client_ron(" + player_index.to_string() + "): Player cannot make calls");
                return false;
            }

            if (!validator.decide_ron(player_index))
            {
                debug_log("client_ron(" + player_index.to_string() + "): Player trying to do invalid ron");
                return false;
            }

            log(new ClientRonGameLogLine(new TimeStamp.now(), player_index));
            check_calls_done();
            return true;
        }

        public bool client_tsumo(int player_index)
        {
            if (!validator.is_players_turn(player_index))
            {
                debug_log("client_tsumo(" + player_index.to_string() + "): Not players turn");
                return false;
            }

            if (!validator.tsumo())
            {
                debug_log("client_tsumo(" + player_index.to_string() + "): Player trying to do invalid tsumo");
                return false;
            }

            ServerRoundStatePlayer player = validator.get_player(player_index);

            //log("client_tsumo(" + player_index.to_string() + "): Player called tsumo");
            log(new ClientTsumoGameLogLine(new TimeStamp.now(), player_index));
            if (player.in_riichi)
                game_flip_ura_dora(validator.ura_dora);
            game_tsumo(player.index, player.hand, validator.get_tsumo_score());
            game_over();
            return true;
        }

        public bool client_riichi(int player_index, bool open)
        {
            if (!validator.is_players_turn(player_index))
            {
                debug_log("client_riichi(" + player_index.to_string() + "): Not players turn");
                return false;
            }

            if (!validator.riichi(open))
            {
                debug_log("client_riichi(" + player_index.to_string() + "): Player can't declare riichi");
                return false;
            }

            //log("client_riichi(" + player_index.to_string() + "): Player declared riichi(open:" + open.to_string() + ")");
            log(new ClientRiichiGameLogLine(new TimeStamp.now(), player_index, open));
            ServerRoundStatePlayer player = validator.get_player(player_index);
            game_riichi(player_index, player.open, player.hand);
            return true;
        }

        public bool client_late_kan(int player_index, int tile_ID)
        {
            if (!validator.is_players_turn(player_index))
            {
                debug_log("client_late_kan(" + player_index.to_string() + "): Not players turn");
                return false;
            }

            if (!validator.do_late_kan(tile_ID))
            {
                debug_log("client_late_kan(" + player_index.to_string() + "): Player trying to do invalid late kan(" + tile_ID.to_string() + ")");
                return false;
            }

            //log("client_late_kan(" + player_index.to_string() + "): Player calling late kan(" + tile_ID.to_string() + ")");
            log(new ClientLateKanGameLogLine(new TimeStamp.now(), player_index, tile_ID));
            Tile tile = validator.get_tile(tile_ID);

            game_late_kan(tile);
            call_decisions();

            return true;
        }

        public bool client_closed_kan(int player_index, TileType type)
        {
            if (!validator.is_players_turn(player_index))
            {
                debug_log("client_closed_kan(" + player_index.to_string() + "): Not players turn");
                return false;
            }

            ArrayList<Tile>? tiles = validator.do_closed_kan(type);

            if (tiles == null)
            {
                debug_log("client_closed_kan(" + player_index.to_string() + "): Player trying to do invalid closed kan(" + type.to_string() + ")");
                return false;
            }

            //log("client_closed_kan(" + player_index.to_string() + "): Player making closed kan(" + type.to_string() + ")");
            log(new ClientClosedKanGameLogLine(new TimeStamp.now(), player_index, type));
            game_closed_kan(tiles);
            call_decisions();

            return true;
        }

        public bool client_open_kan(int player_index)
        {
            if (!validator.can_call(player_index))
            {
                debug_log("client_open_kan(" + player_index.to_string() + "): Not players turn");
                return false;
            }

            if (!validator.decide_open_kan(player_index))
            {
                debug_log("client_open_kan(" + player_index.to_string() + "): Player trying to do invalid open kan");
                return false;
            }

            //log("client_open_kan(" + player_index.to_string() + "): Player calling open kan");
            log(new ClientOpenKanGameLogLine(new TimeStamp.now(), player_index));
            check_calls_done();

            return true;
        }

        public bool client_pon(int player_index)
        {
            if (!validator.can_call(player_index))
            {
                debug_log("client_open_kan(" + player_index.to_string() + "): Not players turn");
                return false;
            }

            if (!validator.decide_pon(player_index))
            {
                debug_log("client_pon(" + player_index.to_string() + "): Player trying to do invalid pon");
                return false;
            }

            //log("client_pon(" + player_index.to_string() + "): Player calling pon");
            log(new ClientPonGameLogLine(new TimeStamp.now(), player_index));
            check_calls_done();

            return true;
        }

        public bool client_chii(int player_index, int tile_1_ID, int tile_2_ID)
        {
            if (!validator.can_call(player_index))
            {
                debug_log("client_chii(" + player_index.to_string() + "): Not players turn");
                return false;
            }

            if (!validator.decide_chii(player_index, tile_1_ID, tile_2_ID))
            {
                debug_log("client_chii(" + player_index.to_string() + "): Player trying to do invalid chii(" + tile_1_ID.to_string() + "," + tile_2_ID.to_string() + ")");
                return false;
            }

            //log("client_chii(" + player_index.to_string() + "): Player calling chii(" + tile_1_ID.to_string() + "," + tile_2_ID.to_string() + ")");
            log(new ClientChiiGameLogLine(new TimeStamp.now(), player_index, tile_1_ID, tile_2_ID));
            check_calls_done();

            return true;
        }

        /////////////////////

        private void tile_discard(Tile tile)
        {
            game_discard_tile(tile);
            call_decisions();
        }

        private void check_calls_done()
        {
            if (!validator.calls_finished)
                return;

            CallResult? result = validator.get_call();

            if (result == null)
            {
                game_calls_finished();
                next_turn();
                return;
            }

            ServerRoundStatePlayer discarder = result.discarder;
            ServerRoundStatePlayer caller = result.callers[0];
            Tile discard_tile = result.discard_tile;

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
                bool flip_ura_dora = false;

                int[] indices = new int[result.callers.length];
                ArrayList<Tile>[] hands = new ArrayList<Tile>[result.callers.length];
                for (int i = 0; i < result.callers.length; i++)
                {
                    indices[i] = result.callers[i].index;
                    hands[i] = result.callers[i].hand;

                    if (validator.get_player(indices[i]).in_riichi)
                        flip_ura_dora = true;
                }

                if (result.draw)
                {
                    triple_ron(indices);
                    return;
                }

                if (flip_ura_dora)
                    game_flip_ura_dora(validator.ura_dora);

                game_ron(indices, hands, discarder.index, discard_tile, result.riichi_return_index, validator.get_ron_score());
                game_over();
                return;
            }

            turn_decision(caller.index);
        }

        private void turn_decision(int player_index)
        {
            if (!validator.get_player(player_index).disconnected)
            {
                game_get_turn_decision(player_index);
                reset_timeout();
            }
            else
                default_action();
        }

        private void call_decisions()
        {
            var call_players = validator.do_player_calls();

            if (call_players.size == 0)
            {
                game_calls_finished();
                next_turn();
                return;
            }

            foreach (var player in call_players)
                game_get_call_decision(player.index);
            reset_timeout();
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
                //log("default_action: Defaulting remaining call decisions");
                log(new DefaultCallActionGameLogLine(new TimeStamp.now()));
                validator.default_call_decisions();
                check_calls_done();
            }
            else // Waiting for turn decision
            {
                int index = validator.get_current_player().index;
                Tile tile = validator.default_tile_discard();
                //log("default_action(" + index.to_string() + "): Defaulting tile_discard(" + tile.ID.to_string() + ")");
                log(new DefaultTileDiscardGameLogLine(new TimeStamp.now(), index, tile.ID));
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

            ServerRoundStatePlayer player = validator.get_current_player();

            if (validator.chankan_call)
                kan(player.index);
            else
            {
                Tile tile = validator.draw_wall();
                game_draw_tile(player.index, tile, player.open);
            }

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

            int[] nagashi_indices = validator.get_nagashi_indices();

            game_draw(tenpai_indices, nagashi_indices, validator.game_draw_type, tiles);
            game_over();
        }

        private void triple_ron(int[] ron_indices)
        {
            ArrayList<Tile> tiles = new ArrayList<Tile>();
            for (int i = 0; i < ron_indices.length; i++)
                tiles.add_all(validator.get_player(ron_indices[i]).hand);

            game_draw(ron_indices, new int[] {}, GameDrawType.TRIPLE_RON, tiles);
            game_over();
        }

        private void kan(int player_index)
        {
            ServerRoundStatePlayer player = validator.get_player(player_index);
            game_flip_dora(validator.newest_dora);
            game_draw_dead_tile(player.index, player.newest_tile, player.open);
        }

        private void initial_draw()
        {
            foreach (ServerRoundStatePlayer player in validator.players)
                game_initial_draw(player.index, player.hand);
        }

        private void game_over()
        {
            //log("round_over");
            timeout = 0;
        }
    }
}
