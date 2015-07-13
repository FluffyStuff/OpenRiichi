using Gee;

namespace GameServer
{
    class Server
    {
        private GameStateServerPlayer[] players;
        private GameStateGame game;
        private ClientMessageParser parser = new ClientMessageParser();

        private Mutex mutex = new Mutex();

        public Server()
        {

        }

        public void create_game(ServerPlayer[] players)
        {
            parser.connect(client_tile_discard, typeof(ClientMessageTileDiscard));
            parser.connect(client_no_call, typeof(ClientMessageNoCall));
            parser.connect(client_ron, typeof(ClientMessageRon));
            parser.connect(client_open_kan, typeof(ClientMessageOpenKan));
            parser.connect(client_pon, typeof(ClientMessagePon));
            parser.connect(client_chi, typeof(ClientMessageChi));

            Rand rnd = new Rand();

            if (players != null)
                foreach (GameStateServerPlayer p in this.players)
                    unsubscribe_player(p.server_player);

            this.players = new GameStateServerPlayer[players.length];

            for (int i = 0; i < players.length; i++)
            {
                GameStateServerPlayer player = new GameStateServerPlayer(players[i], i);
                subscribe_player(player.server_player);
                this.players[i] = player;
            }

            int dealer = rnd.int_range(0, 4);
            int wall_index = rnd.int_range(2, 13);

            game = new GameStateGame(dealer, wall_index, rnd);
            game.game_draw_tile.connect(game_draw_tile);
            game.game_discard_tile.connect(game_discard_tile);
            game.game_flip_dora.connect(game_flip_dora);
            game.game_get_turn_decision.connect(game_get_turn_decision);
            game.game_get_call_decision.connect(game_get_call_decision);
            game.game_ron.connect(game_ron);
            game.game_open_kan.connect(game_open_kan);
            game.game_pon.connect(game_pon);
            game.game_chi.connect(game_chi);

            for (int i = 0; i < this.players.length; i++)
            {
                ServerMessageGameStart start_message = new ServerMessageGameStart(this.players[i].ID, dealer, wall_index);
                this.players[i].server_player.send_message(start_message);
            }

            game.start();
        }

        private void subscribe_player(ServerPlayer player)
        {
            player.receive_message.connect(receive_message);
            player.disconnected.connect(disconnected);
        }

        private void unsubscribe_player(ServerPlayer player)
        {
            player.receive_message.disconnect(receive_message);
            player.disconnected.disconnect(disconnected);
        }

        private void disconnected(ServerPlayer player)
        {
            print("Player disconnected...\n");
        }

        private void receive_message(ServerPlayer player, ClientMessage message)
        {
            mutex.lock();
            parser.execute(player, message);
            mutex.unlock();
        }

        ///////////////////////

        private void client_tile_discard(ServerPlayer player, ClientMessage message)
        {
            ClientMessageTileDiscard tile = (ClientMessageTileDiscard)message;

            GameStateServerPlayer p = get_game_player(players, player);
            game.client_tile_discard(p.ID, tile.tile_ID);
        }

        private void client_no_call(ServerPlayer player, ClientMessage message)
        {
            GameStateServerPlayer p = get_game_player(players, player);
            game.client_no_call(p.ID);
        }

        private void client_ron(ServerPlayer player, ClientMessage message)
        {
            GameStateServerPlayer p = get_game_player(players, player);
            game.client_ron(p.ID);
        }

        private void client_open_kan(ServerPlayer player, ClientMessage message)
        {
            GameStateServerPlayer p = get_game_player(players, player);
            game.client_open_kan(p.ID);
        }

        private void client_pon(ServerPlayer player, ClientMessage message)
        {
            GameStateServerPlayer p = get_game_player(players, player);
            game.client_pon(p.ID);
        }

        private void client_chi(ServerPlayer player, ClientMessage message)
        {
            ClientMessageChi chi = (ClientMessageChi)message;

            GameStateServerPlayer p = get_game_player(players, player);
            game.client_chi(p.ID, chi.tile_1_ID, chi.tile_2_ID);
        }

        ////////////////////////

        private void game_draw_tile(int player_ID, Tile tile)
        {
            GameStateServerPlayer player = get_server_player(players, player_ID);
            ServerMessageTileAssignment assignment = new ServerMessageTileAssignment(tile.ID, (int)tile.tile_type, tile.dora);
            ServerMessageTileDraw draw = new ServerMessageTileDraw(player.ID, tile.ID);

            foreach (GameStateServerPlayer p in players)
            {
                if (p == player || p.server_player.state != ServerPlayer.State.PLAYER)
                    p.server_player.send_message(assignment);

                p.server_player.send_message(draw);
            }
        }

        private void game_reveal_tile(Tile tile)
        {
            ServerMessageTileAssignment assignment = new ServerMessageTileAssignment(tile.ID, (int)tile.tile_type, tile.dora);

            foreach (GameStateServerPlayer p in players)
                p.server_player.send_message(assignment);
        }

        private void game_discard_tile(int player_ID, Tile tile)
        {
            game_reveal_tile(tile);
            ServerMessageTileDiscard message = new ServerMessageTileDiscard(player_ID, tile.ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        private void game_flip_dora(Tile tile)
        {
            game_reveal_tile(tile);
            ServerMessageFlipDora message = new ServerMessageFlipDora(tile.ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        private void game_get_turn_decision(int player_ID)
        {
            ServerMessageTurnDecision message = new ServerMessageTurnDecision();
            get_server_player(players, player_ID).server_player.send_message(message);
        }

        private void game_get_call_decision(int[] receivers, int player_ID, Tile tile)
        {
            ServerMessageCallDecision message = new ServerMessageCallDecision(player_ID, tile.ID);

            foreach (int ID in receivers)
                get_server_player(players, ID).server_player.send_message(message);
        }

        private void game_ron(int player_ID, int discard_player_ID, Tile tile)
        {
            ServerMessageRon message = new ServerMessageRon(player_ID, discard_player_ID, tile.ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_open_kan(int player_ID, int discard_player_ID, Tile tile, ArrayList<Tile> tiles)
        {
            foreach (Tile t in tiles)
                game_reveal_tile(t);

            ServerMessageOpenKan message = new ServerMessageOpenKan(player_ID, discard_player_ID, tile.ID, tiles[0].ID, tiles[1].ID, tiles[2].ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_pon(int player_ID, int discard_player_ID, Tile tile, ArrayList<Tile> tiles)
        {
            foreach (Tile t in tiles)
                game_reveal_tile(t);

            ServerMessagePon message = new ServerMessagePon(player_ID, discard_player_ID, tile.ID, tiles[0].ID, tiles[1].ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_chi(int player_ID, int discard_player_ID, Tile tile, ArrayList<Tile> tiles)
        {
            foreach (Tile t in tiles)
                game_reveal_tile(t);

            ServerMessageChi message = new ServerMessageChi(player_ID, discard_player_ID, tile.ID, tiles[0].ID, tiles[1].ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        //////////////////////

        private static GameStateServerPlayer? get_game_player(GameStateServerPlayer[] players, ServerPlayer player)
        {
            foreach (GameStateServerPlayer p in players)
                if (p.server_player == player)
                    return p;
            return null;
        }

        private static GameStateServerPlayer? get_server_player(GameStateServerPlayer[] players, int ID)
        {
            foreach (GameStateServerPlayer p in players)
                if (p.ID == ID)
                    return p;
            return null;
        }

        private class GameStateServerPlayer
        {
            public GameStateServerPlayer(ServerPlayer sp, int ID)
            {
                server_player = sp;
                this.ID = ID;
            }

            public ServerPlayer server_player { get; private set; }
            public int ID { get; private set; }
        }
    }
}
