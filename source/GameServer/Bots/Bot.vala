public abstract class Bot
{
    private bool active = false;
    protected BotGameState state;

    public Bot()
    {
    }

    public void start(int player_ID)
    {
        active = true;
        state = new BotGameState(player_ID);
        Threading.start0(logic);
    }

    private void logic()
    {
        while (active)
        {
            do_logic();
            poll();
            sleep();
        }
    }

    protected virtual void sleep()
    {
        Thread.usleep(100000);
    }

    /////////////

    public void tile_assign(Tile tile)
    {
        state.tile_assign(tile);
    }

    public void tile_draw(int player_ID, int tile_ID)
    {
        state.tile_draw(player_ID, tile_ID);
    }

    public void tile_discard(int player_ID, int tile_ID)
    {
        state.tile_discard(player_ID, tile_ID);
    }

    public void turn_decision()
    {
        do_turn_decision();
    }

    public void call_decision(int discarding_player, int tile_ID)
    {
        do_call_decision(discarding_player, tile_ID);
    }

    ////////////

    public signal void poll();

    public signal void discard_tile(Tile tile);
    public signal void no_call();

    protected abstract void do_turn_decision();
    protected abstract void do_call_decision(int discarding_player, int tile_ID);
    protected virtual void do_logic() {}

    protected class BotGameState
    {
        private Tile[] tiles = new Tile[136];
        private int player_ID;
        private BotPlayer[] players = new BotPlayer[4];

        public BotGameState(int player_ID)
        {
            this.player_ID = player_ID;

            for (int i = 0; i < players.length; i++)
                players[i] = new BotPlayer();

            for (int i = 0; i < tiles.length; i++)
                tiles[i] = new Tile(i, TileType.BLANK, false);
        }

        public void tile_assign(Tile tile)
        {
            Tile t = tiles[tile.ID];
            t.tile_type = tile.tile_type;
            t.dora = tile.dora;
        }

        public void tile_draw(int player_ID, int tile_ID)
        {
            if (player_ID == this.player_ID)
            players[player_ID].draw(tiles[tile_ID]);
        }

        public void tile_discard(int player_ID, int tile_ID)
        {
            print("Discard ID: %d This: %d\n", player_ID, this.player_ID);
            if (player_ID == this.player_ID)
            players[player_ID].discard(tiles[tile_ID]);
        }

        public BotPlayer self { get { return players[player_ID]; } }
    }

    protected class BotPlayer
    {
        private Gee.ArrayList<Tile> tiles = new Gee.ArrayList<Tile>();

        public BotPlayer()
        {

        }

        public void draw(Tile tile)
        {
            print("Drawing tile: %d\n", tile.ID);
            tiles.add(tile);
        }

        public void discard(Tile tile)
        {
            print("State discarding: %d\n", tile.ID);
            //print("Pre discard: %d\n", tiles.size);
            tiles.remove(tile);
            //print("Post discard: %d\n", tiles.size);
        }

        public Gee.ArrayList<Tile> hand { get { return tiles; } }
    }
}
