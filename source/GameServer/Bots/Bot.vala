using Gee;

public abstract class Bot : Object
{
    private bool active = false;
    protected ClientGameState state;

    private Mutex mutex = new Mutex();

    public Bot()
    {
    }

    public void start(int player_ID)
    {
        active = true;
        state = new ClientGameState(player_ID);
        Threading.start0(logic);
    }

    public void stop()
    {
        mutex.lock();
        active = false;
        mutex.unlock();
    }

    private void logic()
    {
        ref();

        while (true)
        {
            mutex.lock();
            if (!active)
                break;

            do_logic();
            poll();

            if (!active)
                break;
            mutex.unlock();

            sleep();
        }

        mutex.unlock();

        unref();
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

    public void late_kan(int player_ID, int tile_ID)
    {
        state.late_kan(player_ID, tile_ID);
    }

    public void closed_kan(int player_ID, TileType type)
    {
        state.closed_kan(player_ID, type);
    }

    public void open_kan(int player_ID, int discarding_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID, int tile_3_ID)
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
    public signal void do_late_kan(Tile tile);
    public signal void do_closed_kan(TileType type);
    public signal void no_call();
    public signal void call_ron();
    public signal void call_open_kan();
    public signal void call_pon();
    public signal void call_chi(Tile tile_1, Tile tile_2);

    protected abstract void do_turn_decision();
    protected abstract void do_call_decision(ClientGameStatePlayer discarding_player, Tile tile);
    protected virtual void do_logic() {}
}
