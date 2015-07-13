using Gee;

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

    public void call_decision(int discarding_player_ID, int tile_ID)
    {
        do_call_decision(state.get_player(discarding_player_ID), state.get_tile(tile_ID));
    }

    public void kan(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID, int tile_3_ID)
    {
        state.open_kan(player_ID, discarding_player_ID, tile_ID, tile_1_ID, tile_2_ID, tile_3_ID);
    }

    public void pon(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        state.pon(player_ID, discarding_player_ID, tile_ID, tile_1_ID, tile_2_ID);
    }

    public void chi(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        state.chi(player_ID, discarding_player_ID, tile_ID, tile_1_ID, tile_2_ID);
    }

    ////////////

    public signal void poll();

    public signal void discard_tile(Tile tile);
    public signal void no_call();
    public signal void call_ron();
    public signal void call_open_kan();
    public signal void call_pon();
    public signal void call_chi(Tile tile_1, Tile tile_2);

    protected abstract void do_turn_decision();
    protected abstract void do_call_decision(BotPlayer discarding_player, Tile tile);
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
            players[player_ID].draw(tiles[tile_ID]);
        }

        public void tile_discard(int player_ID, int tile_ID)
        {
            players[player_ID].discard(tiles[tile_ID]);
        }

        public void open_kan(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID, int tile_3_ID)
        {
            BotPlayer player = get_player(player_ID);
            BotPlayer discarder = get_player(discarding_player_ID);

            Tile tile = get_tile(tile_ID);
            Tile tile_1 = get_tile(tile_1_ID);
            Tile tile_2 = get_tile(tile_2_ID);
            Tile tile_3 = get_tile(tile_3_ID);

            discarder.rob_tile(tile);
            player.remove_tile(tile_1);
            player.remove_tile(tile_2);
            player.remove_tile(tile_3);

            // TODO: Create call
        }

        public void pon(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID)
        {
            BotPlayer player = get_player(player_ID);
            BotPlayer discarder = get_player(discarding_player_ID);

            Tile tile = get_tile(tile_ID);
            Tile tile_1 = get_tile(tile_1_ID);
            Tile tile_2 = get_tile(tile_2_ID);

            discarder.rob_tile(tile);
            player.remove_tile(tile_1);
            player.remove_tile(tile_2);

            // TODO: Create call
        }

        public void chi(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID)
        {
            BotPlayer player = get_player(player_ID);
            BotPlayer discarder = get_player(discarding_player_ID);

            Tile tile = get_tile(tile_ID);
            Tile tile_1 = get_tile(tile_1_ID);
            Tile tile_2 = get_tile(tile_2_ID);

            discarder.rob_tile(tile);
            player.remove_tile(tile_1);
            player.remove_tile(tile_2);

            // TODO: Create call
        }

        public BotPlayer get_player(int player_ID)
        {
            return players[player_ID];
        }

        public Tile get_tile(int tile_ID)
        {
            return tiles[tile_ID];
        }

        public BotPlayer self { get { return players[player_ID]; } }
    }

    public class BotPlayer
    {
        public BotPlayer()
        {
            hand = new ArrayList<Tile>();
            pond = new ArrayList<Tile>();
        }

        public void draw(Tile tile)
        {
            hand.add(tile);
        }

        public void discard(Tile tile)
        {
            hand.remove(tile);
            pond.add(tile);
        }

        public void remove_tile(Tile tile)
        {
            hand.remove(tile);
        }

        public void rob_tile(Tile tile)
        {
            pond.remove(tile);
        }

        public ArrayList<Tile> hand { get; private set; }
        public ArrayList<Tile> pond { get; private set; }
    }
}
