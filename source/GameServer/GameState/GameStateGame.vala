namespace GameServer
{
    class GameStateGame
    {
        public signal void game_draw_tile(int player_ID, Tile tile);
        public signal void game_discard_tile(int player_ID, Tile tile);

        public signal void game_get_call_decision(int[] receivers, int player_ID, Tile tile);
        public signal void game_get_turn_decision(int player_ID);

        private GameState current_state = GameState.STARTING;
        private GameStateWall tiles = new GameStateWall();
        private GameStatePlayers players = new GameStatePlayers();

        // Whether the standard game flow has been interrupted
        private bool flow_interrupted = false;

        public GameStateGame()
        {
        }

        public void start()
        {
            initial_draw();
        }

        public bool tile_discard(int player_ID, int tile_ID)
        {
            GameStatePlayer player = players.get_current_player();

            if (player.ID != player_ID)
                return false;
            if (current_state != GameState.WAITING_TURN)
            {
                print("Not players turn...\n");
                return false;
            }

            Tile? tile = player.get_tile(tile_ID);

            if (tile == null)
            {
                print("Trying to discard invalid tile...\n");
                return false;
            }

            player.discard(tile);
            current_state = GameState.WAITING_CALLS;

            game_discard_tile(player_ID, tile);

            var call_players = players.get_call_players(player, tile);

            if (call_players.size == 0)
            {
                next_turn();
                return true;
            }

            int[] pl = new int[call_players.size];
            for (int i = 0; i < pl.length; i++)
                pl[i] = call_players.get(i).ID;

            game_get_call_decision(pl, player_ID, tile);

            return true;
        }

        private void next_turn()
        {
            players.next_player();
            GameStatePlayer player = players.get_current_player();
            Tile tile = tiles.draw_wall();
            player.draw(tile);
            current_state = GameState.WAITING_TURN;
            game_draw_tile(player.ID, tile);
            game_get_turn_decision(player.ID);
        }

        /*public bool player_turn_decision(GameStatePlayer player, GameStateTurnDecision decision)
        {
            if (current_state != GameState.WAITING_TURN)
                return false;

            if (!players.turn_decision(player, decision))
                return false;

            if (decision.DecisionType == GameStateTurnDecision.TurnDecision.TSUMO)
                current_state = GameState.FINISHED;
            else if (decision.DecisionType == GameStateTurnDecision.TurnDecision.DISCARD)
            {
                if (players.can_call(decision.Tile))
                {
                    current_state = GameState.WAITING_CALLS;
                    players.wait_calls(decision.Tile);
                }
                else
                    players.next_player();
            }

            return true;
        }

        public bool player_call_decision(GameStatePlayer player, GameStateCallDecision decision)
        {
            if (current_state != GameState.WAITING_CALLS)
                return false;

            if (!players.call_decision(player, decision))
                return false;

            if (decision.DecisionType == GameStateCallDecision.CallDecision.RON)
                current_state = GameState.FINISHED;
            else if (decision.DecisionType != GameStateCallDecision.CallDecision.NONE)
                flow_interrupted = true;

            return true;
        }*/

        private void initial_draw()
        {
            // Start initial wall drawing
            for (int i = 0; i < 3; i++)
            {
                for (int p = 0; p < 4; p++)
                {
                    GameStatePlayer player = players.get_current_player();

                    for (int t = 0; t < 4; t++)
                    {
                        Tile tile = tiles.draw_wall();
                        player.draw(tile);
                        game_draw_tile(player.ID, tile);
                    }

                    players.next_player();
                }
            }

            for (int p = 0; p < 4; p++)
            {
                GameStatePlayer player = players.get_current_player();
                Tile tile = tiles.draw_wall();
                player.draw(tile);
                game_draw_tile(player.ID, tile);

                if (p < 3)
                    players.next_player();
            }

            next_turn();
        }

        private enum GameState
        {
            STARTING,
            WAITING_CALLS,
            WAITING_TURN,
            FINISHED
        }
    }
}
