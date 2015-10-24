using Gee;

namespace GameServer
{
    class GameStateGame
    {
        public signal void game_draw_tile(int player_ID, Tile tile, bool dead_wall);
        public signal void game_discard_tile(int player_ID, Tile tile);
        public signal void game_flip_dora(Tile tile);
        public signal void game_flip_ura_dora(ArrayList<Tile> tiles);
        public signal void game_dead_tile_add(Tile tile);

        public signal void game_ron(int player_ID, ArrayList<Tile> hand, int discard_player_ID, Tile tile, Scoring score);
        public signal void game_tsumo(int player_ID, ArrayList<Tile> hand, Scoring score);
        public signal void game_riichi(int player_ID);
        public signal void game_late_kan(int player_ID, Tile tile);
        public signal void game_closed_kan(int player_ID, ArrayList<Tile> tiles);
        public signal void game_open_kan(int player_ID, int discard_player_ID, Tile tile, ArrayList<Tile> tiles);
        public signal void game_pon(int player_ID, int discard_player_ID, Tile tile, ArrayList<Tile> tiles);
        public signal void game_chii(int player_ID, int discard_player_ID, Tile tile, ArrayList<Tile> tiles);

        public signal void game_get_call_decision(int[] receivers, int player_ID, Tile tile);
        public signal void game_get_turn_decision(int player_ID);
        public signal void game_draw(ArrayList<GameStatePlayer> tenpai_players);

        private Tile? discard_tile = null;
        private GameState current_state = GameState.STARTING;
        private GameStateWall tiles;
        private GameStatePlayers players;
        private Wind round_wind;

        // Whether the standard game flow has been interrupted
        private bool flow_interrupted = false;

        public GameStateGame(Wind round_wind, int dealer, int wall_index, Rand rnd)
        {
            this.round_wind = round_wind;
            tiles = new GameStateWall(dealer, wall_index, rnd);
            players = new GameStatePlayers(dealer);
        }

        public void start()
        {
            initial_draw();
            flip_dora();
            next_turn();
        }

        public bool client_tile_discard(int player_ID, int tile_ID)
        {
            GameStatePlayer player = players.get_current_player();

            if (player.ID != player_ID)
                return false;
            if (current_state != GameState.WAITING_TURN)
            {
                print("tile_discard: Not players turn\n");
                return false;
            }

            Tile? tile = player.get_tile(tile_ID);

            if (tile == null)
            {
                print("tile_discard: Trying to discard tile not in hand\n");
                return false;
            }

            discard_tile = tile;

            if (!player.discard(tile))
            {
                print("tile_discard: Player can't discard selected tile");
                return false;
            }

            current_state = GameState.WAITING_CALLS;

            game_discard_tile(player_ID, tile);

            var call_players = players.get_call_players(player, create_context(true, tile));

            if (call_players.size == 0)
            {
                next_turn();
                return true;
            }

            players.clear_calls();

            int[] pl = new int[call_players.size];
            for (int i = 0; i < pl.length; i++)
            {
                GameStatePlayer p = call_players.get(i);
                p.state = GameStatePlayer.PlayerState.WAITING_CALL;
                pl[i] = p.ID;
                //print("Game now waiting on player %d call\n", p.ID);
            }

            game_get_call_decision(pl, player_ID, tile);

            return true;
        }

        public bool client_no_call(int player_ID)
        {
            GameStatePlayer player = players.get_player(player_ID);
            if (!check_can_call(player))
                return false;

            player.state = GameStatePlayer.PlayerState.DONE;
            check_calls_done();

            return true;
        }

        public void client_ron(int player_ID)
        {
            GameStatePlayer player = players.get_player(player_ID);
            if (!check_can_call(player))
                return;

            if (!player.can_ron(create_context(true, discard_tile)))
            {
                print("client_ron: Player trying to do invalid ron\n");
                return;
            }

            player.call_decision = new GameStateCallDecision(GameStateCallDecision.CallDecisionType.RON, null);
            player.state = GameStatePlayer.PlayerState.DONE;
            check_calls_done();
        }

        public void client_tsumo(int player_ID)
        {
            GameStatePlayer player = players.get_current_player();

            if (player.ID != player_ID)
                return;
            if (current_state != GameState.WAITING_TURN)
            {
                print("client_tsumo: Not players turn\n");
                return;
            }

            GameStateContext context = create_context(false, player.last_drawn_tile);
            if (!player.can_tsumo(context))
            {
                print("client_tsumo: Player trying to do invalid tsumo\n");
                return;
            }

            current_state = GameState.FINISHED;

            if (player.in_riichi)
                game_flip_ura_dora(tiles.ura_doras);
            game_tsumo(player.ID, player.hand, player.get_tsumo_score(context));
        }

        public void client_riichi(int player_ID)
        {
            GameStatePlayer player = players.get_current_player();

            if (player.ID != player_ID)
                return;
            if (current_state != GameState.WAITING_TURN)
            {
                print("client_riichi: Not players turn\n");
                return;
            }
            if (!player.can_riichi())
            {
                print("client_riichi: Player can't declare riichi\n");
                return;
            }

            player.do_riichi();
            player.state = GameStatePlayer.PlayerState.WAITING_RIICHI_DISCARD;

            game_riichi(player_ID);
        }

        // TODO: Riichi check
        public bool client_late_kan(int player_ID, int tile_ID)
        {
            GameStatePlayer player = players.get_current_player();

            if (player.ID != player_ID)
                return false;
            if (current_state != GameState.WAITING_TURN)
            {
                print("late_kan: Not players turn\n");
                return false;
            }

            Tile? tile = player.get_tile(tile_ID);

            if (tile == null)
            {
                print("late_kan: Trying to kan on invalid tile\n");
                return false;
            }

            if (!player.do_late_kan(tile))
            {
                print("late_kan: Player doesn't have pon type\n");
                return false;
            }

            game_late_kan(player_ID, tile);
            kan(player);
            game_get_turn_decision(player.ID);

            return true;
        }

        // TODO: Riichi check
        public bool client_closed_kan(int player_ID, TileType type)
        {
            GameStatePlayer player = players.get_current_player();

            if (player.ID != player_ID)
                return false;
            if (current_state != GameState.WAITING_TURN)
            {
                print("closed_kan: Not players turn\n");
                return false;
            }

            ArrayList<Tile>? tiles = player.do_closed_kan(type);

            if (tiles == null)
            {
                print("closed_kan: Player doesn't have kan type\n");
                return false;
            }

            game_closed_kan(player_ID, tiles);
            kan(player);
            game_get_turn_decision(player.ID);

            return true;
        }

        public void client_open_kan(int player_ID)
        {
            GameStatePlayer player = players.get_player(player_ID);
            if (!check_can_call(player))
                return;

            if (player.in_riichi)
            {
                print("client_open_kan: Player trying to do open kan while in riichi\n");
                return;
            }

            ArrayList<Tile>? kan = player.get_open_kan_tiles(discard_tile);
            if (kan == null)
            {
                print("client_open_kan: Player trying to do invalid open kan\n");
                return;
            }

            player.call_decision = new GameStateCallDecision(GameStateCallDecision.CallDecisionType.KAN, kan);
            player.state = GameStatePlayer.PlayerState.DONE;
            check_calls_done();
        }

        public void client_pon(int player_ID)
        {
            GameStatePlayer player = players.get_player(player_ID);
            if (!check_can_call(player))
                return;

            if (player.in_riichi)
            {
                print("client_pon: Player trying to do pon kan while in riichi\n");
                return;
            }

            ArrayList<Tile>? pon = player.get_pon_tiles(discard_tile);
            if (pon == null)
            {
                print("client_pon: Player trying to do invalid pon\n");
                return;
            }

            player.call_decision = new GameStateCallDecision(GameStateCallDecision.CallDecisionType.PON, pon);
            player.state = GameStatePlayer.PlayerState.DONE;
            check_calls_done();
        }

        public void client_chii(int player_ID, int tile_1_ID, int tile_2_ID)
        {
            GameStatePlayer player = players.get_player(player_ID);
            if (!check_can_call(player))
                return;

            if (player.in_riichi)
            {
                print("client_chii: Player trying to do chii while in riichi\n");
                return;
            }

            Tile tile_1 = player.get_tile(tile_1_ID);
            Tile tile_2 = player.get_tile(tile_2_ID);

            ArrayList<Tile> chii = new ArrayList<Tile>();
            chii.add(tile_1);
            chii.add(tile_2);

            if (!TileRules.can_chii(chii, discard_tile))
            {
                print("client_chii: Player %d trying to do invalid chii\n", player.ID);
                return;
            }

            player.call_decision = new GameStateCallDecision(GameStateCallDecision.CallDecisionType.CHII, chii);
            player.state = GameStatePlayer.PlayerState.DONE;
            check_calls_done();
        }

        /////////////////////

        private bool check_can_call(GameStatePlayer player)
        {
            if (current_state != GameState.WAITING_CALLS)
            {
                print("check_can_call: Not waiting for calls\n");
                return false;
            }

            if (player.state != GameStatePlayer.PlayerState.WAITING_CALL)
            {
                print("check_can_call: Player not waiting on calls\n");
                return false;
            }

            return true;
        }

        private void check_calls_done()
        {
            if (current_state != GameState.WAITING_CALLS)
            {
                print("check_calls_done: Not waiting for calls\n");
                return;
            }

            GameStatePlayer? player = null;
            GameStateCallDecision? decision = null;
            GameStateContext context = create_context(true, discard_tile);

            bool undecided = false;
            foreach (GameStatePlayer p in players.players)
            {
                if (p.state == GameStatePlayer.PlayerState.WAITING_CALL)
                {
                    undecided = true;
                    continue;
                }

                if (p.call_decision == null)
                    continue;

                if (p.call_decision.call_type == GameStateCallDecision.CallDecisionType.CHII && decision == null)
                {
                    player = p;
                    decision = p.call_decision;
                }
                else if (p.call_decision.call_type == GameStateCallDecision.CallDecisionType.PON || p.call_decision.call_type == GameStateCallDecision.CallDecisionType.KAN)
                {
                    player = p;
                    decision = p.call_decision;

                    bool can_ron = false;
                    foreach (GameStatePlayer pl in players.players)
                    {
                        if (pl.state == GameStatePlayer.PlayerState.WAITING_CALL && pl.can_ron(context))
                        {
                            can_ron = true;
                            break;
                        }
                    }

                    if (!can_ron)
                    {
                        undecided = false;
                        break;
                    }
                }
                else if (p.call_decision.call_type == GameStateCallDecision.CallDecisionType.RON)
                {
                    player = p;
                    decision = p.call_decision;
                    undecided = false;
                    break;
                }
            }

            if (undecided)
                return;

            if (decision == null)
            {
                next_turn();
                return;
            }

            GameStatePlayer discarder = players.get_current_player();

            if (decision.call_type == GameStateCallDecision.CallDecisionType.CHII)
            {
                player.do_chii(discard_tile, decision.tiles);
                game_chii(player.ID, discarder.ID, discard_tile, decision.tiles);
            }
            else if (decision.call_type == GameStateCallDecision.CallDecisionType.PON)
            {
                player.do_pon(discard_tile, decision.tiles);
                game_pon(player.ID, discarder.ID, discard_tile, decision.tiles);
            }
            else if (decision.call_type == GameStateCallDecision.CallDecisionType.KAN)
            {
                player.do_open_kan(discard_tile, decision.tiles);
                game_open_kan(player.ID, discarder.ID, discard_tile, decision.tiles);

                kan(player);
            }
            else if (decision.call_type == GameStateCallDecision.CallDecisionType.RON)
            {
                // Game over
                current_state = GameState.FINISHED;
                if (player.in_riichi)
                    game_flip_ura_dora(tiles.ura_doras);
                game_ron(player.ID, player.hand, discarder.ID, discard_tile, player.get_ron_score(context));
                return;
            }

            flow_interrupted = true;
            players.set_current_player(player);
            current_state = GameState.WAITING_TURN;
            game_get_turn_decision(player.ID);
        }

        private void kan(GameStatePlayer player)
        {
            flip_dora();
            Tile tile = tiles.dead_tile_add();
            game_dead_tile_add(tile);

            tile = tiles.draw_dead_wall();
            player.draw(tile);
            game_draw_tile(player.ID, tile, true);
        }

        private void next_turn()
        {
            // Game over
            if (tiles.empty)
            {
                game_end();
                return;
            }

            discard_tile = null;
            players.next_player();
            GameStatePlayer player = players.get_current_player();
            Tile tile = tiles.draw_wall();
            player.draw(tile);
            current_state = GameState.WAITING_TURN;
            game_draw_tile(player.ID, tile, false);
            game_get_turn_decision(player.ID);
        }

        private void game_end()
        {
            ArrayList<GameStatePlayer> tenpai_players = players.get_tenpai_players();

            game_draw(tenpai_players);

            /*int[] pl = new int[tenpai_players.size];
            for (int i = 0; i < pl.length; i++)
                pl[i] = tenpai_players[i].ID;

            game_draw(pl);*/
        }

        private void flip_dora()
        {
            Tile tile = tiles.flip_dora();
            game_flip_dora(tile);
        }

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
                        game_draw_tile(player.ID, tile, false);
                    }

                    players.next_player();
                }
            }

            for (int p = 0; p < 4; p++)
            {
                GameStatePlayer player = players.get_current_player();
                Tile tile = tiles.draw_wall();
                player.draw(tile);
                game_draw_tile(player.ID, tile, false);

                if (p < 3)
                    players.next_player();
            }
        }

        private GameStateContext create_context(bool ron, Tile win_tile)
        {
            bool last_tile = tiles.empty;
            bool rinshan = false;
            bool chankan = false;

            return new GameStateContext
            (
                round_wind,
                tiles.doras,
                tiles.ura_doras,
                ron,
                win_tile,
                last_tile,
                rinshan,
                chankan,
                flow_interrupted
            );
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
