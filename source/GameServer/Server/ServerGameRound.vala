using Gee;

namespace GameServer
{
    class ServerGameRound : Object // Signal receiver needs to be object
    {
        private ArrayList<GameStateServerPlayer> players = new ArrayList<GameStateServerPlayer>();
        private GameStateGame game;
        private ClientMessageParser parser = new ClientMessageParser();

        public bool finished { get; private set; }
        public ServerPlayer winner { get; private set; }
        public ServerPlayer loser { get; private set; }
        public Scoring score { get; private set; }
        public bool[] in_tenpai { get; private set; }

        public ServerGameRound(ArrayList<ServerPlayer> players, ArrayList<ServerPlayer> spectators, int[] player_seats, Wind round_wind, int dealer)
        {
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

            Rand rnd = new Rand();

            for (int i = 0; i < players.size; i++)
            {
                GameStateServerPlayer player = new GameStateServerPlayer(players[player_seats[i]], i);
                this.players.add(player);
            }

            foreach (ServerPlayer player in spectators)
            {
                GameStateServerPlayer p = new GameStateServerPlayer(player, -1);
                this.players.add(p);
            }

            int wall_index = rnd.int_range(1, 7) + rnd.int_range(1, 7);

            game = new GameStateGame(round_wind, dealer, wall_index, rnd);
            game.game_draw_tile.connect(game_draw_tile);
            game.game_discard_tile.connect(game_discard_tile);
            game.game_flip_dora.connect(game_flip_dora);
            game.game_flip_ura_dora.connect(game_flip_ura_dora);
            game.game_dead_tile_add.connect(game_dead_tile_add);
            game.game_get_turn_decision.connect(game_get_turn_decision);
            game.game_get_call_decision.connect(game_get_call_decision);
            game.game_ron.connect(game_ron);
            game.game_tsumo.connect(game_tsumo);
            game.game_riichi.connect(game_riichi);
            game.game_late_kan.connect(game_late_kan);
            game.game_closed_kan.connect(game_closed_kan);
            game.game_open_kan.connect(game_open_kan);
            game.game_pon.connect(game_pon);
            game.game_chii.connect(game_chii);
            game.game_draw.connect(game_draw);

            for (int i = 0; i < this.players.size; i++)
            {
                ServerMessageRoundStart start_message = new ServerMessageRoundStart(this.players[i].ID, round_wind, dealer, wall_index);
                this.players[i].server_player.send_message(start_message);
            }

            game.start();
        }

        public void process(float time)
        {
            parser.execute_all();
        }

        public void message_received(ServerPlayer player, ClientMessage message)
        {
            parser.add(player, message);
        }

        private void finish_round()
        {
            finished = true;
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

        private void client_tsumo(ServerPlayer player, ClientMessage message)
        {
            GameStateServerPlayer p = get_game_player(players, player);
            game.client_tsumo(p.ID);
        }

        private void client_riichi(ServerPlayer player, ClientMessage message)
        {
            GameStateServerPlayer p = get_game_player(players, player);
            game.client_riichi(p.ID);
        }

        private void client_late_kan(ServerPlayer player, ClientMessage message)
        {
            ClientMessageLateKan kan = (ClientMessageLateKan)message;

            GameStateServerPlayer p = get_game_player(players, player);
            game.client_late_kan(p.ID, kan.tile_ID);
        }

        private void client_closed_kan(ServerPlayer player, ClientMessage message)
        {
            ClientMessageClosedKan kan = (ClientMessageClosedKan)message;

            GameStateServerPlayer p = get_game_player(players, player);
            game.client_closed_kan(p.ID, kan.get_type_enum());
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

        private void client_chii(ServerPlayer player, ClientMessage message)
        {
            ClientMessageChii chii = (ClientMessageChii)message;

            GameStateServerPlayer p = get_game_player(players, player);
            game.client_chii(p.ID, chii.tile_1_ID, chii.tile_2_ID);
        }

        ////////////////////////

        private void game_draw_tile(int player_ID, Tile tile, bool dead_wall)
        {
            GameStateServerPlayer player = get_server_player(players, player_ID);
            ServerMessageTileAssignment assignment = new ServerMessageTileAssignment(tile.ID, (int)tile.tile_type, tile.dora);
            ServerMessageTileDraw draw = new ServerMessageTileDraw(player.ID, tile.ID, dead_wall);

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

        private void game_flip_ura_dora(ArrayList<Tile> tiles)
        {
            foreach (Tile tile in tiles)
            {
                game_reveal_tile(tile);
                ServerMessageFlipUraDora message = new ServerMessageFlipUraDora(tile.ID);

                foreach (GameStateServerPlayer pl in players)
                    pl.server_player.send_message(message);
            }
        }

        private void game_dead_tile_add(Tile tile)
        {
            ServerMessageDeadTileAdd message = new ServerMessageDeadTileAdd(tile.ID);

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

        private void game_ron(int player_ID, ArrayList<Tile> hand, int discard_player_ID, Tile tile, Scoring score)
        {
            foreach (Tile t in hand)
                game_reveal_tile(t);

            ServerMessageRon message = new ServerMessageRon(player_ID, discard_player_ID, tile.ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);

            winner = players[player_ID].server_player;
            loser = players[discard_player_ID].server_player;
            this.score = score;

            finish_round();
        }

        private void game_tsumo(int player_ID, ArrayList<Tile> hand, Scoring score)
        {
            foreach (Tile t in hand)
                game_reveal_tile(t);

            ServerMessageTsumo message = new ServerMessageTsumo(player_ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);

            winner = players[player_ID].server_player;
            loser = null;
            this.score = score;

            finish_round();
        }

        private void game_riichi(int player_ID)
        {
            ServerMessageRiichi message = new ServerMessageRiichi(player_ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_late_kan(int player_ID, Tile tile)
        {
            game_reveal_tile(tile);
            ServerMessageLateKan message = new ServerMessageLateKan(player_ID, tile.ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_closed_kan(int player_ID, ArrayList<Tile> tiles)
        {
            foreach (Tile t in tiles)
                game_reveal_tile(t);

            ServerMessageClosedKan message = new ServerMessageClosedKan(player_ID, tiles[0].tile_type);

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

        public void game_chii(int player_ID, int discard_player_ID, Tile tile, ArrayList<Tile> tiles)
        {
            foreach (Tile t in tiles)
                game_reveal_tile(t);

            ServerMessageChii message = new ServerMessageChii(player_ID, discard_player_ID, tile.ID, tiles[0].ID, tiles[1].ID);

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);
        }

        public void game_draw(ArrayList<GameStatePlayer> tenpai_players)
        {
            in_tenpai = new bool[players.size];

            foreach (GameStatePlayer player in tenpai_players)
            {
                foreach (Tile t in player.hand)
                    game_reveal_tile(t);

                ServerMessageTenpaiPlayer m = new ServerMessageTenpaiPlayer(player.ID);

                foreach (GameStateServerPlayer pl in players)
                    pl.server_player.send_message(m);

                in_tenpai[player.ID] = true;
            }

            ServerMessageDraw message = new ServerMessageDraw();

            foreach (GameStateServerPlayer pl in players)
                pl.server_player.send_message(message);

            finish_round();
        }

        //////////////////////

        private static GameStateServerPlayer? get_game_player(ArrayList<GameStateServerPlayer> players, ServerPlayer player)
        {
            foreach (GameStateServerPlayer p in players)
                if (p.server_player == player)
                    return p;
            return null;
        }

        private static GameStateServerPlayer? get_server_player(ArrayList<GameStateServerPlayer> players, int ID)
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
