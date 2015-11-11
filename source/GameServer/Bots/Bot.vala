using Gee;

public abstract class Bot : Object
{
    private bool active = false;
    private Mutex mutex = Mutex();
    private int player_index;

    protected GameState game_state;
    protected ClientRoundState? round_state;

    public void init_game(GameStartInfo info, int player_index)
    {
        game_state = new GameState(info);
        this.player_index = player_index;
        active = true;
        Threading.start0(logic);
    }

    public void start_round(bool use_lock, RoundStartInfo info)
    {
        if (use_lock)
            mutex.lock();

        game_state.start_round(info);
        round_state = new ClientRoundState(player_index, game_state.round_wind, game_state.dealer_index);

        if (use_lock)
            mutex.unlock();
    }

    public void stop(bool use_lock)
    {
        if (use_lock)
            mutex.lock();

        active = false;
        round_state = null;

        if (use_lock)
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

            poll();

            if (round_state != null)
                do_logic();

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
        round_state.tile_assign(tile);
    }

    public void tile_draw(int player_index, int tile_ID)
    {
        round_state.tile_draw(player_index, tile_ID);
    }

    public void tile_discard(int player_index, int tile_ID)
    {
        round_state.tile_discard(player_index, tile_ID);
    }

    public void ron(int player_index, int discarding_player_index, int tile_ID)
    {
        ClientRoundStatePlayer player = round_state.get_player(player_index);
        Tile tile = round_state.get_tile(tile_ID);

        Scoring score = round_state.get_ron_score(player, tile);
        RoundFinishResult result = new RoundFinishResult.ron(score, player_index, discarding_player_index);
        game_state.round_finished(result);
    }

    public void tsumo(int player_index)
    {
        ClientRoundStatePlayer player = round_state.get_player(player_index);

        Scoring score = round_state.get_tsumo_score(player);
        RoundFinishResult result = new RoundFinishResult.tsumo(score, player_index);
        game_state.round_finished(result);
    }

    public void riichi(int player_index)
    {
        round_state.riichi(player_index);
    }

    public void turn_decision()
    {
        do_turn_decision();
    }

    public void call_decision(int discarding_player_index, int tile_ID)
    {
        do_call_decision(round_state.get_player(discarding_player_index), round_state.get_tile(tile_ID));
    }

    public void late_kan(int player_index, int tile_ID)
    {
        round_state.late_kan(player_index, tile_ID);
    }

    public void closed_kan(int player_index, TileType type)
    {
        round_state.closed_kan(player_index, type);
    }

    public void open_kan(int player_index, int discarding_player_index, int tile_ID, int tile_1_ID, int tile_2_ID, int tile_3_ID)
    {
        round_state.open_kan(player_index, discarding_player_index, tile_ID, tile_1_ID, tile_2_ID, tile_3_ID);
    }

    public void pon(int player_index, int discarding_player_index, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        round_state.pon(player_index, discarding_player_index, tile_ID, tile_1_ID, tile_2_ID);
    }

    public void chii(int player_index, int discarding_player_index, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        round_state.chii(player_index, discarding_player_index, tile_ID, tile_1_ID, tile_2_ID);
    }

    public void draw(int[] tenpai_indices)
    {
        RoundFinishResult result = new RoundFinishResult.draw(tenpai_indices);
        game_state.round_finished(result);
    }

    ////////////

    public signal void poll();

    public signal void do_discard(Tile tile);
    public signal void do_tsumo();
    public signal void do_riichi();
    public signal void do_late_kan(Tile tile);
    public signal void do_closed_kan(TileType type);
    public signal void call_nothing();
    public signal void call_ron();
    public signal void call_open_kan();
    public signal void call_pon();
    public signal void call_chii(Tile tile_1, Tile tile_2);

    protected abstract void do_turn_decision();
    protected abstract void do_call_decision(ClientRoundStatePlayer discarding_player, Tile tile);
    protected virtual void do_logic() {}
    public abstract string name { get; }
}
