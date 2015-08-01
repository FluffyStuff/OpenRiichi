public class GameController
{
    private GameState? game;
    private GameRenderView? renderer = null;
    private GameMenuView? menu = null;

    private IGameConnection connection;
    private unowned View parent_view;

    private bool game_finished = false;
    public signal void finished();

    public GameController(View parent_view, GameStartState game_start)
    {
        this.parent_view = parent_view;

        connection = game_start.connection;
        connection.disconnected.connect(disconnected);

        create_game(game_start);
    }

    ~GameController()
    {
        connection.close();

        parent_view.remove_child(renderer);
        parent_view.remove_child(menu);
    }

    public void process()
    {
        if (game_finished == true)
        {
            finished();
            return;
        }

        ServerMessage? message = null;
        while ((message = connection.dequeue_message()) != null)
        {
            if (renderer != null)
                renderer.receive_message(message);
            if (game != null)
                game.receive_message(message);

            if (message.get_type() == typeof(ServerMessageRoundStart))
            {
                ServerMessageRoundStart start = (ServerMessageRoundStart)message;
                GamePlayer[] players = null;
                GameStartState state = new GameStartState(connection, players, start.player_ID, start.get_wind(), start.dealer, start.wall_index);

                create_game(state);
            }
        }
    }

    private void create_game_state(GameStartState game_start)
    {
        game = new GameState(game_start);
        game.send_message.connect(connection.send_message);
        game.set_chii_state.connect(menu.set_chii);
        game.set_pon_state.connect(menu.set_pon);
        game.set_kan_state.connect(menu.set_kan);
        game.set_riichi_state.connect(menu.set_riichi);
        game.set_tsumo_state.connect(menu.set_tsumo);
        game.set_ron_state.connect(menu.set_ron);
        game.set_continue_state.connect(menu.set_continue);
        game.display_score.connect(menu.display_score);
        game.set_tile_select_state.connect(renderer.set_active);
        game.set_tile_select_groups.connect(renderer.set_tile_select_groups);

        renderer.tile_selected.connect(game.client_tile_selected);

        menu.chii_pressed.connect(game.client_chii);
        menu.pon_pressed.connect(game.client_pon);
        menu.kan_pressed.connect(game.client_kan);
        menu.riichi_pressed.connect(game.client_riichi);
        menu.tsumo_pressed.connect(game.client_tsumo);
        menu.ron_pressed.connect(game.client_ron);
        menu.continue_pressed.connect(game.client_continue);
    }

    private void create_game(GameStartState game_start)
    {
        if (renderer != null)
            parent_view.remove_child(renderer);
        if (menu != null)
            parent_view.remove_child(menu);

        menu = new GameMenuView();
        menu.quit.connect(finish_game);

        if (game != null)
        {
            menu.chii_pressed.disconnect(game.client_chii);
            menu.pon_pressed.disconnect(game.client_pon);
            menu.kan_pressed.disconnect(game.client_kan);
            menu.riichi_pressed.disconnect(game.client_riichi);
            menu.tsumo_pressed.disconnect(game.client_tsumo);
            menu.ron_pressed.disconnect(game.client_ron);
            menu.continue_pressed.disconnect(game.client_continue);
        }

        renderer = new GameRenderView(game_start);
        parent_view.add_child(renderer);
        parent_view.add_child(menu);

        if (game_start.player_ID != -1)
            create_game_state(game_start);
    }

    private void disconnected()
    {
        finish_game();
    }

    private void finish_game()
    {
        game_finished = true;
    }
}
