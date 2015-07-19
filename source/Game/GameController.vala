public class GameController
{
    private GameState? game;
    private GameRenderView renderer;
    private GameMenuView menu;

    private IGameConnection connection;
    private unowned View parent_view;

    public signal void finished();

    public GameController(View parent_view, GameStartState game_start)
    {
        this.parent_view = parent_view;

        GameRenderView renderer = new GameRenderView(game_start);
        parent_view.add_child(renderer);
        this.renderer = renderer;

        menu = new GameMenuView();
        parent_view.add_child(menu);

        connection = game_start.connection;
        connection.disconnected.connect(disconnected);

        if (game_start.player_ID != -1)
        {
            create_game(game_start);

            renderer.tile_selected.connect(game.client_tile_selected);

            menu.chi_pressed.connect(game.client_chi);
            menu.pon_pressed.connect(game.client_pon);
            menu.kan_pressed.connect(game.client_kan);
            menu.riichi_pressed.connect(game.client_riichi);
            menu.tsumo_pressed.connect(game.client_tsumo);
            menu.ron_pressed.connect(game.client_ron);
            menu.continue_pressed.connect(game.client_continue);

            game.send_message.connect(connection.send_message);
            game.set_chi_state.connect(menu.set_chi);
            game.set_pon_state.connect(menu.set_pon);
            game.set_kan_state.connect(menu.set_kan);
            game.set_riichi_state.connect(menu.set_riichi);
            game.set_tsumo_state.connect(menu.set_tsumo);
            game.set_ron_state.connect(menu.set_ron);
            game.set_continue_state.connect(menu.set_continue);
            game.set_tile_select_state.connect(renderer.set_active);
            game.set_tile_select_groups.connect(renderer.set_tile_select_groups);
        }
    }

    ~GameController()
    {
        connection.disconnected.disconnect(disconnected);

        renderer.tile_selected.disconnect(game.client_tile_selected);

        menu.chi_pressed.disconnect(game.client_chi);
        menu.pon_pressed.disconnect(game.client_pon);
        menu.kan_pressed.disconnect(game.client_kan);
        menu.riichi_pressed.disconnect(game.client_riichi);
        menu.tsumo_pressed.disconnect(game.client_tsumo);
        menu.ron_pressed.disconnect(game.client_ron);
        menu.continue_pressed.disconnect(game.client_continue);

        game.send_message.disconnect(connection.send_message);
        game.set_chi_state.disconnect(menu.set_chi);
        game.set_pon_state.disconnect(menu.set_pon);
        game.set_kan_state.disconnect(menu.set_kan);
        game.set_riichi_state.disconnect(menu.set_riichi);
        game.set_tsumo_state.disconnect(menu.set_tsumo);
        game.set_ron_state.disconnect(menu.set_ron);
        game.set_continue_state.disconnect(menu.set_continue);
        game.set_tile_select_state.disconnect(renderer.set_active);
        game.set_tile_select_groups.disconnect(renderer.set_tile_select_groups);

        parent_view.remove_child(renderer);
        parent_view.remove_child(menu);
    }

    public void process()
    {
        ServerMessage message;
        while ((message = connection.dequeue_message()) != null)
        {
            renderer.receive_message(message);

            if (game != null)
                game.receive_message(message);
        }
    }

    private void create_game(GameStartState game_start)
    {
        game = new GameState(game_start);
    }

    private void disconnected()
    {
        finish_game();
    }

    private void finish_game()
    {
        finished();
    }
}
