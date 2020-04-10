using Engine;
using Gee;

class MultiplayerMenuView : MenuSubView
{
    private GameController controller;

    public MultiplayerMenuView()
    {
        controller = null; // Fix include bug in vala
    }

    public signal GameController menu_game_start(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index);

    private void create_server_clicked()
    {
        CreateServerView view = new CreateServerView();
        view.finish.connect(create_server);
        load_sub_view(view);
    }

    private void join_server_clicked()
    {
        JoinMenuView view = new JoinMenuView();
        view.finish.connect(join_server);
        load_sub_view(view);
    }

    private void create_server(MenuSubView view)
    {
        CreateServerView v = (CreateServerView)view;
        ServerMenuView s = new ServerMenuView.create_server(v.player_name, true);
        s.start.connect(game_start);
        load_sub_view(s);
    }

    private void join_server(MenuSubView view)
    {
        JoinMenuView v = (JoinMenuView)view;
        ServerMenuView s = new ServerMenuView.join_server(v.connection, false);
        s.start.connect(game_start);
        load_sub_view(s);
    }

    private void lobby()
    {
        LobbyConnectionView view = new LobbyConnectionView();
        view.start_game.connect(game_start_controller);
        load_sub_view(view);
    }

    protected override ArrayList<MenuTextButton>? get_main_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        MenuTextButton create_button = new MenuTextButton("MenuButtonBig", "Create Server");
        create_button.clicked.connect(create_server_clicked);
        buttons.add(create_button);

        MenuTextButton join_button = new MenuTextButton("MenuButtonBig", "Join Server");
        join_button.clicked.connect(join_server_clicked);
        buttons.add(join_button);

        MenuTextButton lobby_button = new MenuTextButton("MenuButtonBig", "Online Lobby");
        lobby_button.clicked.connect(lobby);
        buttons.add(lobby_button);

        return buttons;
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

        return buttons;
    }

    private GameController game_start_controller(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index)
    {
        return menu_game_start(info, settings, connection, player_index);
    }

    private void game_start(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index)
    {
        menu_game_start(info, settings, connection, player_index);
    }

    protected override string get_name() { return "Multiplayer"; }
}
