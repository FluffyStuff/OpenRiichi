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

        protected override void do_call_decision(int discarding_player, int tile_ID)
        {
            no_call();
        }
    }
}
