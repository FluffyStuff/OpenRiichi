using Gee;

namespace GameServer
{
    class NullBot : Bot
    {
        private Rand rnd = new Rand();

        public NullBot()
        {
            base();
        }

        protected override void do_turn_decision()
        {
            action_delay();

            if (TileRules.can_late_kan(state.self.hand, state.self.calls))
            {
                ArrayList<Tile> tiles = TileRules.get_late_kan_tiles(state.self.hand, state.self.calls);
                do_late_kan(tiles[0]);
            }
            else if (TileRules.can_closed_kan(state.self.hand))
            {
                ArrayList<ArrayList<Tile>> groups = TileRules.get_closed_kan_groups(state.self.hand);
                do_closed_kan(groups[0][0].tile_type);
            }
            else
            {
                Tile tile = state.self.hand[rnd.int_range(0, state.self.hand.size)];
                discard_tile(tile);
            }
        }

        protected override void do_call_decision(ClientGameStatePlayer discarding_player, Tile tile)
        {
            /*if (TileRules.can_open_kan(state.self.hand, tile))
            {
                action_delay();
                call_open_kan();
            }
            else */if (TileRules.can_pon(state.self.hand, tile))
            {
                action_delay();
                call_pon();
            }
            /*else if (state.can_chi(tile, state.self, state.discard_player))
            {
                action_delay();

                ArrayList<ArrayList<Tile>> groups = TileRules.get_chi_groups(state.self.hand, tile);
                ArrayList<Tile> tiles = groups[0];

                call_chi(tiles[0], tiles[1]);
            }*/
            else
            {
                no_call();
            }
        }

        private void action_delay()
        {
            Thread.usleep(1 * 1000000);
        }
    }
}
