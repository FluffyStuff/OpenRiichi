using Gee;
using Engine;

namespace GameServer
{
    abstract class ServerRoundState
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

        private ServerRoundStateValidator validator;
        private int dealer;
        private int wall_index;
        private float current_time;
        private bool round_finished;
        private int pending_turn_decision = -1;
        private bool pending_call_decisions;

        private DelayTimer animation_timer = new DelayTimer();

        protected abstract void next_player_action(float time);

        protected ServerRoundState(ServerSettings settings, Wind round_wind, int dealer, int wall_index, RandomClass rnd, bool[] can_riichi, AnimationTimings timings, Tile[]? tiles)
        {
            validator = new ServerRoundStateValidator(settings, dealer, wall_index, rnd, round_wind, can_riichi, tiles);
            this.dealer = dealer;
            this.wall_index = wall_index;
            this.timings = timings;
        }

        public void process(float time)
        {
            if (round_finished)
                return;
            
            if (animation_timer.is_active)
            {
                if (!animation_timer.active(time))
                    return;
                move_start_time = time;
            }
            
            current_time = time;

            if (pending_turn_decision != -1)
            {
                turn_decision(pending_turn_decision);
                pending_turn_decision = -1;
            }

            if (pending_call_decisions)
            {
                call_decisions();
                pending_call_decisions = false;
            }

            next_player_action(time);
        }

        public void set_disconnected(int index)
        {
            validator.get_player(index).disconnected = true;
        }

        public void start(float time)
        {
            current_time = time;

            validator.start();
            add_animation_delay(timings.split_wall.total());
            initial_draw();
            game_flip_dora(validator.newest_dora);
            next_turn();
        }

        private void log_action(ServerAction action)
        {
            log(new GameLogLine(current_time - move_start_time, action));
        }

        protected void process_action(ClientServerAction action)
        {
            ClientAction a = action.action;

            if (a is VoidHandClientAction)
                client_void_hand(action);
            else if (a is TileDiscardClientAction)
                client_tile_discard(action);
            else if (a is NoCallClientAction)
                client_no_call(action);
            else if (a is RonClientAction)
                client_ron(action);
            else if (a is TsumoClientAction)
                client_tsumo(action);
            else if (a is RiichiClientAction)
                client_riichi(action);
            else if (a is LateKanClientAction)
                client_late_kan(action);
            else if (a is ClosedKanClientAction)
                client_closed_kan(action);
            else if (a is OpenKanClientAction)
                client_open_kan(action);
            else if (a is PonClientAction)
                client_pon(action);
            else if (a is ChiiClientAction)
                client_chii(action);
        }

        public Tile[] get_tiles()
        {
            return validator.get_tiles();
        }

        private void add_animation_delay(float delay)
        {
            animation_timer.set_time(delay, true);
        }
        
        private bool client_void_hand(ClientServerAction action)
        {
            int player_index = action.client;

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

            log_action(action);
            draw_situation();
            return true;
        }

        private bool client_tile_discard(ClientServerAction action)
        {
            int player_index = action.client;

            var a = action.action as TileDiscardClientAction;
            int tile_ID = a.tile;

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

            log_action(action);
            tile_discard(validator.get_tile(tile_ID));
            return true;
        }

        private bool client_no_call(ClientServerAction action)
        {
            int player_index = action.client;

            if (!validator.can_call(player_index))
            {
                debug_log("client_no_call(" + player_index.to_string() + "): Player trying to do invalid no call");
                return false;
            }

            log_action(action);
            validator.no_call(player_index);
            check_calls_done();

            return true;
        }

        private bool client_ron(ClientServerAction action)
        {
            int player_index = action.client;

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

            log_action(action);
            check_calls_done();
            return true;
        }

        private bool client_tsumo(ClientServerAction action)
        {
            int player_index = action.client;

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

            log_action(action);
            if (player.in_riichi)
                game_flip_ura_dora(validator.ura_dora);
            game_tsumo(player.index, player.hand, validator.get_tsumo_score());
            game_over();
            return true;
        }

        private bool client_riichi(ClientServerAction action)
        {
            int player_index = action.client;

            var a = action.action as RiichiClientAction;
            bool open = a.open;

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

            log_action(action);
            ServerRoundStatePlayer player = validator.get_player(player_index);
            game_riichi(player_index, player.open, player.hand);
            return true;
        }

        private bool client_late_kan(ClientServerAction action)
        {
            int player_index = action.client;

            var a = action.action as LateKanClientAction;
            int tile_ID = a.tile;

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

            log_action(action);
            Tile tile = validator.get_tile(tile_ID);

            game_late_kan(tile);
            queue_call_decisions();

            return true;
        }

        private bool client_closed_kan(ClientServerAction action)
        {
            int player_index = action.client;

            var a = action.action as ClosedKanClientAction;
            TileType type = a.tile_type;

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

            log_action(action);
            game_closed_kan(tiles);
            queue_call_decisions();

            return true;
        }

        private bool client_open_kan(ClientServerAction action)
        {
            int player_index = action.client;

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

            log_action(action);
            check_calls_done();

            return true;
        }

        private bool client_pon(ClientServerAction action)
        {
            int player_index = action.client;

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

            log_action(action);
            check_calls_done();

            return true;
        }

        private bool client_chii(ClientServerAction action)
        {
            int player_index = action.client;

            var a = action.action as ChiiClientAction;
            int tile_1_ID = a.tile_1;
            int tile_2_ID = a.tile_2;

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

            log_action(action);
            check_calls_done();

            return true;
        }

        /////////////////////

        private void tile_discard(Tile tile)
        {
            add_animation_delay(timings.tile_discard.total());
            game_discard_tile(tile);
            queue_call_decisions();
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
                add_animation_delay(timings.call.total());
            }
            else if (result.call_type == CallDecisionType.PON)
            {
                game_pon(caller.index, result.tiles);
                add_animation_delay(timings.call.total());
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

        private void queue_turn_decision(int player_index)
        {
            pending_turn_decision = player_index;
        }

        private void turn_decision(int player_index)
        {
            turn_decision_started();

            if (!validator.get_player(player_index).disconnected)
                game_get_turn_decision(player_index);
            else
                default_action();
        }

        private void queue_call_decisions()
        {
            pending_call_decisions = true;
        }

        private void call_decisions()
        {
            call_decisions_started();

            var call_players = validator.do_player_calls();

            if (call_players.size == 0)
            {
                game_calls_finished();
                next_turn();
                return;
            }

            foreach (var player in call_players)
                game_get_call_decision(player.index);
        }

        protected void default_action()
        {
            // Waiting for call decisions
            if (!validator.calls_finished)
            {
                log_action(new DefaultNoCallServerAction());
                validator.default_call_decisions();
                check_calls_done();
            }
            else // Waiting for turn decision
            {
                int index = validator.get_current_player().index;
                Tile tile = validator.default_tile_discard();
                log_action(new DefaultDiscardServerAction(index, tile.ID));
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

            queue_turn_decision(player.index);
            add_animation_delay(timings.tile_draw.total());
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
            add_animation_delay(timings.call.total() + timings.tile_draw.total());
        }

        private void initial_draw()
        {
            foreach (ServerRoundStatePlayer player in validator.players)
                game_initial_draw(player.index, player.hand);
            add_animation_delay(timings.initial_draw.total() * 16);
        }

        private void game_over()
        {
            round_finished = true;
        }

        protected virtual void call_decisions_started() {}
        protected virtual void turn_decision_started() {}
        public virtual void buffer_action(ClientServerAction action) {}

        protected float move_start_time { get; private set; }
        protected AnimationTimings timings { get; private set; }
    }

    class RegularServerRoundState : ServerRoundState
    {
        private ArrayList<ClientServerAction> actions = new ArrayList<ClientServerAction>();
        private DelayTimer move_timer = new DelayTimer();

        public RegularServerRoundState(ServerSettings settings, Wind round_wind, int dealer, int wall_index, RandomClass rnd, bool[] can_riichi, AnimationTimings timings)
        {
            base(settings, round_wind, dealer, wall_index, rnd, can_riichi, timings, null);
        }

        public override void buffer_action(ClientServerAction action)
        {
            actions.add(action);
        }

        protected override void next_player_action(float time)
        {
            while (actions.size > 0)
                process_action(actions.remove_at(0));

            if (!move_timer.is_active || !move_timer.active(time))
                return;

            default_action();
        }

        protected override void call_decisions_started()
        {
            move_timer.set_time(timings.decision_time);
        }

        protected override void turn_decision_started()
        {
            move_timer.set_time(timings.decision_time);
        }
    }

    class LogServerRoundState : ServerRoundState
    {
        private ArrayList<GameLogLine> lines;

        public LogServerRoundState(ServerSettings settings, Wind round_wind, int dealer, RandomClass rnd, bool[] can_riichi, AnimationTimings timings, GameLogRound round)
        {
            base(settings, round_wind, dealer, round.start_info.wall_index, rnd, can_riichi, timings, round.tiles.to_array());
            lines = new ArrayList<GameLogLine>.wrap(round.lines.to_array());
        }

        protected override void next_player_action(float time)
        {
            if (lines.size == 0)
            {
                default_action();
                return;
            }
            
            GameLogLine line = lines[0];

            if (time - move_start_time > line.delta)
            {
                action(line.action);
                lines.remove_at(0);
            }
        }

        private void action(ServerAction action)
        {
            if (action is ClientServerAction)
                process_action(action as ClientServerAction);
            else if (action is DefaultDiscardServerAction || action is DefaultNoCallServerAction)
                default_action();
        }
    }
}