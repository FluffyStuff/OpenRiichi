using Gee;

namespace GameServer
{
    class ServerGameRound : Object // Signal receiver needs to be object
    {
        private RoundStartInfo info;

        private ArrayList<GameRoundServerPlayer> players = new ArrayList<GameRoundServerPlayer>();
        private ServerRoundState round;
        private ClientMessageParser parser = new ClientMessageParser();
        private bool reveal;

        public bool finished { get; private set; }
        public RoundFinishResult result { get; private set; }
        public Tile[] tiles { get { return round.tiles; } }

        public signal void declare_riichi(int player_index);
        public signal void log(GameLogLine line);

        public ServerGameRound(RoundStartInfo info, ServerSettings settings, ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> spectators, Wind round_wind, int dealer, Random rnd, bool[] can_riichi, int decision_time, Tile[]? tiles, bool reveal)
        {
            this.info = info;
            this.reveal = reveal;

            round = new ServerRoundState(settings, round_wind, dealer, info.wall_index, rnd, can_riichi, decision_time, tiles);

            init();

            for (int i = 0; i < players.size; i++)
            {
                GameRoundServerPlayer player = new GameRoundServerPlayer(players[i], i);
                this.players.add(player);

                if (player.server_player.is_disconnected)
                    round.set_disconnected(player.index);
            }

            foreach (ServerPlayer player in spectators)
            {
                GameRoundServerPlayer p = new GameRoundServerPlayer(player, -1);
                this.players.add(p);
            }
        }

        /*public ServerGameRound.with_log(RoundLog log, ServerSettings settings, ArrayList<ServerPlayer> spectators, Random rnd)
        {
            this.info = log.start_info;
            round = new ServerRoundState(settings, log.round_wind, log.dealer, log.start_info.wall_index, rnd, log.can_riichi, log.decision_time, log.tiles);

            init();

            / *foreach (ServerPlayer player in spectators)
            {
                GameRoundServerPlayer p = new GameRoundServerPlayer(player, -1);
                this.players.add(p);
            }* /
        }*/

        private void init()
        {
            parser.connect(client_void_hand, typeof(ClientMessageVoidHand));
            parser.connect(client_tile_discard, typeof(ClientMessageTileDiscard));
            parser.connect(client_no_call, typeof(ClientMessageNoCall));
            parser.connect(client_ron, typeof(ClientMessageRon));
            parser.connect(client_tsumo, typeof(ClientMessageTsumo));
            parser.connect(client_riichi, typeof(ClientMessageRiichi));
            parser.connect(client_late_kan, typeof(ClientMessageLateKan));
            parser.connect(client_closed_kan, typeof(ClientMessageClosedKan));
            parser.connect(client_open_kan, typeof(ClientMessageOpenKan));
            parser.connect(client_pon, typeof(ClientMessagePon));
            parser.connect(client_chii, typeof(ClientMessageChii));

            round.log.connect(do_log);
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

        private void do_log(GameLogLine line)
        {
            log(line);
        }

        public void start(float time)
        {
            for (int i = 0; i < this.players.size; i++)
            {
                ServerMessageRoundStart start_message = new ServerMessageRoundStart(info);
                this.players[i].server_player.send_message(start_message);
            }

            Thread.usleep(5 * 100 * 1000); // TODO: Find fix for slow loading

            if (reveal)
                foreach (Tile tile in tiles)
                    game_reveal_tile(tile);

            round.start(time);
        }

        public void process(float time)
        {
            parser.execute_all();
            round.process(time);
        }

        public void message_received(ServerPlayer player, ClientMessage message)
        {
            parser.add(player, message);
        }

        public void player_disconnected(int index)
        {
            round.set_disconnected(index);
        }

        ///////////////////////

        private void client_void_hand(ServerPlayer player, ClientMessage message)
        {
            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_void_hand(p.index);
        }

        private void client_tile_discard(ServerPlayer player, ClientMessage message)
        {
            ClientMessageTileDiscard tile = (ClientMessageTileDiscard)message;

            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_tile_discard(p.index, tile.tile_ID);
        }

        private void client_no_call(ServerPlayer player, ClientMessage message)
        {
            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_no_call(p.index);
        }

        private void client_ron(ServerPlayer player, ClientMessage message)
        {
            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_ron(p.index);
        }

        private void client_tsumo(ServerPlayer player, ClientMessage message)
        {
            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_tsumo(p.index);
        }

        private void client_riichi(ServerPlayer player, ClientMessage message)
        {
            ClientMessageRiichi riichi = (ClientMessageRiichi)message;

            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_riichi(p.index, riichi.open);
        }

        private void client_late_kan(ServerPlayer player, ClientMessage message)
        {
            ClientMessageLateKan kan = (ClientMessageLateKan)message;

            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_late_kan(p.index, kan.tile_ID);
        }

        private void client_closed_kan(ServerPlayer player, ClientMessage message)
        {
            ClientMessageClosedKan kan = (ClientMessageClosedKan)message;

            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_closed_kan(p.index, kan.tile_type);
        }

        private void client_open_kan(ServerPlayer player, ClientMessage message)
        {
            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_open_kan(p.index);
        }

        private void client_pon(ServerPlayer player, ClientMessage message)
        {
            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_pon(p.index);
        }

        private void client_chii(ServerPlayer player, ClientMessage message)
        {
            ClientMessageChii chii = (ClientMessageChii)message;

            GameRoundServerPlayer p = get_game_player(players, player);
            round.client_chii(p.index, chii.tile_1_ID, chii.tile_2_ID);
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

        private void game_reveal_tile(Tile tile)
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

        private static GameRoundServerPlayer? get_game_player(ArrayList<GameRoundServerPlayer> players, ServerPlayer player)
        {
            foreach (GameRoundServerPlayer p in players)
                if (p.server_player == player)
                    return p;
            return null;
        }

        private static GameRoundServerPlayer? get_server_player(ArrayList<GameRoundServerPlayer> players, int index)
        {
            return players[index];
        }

        private class GameRoundServerPlayer
        {
            public GameRoundServerPlayer(ServerPlayer sp, int index)
            {
                server_player = sp;
                this.index = index;
            }

            public ServerPlayer server_player { get; private set; }
            public int index { get; private set; }
        }
    }
}
