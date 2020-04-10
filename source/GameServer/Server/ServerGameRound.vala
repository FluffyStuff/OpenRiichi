using Gee;
using Engine;

namespace GameServer
{
    abstract class ServerGameRound
    {
        private RoundStartInfo info;

        protected ArrayList<GameRoundServerPlayer> players = new ArrayList<GameRoundServerPlayer>();
        protected ServerRoundState round;

        public bool finished { get; private set; }
        public RoundFinishResult result { get; private set; }

        public signal void declare_riichi(int player_index);

        protected ServerGameRound(RoundStartInfo info)
        {
            this.info = info;
        }

        protected void init()
        {
            round.game_initial_draw.connect(game_initial_draw);
            round.game_draw_tile.connect(game_draw_tile);
            round.game_discard_tile.connect(game_discard_tile);
            round.game_flip_dora.connect(game_flip_dora);
            round.game_flip_ura_dora.connect(game_flip_ura_dora);
            round.game_draw_dead_tile.connect(game_draw_dead_tile);
            round.game_get_turn_decision.connect(game_get_turn_decision);
            round.game_get_call_decision.connect(game_get_call_decision);
            round.game_ron.connect(game_ron);
            round.game_tsumo.connect(game_tsumo);
            round.game_riichi.connect(game_riichi);
            round.game_late_kan.connect(game_late_kan);
            round.game_closed_kan.connect(game_closed_kan);
            round.game_open_kan.connect(game_open_kan);
            round.game_pon.connect(game_pon);
            round.game_chii.connect(game_chii);
            round.game_calls_finished.connect(game_calls_finished);
            round.game_draw.connect(game_draw);
        }

        protected void assign_spectators(ArrayList<ServerPlayer> spectators)
        {
            foreach (ServerPlayer player in spectators)
            {
                GameRoundServerPlayer p = new GameRoundServerPlayer(player, -1);
                this.players.add(p);
            }
        }

        public void start(float time)
        {
            ServerMessageRoundStart start_message = new ServerMessageRoundStart(info);
            foreach (var player in players)
                player.server_player.send_message(start_message);

            round_starting();
            round.start(time);
        }

        public void process(float time)
        {
            processing();
            round.process(time);
        }

        public void player_disconnected(int index)
        {
            round.set_disconnected(index);
        }

        ////////////////////////

        private void game_initial_draw(int player_index, ArrayList<Tile> hand)
        {
            GameRoundServerPlayer player = get_server_player(players, player_index);

            foreach (GameRoundServerPlayer p in players)
            {
                foreach (Tile tile in hand)
                {
                    ServerMessageTileAssignment assignment = new ServerMessageTileAssignment(tile);

                    if (p == player || p.server_player.state != ServerPlayer.State.PLAYER)
                        p.server_player.send_message(assignment);
                }
            }
        }

        private void game_draw_tile(int player_index, Tile tile, bool open)
        {
            GameRoundServerPlayer player = get_server_player(players, player_index);
            ServerMessageTileAssignment assignment = new ServerMessageTileAssignment(tile);
            ServerMessageTileDraw draw = new ServerMessageTileDraw();

            foreach (GameRoundServerPlayer p in players)
            {
                if (p == player || p.server_player.state != ServerPlayer.State.PLAYER || open)
                    p.server_player.send_message(assignment);

                p.server_player.send_message(draw);
            }
        }

        protected void game_reveal_tile(Tile tile)
        {
            ServerMessageTileAssignment assignment = new ServerMessageTileAssignment(tile);

            foreach (GameRoundServerPlayer p in players)
                p.server_player.send_message(assignment);
        }

        private void game_discard_tile(Tile tile)
        {
            game_reveal_tile(tile);
            ServerMessageTileDiscard message = new ServerMessageTileDiscard(tile.ID);

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        private void game_flip_dora(Tile tile)
        {
            game_reveal_tile(tile);
        }

        private void game_flip_ura_dora(ArrayList<Tile> tiles)
        {
            foreach (Tile tile in tiles)
                game_reveal_tile(tile);
        }

        private void game_draw_dead_tile(int player_index, Tile tile, bool open)
        {
            GameRoundServerPlayer player = get_server_player(players, player_index);
            ServerMessageTileAssignment assignment = new ServerMessageTileAssignment(tile);

            foreach (GameRoundServerPlayer p in players)
            {
                if (p == player || p.server_player.state != ServerPlayer.State.PLAYER || open)
                    p.server_player.send_message(assignment);
            }
        }

        private void game_get_turn_decision(int player_index)
        {
            ServerMessageTurnDecision message = new ServerMessageTurnDecision();
            get_server_player(players, player_index).server_player.send_message(message);
        }

        private void game_get_call_decision(int player_index)
        {
            ServerMessageCallDecision message = new ServerMessageCallDecision();
            get_server_player(players, player_index).server_player.send_message(message);
        }

        private void game_ron(int[] player_indices, ArrayList<Tile>[] hands, int discard_player_index, Tile discard_tile, int riichi_return_index, Scoring[] scores)
        {
            foreach (ArrayList<Tile> hand in hands)
                foreach (Tile t in hand)
                    game_reveal_tile(t);

            ServerMessageRon message = new ServerMessageRon(player_indices);

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);

            finished = true;
            result = new RoundFinishResult.ron(scores, player_indices, discard_player_index, discard_tile.ID, riichi_return_index);
        }

        private void game_tsumo(int player_index, ArrayList<Tile> hand, Scoring score)
        {
            foreach (Tile t in hand)
                game_reveal_tile(t);

            ServerMessageTsumo message = new ServerMessageTsumo();

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);

            finished = true;
            result = new RoundFinishResult.tsumo(score, player_index);
        }

        private void game_riichi(int player_index, bool open, ArrayList<Tile> hand)
        {
            if (open)
                foreach (Tile t in hand)
                    game_reveal_tile(t);

            ServerMessageRiichi message = new ServerMessageRiichi(open);

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);

            declare_riichi(player_index);
        }

        public void game_late_kan(Tile tile)
        {
            game_reveal_tile(tile);
            ServerMessageLateKan message = new ServerMessageLateKan(tile.ID);

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_closed_kan(ArrayList<Tile> tiles)
        {
            foreach (Tile t in tiles)
                game_reveal_tile(t);

            ServerMessageClosedKan message = new ServerMessageClosedKan(tiles[0].tile_type);

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_open_kan(int player_index, ArrayList<Tile> tiles)
        {
            foreach (Tile t in tiles)
                game_reveal_tile(t);

            ServerMessageOpenKan message = new ServerMessageOpenKan(player_index, tiles[0].ID, tiles[1].ID, tiles[2].ID);

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_pon(int player_index, ArrayList<Tile> tiles)
        {
            foreach (Tile t in tiles)
                game_reveal_tile(t);

            ServerMessagePon message = new ServerMessagePon(player_index, tiles[0].ID, tiles[1].ID);

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_chii(int player_index, ArrayList<Tile> tiles)
        {
            foreach (Tile t in tiles)
                game_reveal_tile(t);

            ServerMessageChii message = new ServerMessageChii(player_index, tiles[0].ID, tiles[1].ID);

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_calls_finished()
        {
            ServerMessageCallsFinished message = new ServerMessageCallsFinished();

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_draw(int[] tenpai_indices, int[] nagashi_indices, GameDrawType draw_type, ArrayList<Tile> all_tenpai_tiles)
        {
            foreach (Tile t in all_tenpai_tiles)
                game_reveal_tile(t);

            ServerMessageDraw message = new ServerMessageDraw(tenpai_indices, draw_type == GameDrawType.VOID_HAND, draw_type == GameDrawType.TRIPLE_RON);

            foreach (GameRoundServerPlayer pl in players)
                pl.server_player.send_message(message);

            finished = true;
            result = new RoundFinishResult.draw(tenpai_indices, nagashi_indices, draw_type);
        }

        //////////////////////

        private static GameRoundServerPlayer? get_server_player(ArrayList<GameRoundServerPlayer> players, int index)
        {
            return players[index];
        }

        protected class GameRoundServerPlayer
        {
            public GameRoundServerPlayer(ServerPlayer sp, int index)
            {
                server_player = sp;
                this.index = index;
            }

            public ServerPlayer server_player { get; private set; }
            public int index { get; private set; }
        }

        protected virtual void round_starting() {}
        protected virtual void processing() {}
        public virtual void message_received(ServerPlayer player, ClientMessage message) {}
    }

    class RegularServerGameRound : ServerGameRound
    {
        private ClientMessageParser parser = new ClientMessageParser();
        public signal void log(GameLogLine line);

        public RegularServerGameRound(RoundStartInfo info, ServerSettings settings, ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> spectators, Wind round_wind, int dealer, RandomClass rnd, bool[] can_riichi, AnimationTimings timings)
        {
            base(info);

            round = new RegularServerRoundState(settings, round_wind, dealer, info.wall_index, rnd, can_riichi, timings);
            tiles = round.get_tiles();

            init();
            round.log.connect(do_log);
            parser.connect(client_action, typeof(ClientMessageGameAction));

            for (int i = 0; i < players.size; i++)
            {
                ServerGameRound.GameRoundServerPlayer player = new ServerGameRound.GameRoundServerPlayer(players[i], i);
                this.players.add(player);

                if (player.server_player.is_disconnected)
                    round.set_disconnected(player.index);
            }

            assign_spectators(spectators);
        }

        private void do_log(GameLogLine line)
        {
            log(line);
        }

        private void client_action(ServerPlayer player, ClientMessage message)
        {
            ClientMessageGameAction action = message as ClientMessageGameAction;
            var p = get_game_player(players, player);

            if (p == null)
                return;
                
            round.buffer_action(new ClientServerAction(p.index, action.action));
        }

        protected override void processing()
        {
            parser.execute_all();
        }

        public override void message_received(ServerPlayer player, ClientMessage message)
        {
            parser.add(player, message);
        }

        private static ServerGameRound.GameRoundServerPlayer? get_game_player(ArrayList<ServerGameRound.GameRoundServerPlayer> players, ServerPlayer player)
        {
            foreach (var p in players)
                if (p.server_player == player)
                    return p;
            return null;
        }

        public Tile[] tiles { get; private set; }
    }

    class LogServerGameRound : ServerGameRound
    {
        GameLogRound log_round;

        public LogServerGameRound(ServerSettings settings, ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> spectators, Wind round_wind, int dealer, RandomClass rnd, bool[] can_riichi, AnimationTimings timings, GameLogRound log_round)
        {
            base(log_round.start_info);
            this.log_round = log_round;

            round = new LogServerRoundState(settings, round_wind, dealer, rnd, can_riichi, timings, log_round);

            for (int i = 0; i < players.size; i++)
            {
                ServerGameRound.GameRoundServerPlayer player = new ServerGameRound.GameRoundServerPlayer(players[i], i);
                this.players.add(player);
            }

            init();

            assign_spectators(spectators);
        }

        protected override void round_starting()
        {
            foreach (Tile tile in log_round.tiles.to_array())
                game_reveal_tile(tile);
        }
    }
}
