namespace GameServer
{
    class NullBot : Bot
    {
        public NullBot()
        {
            base();
        }

        protected override void do_turn_decision()
        {
            Thread.usleep(1 * 1000000);

            Tile tile = state.self.hand[0];
            discard_tile(tile);
        }

        protected override void do_call_decision(Bot.BotPlayer discarding_player, Tile tile)
        {
            if (TileRules.can_open_kan(state.self.hand, tile))
            {
                Thread.usleep(1 * 1000000);
                call_open_kan();
            }
            else if (TileRules.can_pon(state.self.hand, tile))
            {
                Thread.usleep(1 * 1000000);
                call_pon();
            }
            else
                no_call();
        }
    }
}
