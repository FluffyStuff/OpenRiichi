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
            //print("Null computer doing turn decision...\n");
            Thread.usleep(1 * 1000000);

            Tile tile = state.self.hand.get(0);
            discard_tile(tile);

            //print("Discarding tile: %d\n", tile.ID);
        }

        protected override void do_call_decision(int discarding_player, int tile_ID)
        {
            no_call();
        }
    }
}
