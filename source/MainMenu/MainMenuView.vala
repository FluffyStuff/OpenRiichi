using Gee;
using GameServer;

class MainMenuView : View2D
{
    private MainMenuBackgroundView background_view = new MainMenuBackgroundView();
    private ServerMenuView server_view;
    private ServerOptionsView server_options_view;
    private JoinMenuView join_view;
    private OptionsMenuView options_view;

    private MenuTextButton host_game_button;
    private MenuTextButton join_game_button;
    private MenuTextButton options_button;
    private MenuTextButton quit_button;

    public signal void game_start(GameStartInfo info, IGameConnection connection, int player_index);
    public signal void restart();
    public signal void quit();

    ~MainMenuView()
    {
        host_game_button.clicked.disconnect(press_host);
        join_game_button.clicked.disconnect(press_join);
        options_button.clicked.disconnect(press_options);
        quit_button.clicked.disconnect(press_quit);
    }

    private void clear_all()
    {
        host_game_button.visible = false;
        join_game_button.visible = false;
        options_button.visible = false;
        quit_button.visible = false;
        //background_view.visible = false;
    }

    private void show_main_menu()
    {
        host_game_button.visible = true;
        join_game_button.visible = true;
        options_button.visible = true;
        quit_button.visible = true;
        background_view.visible = true;
    }

    private void press_host()
    {
        clear_all();

        server_options_view = new ServerOptionsView();
        server_options_view.finished.connect(server_options_finished);
        server_options_view.back.connect(server_options_back);
        add_child(server_options_view);
    }

    private void press_join()
    {
        clear_all();

        join_view = new JoinMenuView();
        join_view.joined.connect(joined_server);
        join_view.back.connect(join_back);
        add_child(join_view);
    }

    private void press_options()
    {
        clear_all();
        //background_view.visible = false;

        options_view = new OptionsMenuView();
        options_view.apply_clicked.connect(options_apply);
        options_view.back_clicked.connect(options_back);
        add_child(options_view);
    }

    private void press_quit()
    {
        quit();
    }

    private void server_back()
    {
        remove_child(server_view);
        server_view = null;
        show_main_menu();
    }

    private void server_options_back()
    {
        remove_child(server_options_view);
        server_options_view = null;
        show_main_menu();
    }

    private void join_back()
    {
        remove_child(join_view);
        join_view = null;
        show_main_menu();
    }

    private void options_apply()
    {
        remove_child(options_view);

        //show_main_menu();
        restart();
    }

    private void options_back()
    {
        remove_child(options_view);
        options_view = null;
        show_main_menu();
    }

    private void server_options_finished(string name)
    {
        remove_child(server_options_view);
        server_options_view = null;

        server_view = new ServerMenuView.create_server(name);
        server_view.start.connect(menu_game_start);
        server_view.back.connect(server_back);
        add_child(server_view);
    }

    private void joined_server(IGameConnection connection, string name)
    {
        remove_child(join_view);
        join_view = null;

        server_view = new ServerMenuView.join_server(connection);
        server_view.start.connect(menu_game_start);
        server_view.back.connect(server_back);
        add_child(server_view);
    }

    private void menu_game_start(GameStartInfo info, IGameConnection connection, int player_index)
    {
        game_start(info, connection, player_index);
    }

    public override void added()
    {
        add_child(background_view);

        host_game_button = new MenuTextButton("MenuButton", "Create Server");
        join_game_button = new MenuTextButton("MenuButton", "Join Server");
        options_button = new MenuTextButton("MenuButton", "Options");
        quit_button = new MenuTextButton("MenuButton", "Quit");

        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        buttons.add(host_game_button);
        buttons.add(join_game_button);
        buttons.add(options_button);
        buttons.add(quit_button);

        foreach (MenuTextButton button in buttons)
            add_child(button);

        int padding = 30;
        float height = host_game_button.size.height + padding;

        host_game_button.position = Vec2(0, height * 1.5f);
        join_game_button.position = Vec2(0, height * 0.5f);
        options_button.position = Vec2(0, -height * 0.5f);
        quit_button.position = Vec2(0, -height * 1.5f);

        host_game_button.clicked.connect(press_host);
        join_game_button.clicked.connect(press_join);
        options_button.clicked.connect(press_options);
        quit_button.clicked.connect(press_quit);

        show_main_menu();
    }
}
