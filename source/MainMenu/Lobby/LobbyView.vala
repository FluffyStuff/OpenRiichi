using Engine;
using Gee;
using GameServer;

class LobbyView : MenuSubView
{
    private ClientLobby lobby;
    private LobbyConnection connection;
    private ClientLobbyGame? selected_game;
    private LobbyGameListControl game_list;
    private LobbyUserListControl user_list;
    private MenuTextButton enter_button;
    private ServerMenuView server_menu;
    private int current_game_ID = -1;
    private bool do_refresh_game_list = false;
    private bool do_refresh_user_list = false;
    private bool do_enter_game = false;
    private bool do_create_game = false;
    private int padding = 80;

    public signal GameController start_game(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index);

    public LobbyView(LobbyConnection connection)
    {
        this.connection = connection;
        lobby = connection.current_lobby;
        connection.enter_game_result.connect(enter_game_result);
        connection.create_game_result.connect(create_game_result);
        lobby.game_removed.connect(game_removed);
        lobby.game_added.connect(refresh_game_list);
        lobby.game_removed.connect(refresh_game_list);
        lobby.user_added.connect(refresh_user_list);
        lobby.user_removed.connect(refresh_user_list);
        lobby.user_entered_game.connect(refresh_game_list);
        lobby.user_left_game.connect(refresh_game_list);
    }

    protected override void load()
    {
        user_list = new LobbyUserListControl();
        add_child(user_list);
        user_list.resize_style = ResizeStyle.ABSOLUTE;
        user_list.inner_anchor = Vec2(0, 1);
        user_list.outer_anchor = Vec2(1, 1);
        user_list.size = Size2(250, 0);
        user_list.position = Vec2(-user_list.size.width - padding, -120);
        user_list.set_users(lobby.users.to_array());

        game_list = new LobbyGameListControl();
        add_child(game_list);
        game_list.resize_style = ResizeStyle.ABSOLUTE;
        game_list.inner_anchor = Vec2(1, 1);
        game_list.outer_anchor = Vec2(1, 1);
        game_list.position = Vec2(-2 * padding - user_list.size.width, -120);
        game_list.set_games(lobby.games.to_array());
        game_list.selected_index_changed.connect(game_index_changed);
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        enter_button = new MenuTextButton("MenuButton", "Enter Game");
        enter_button.clicked.connect(enter_clicked);
        buttons.add(enter_button);

        MenuTextButton create_button = new MenuTextButton("MenuButton", "Create Game");
        create_button.clicked.connect(create_clicked);
        buttons.add(create_button);

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

        return buttons;
    }

    protected override void load_finished()
    {
        enter_button.enabled = false;
    }

    protected override void process(DeltaArgs args)
    {
        if (do_refresh_game_list)
        {
            do_refresh_game_list = false;
            game_list.set_games(lobby.games.to_array());
        }

        if (do_refresh_user_list)
        {
            do_refresh_user_list = false;
            user_list.set_users(lobby.users.to_array());
        }

        if (do_create_game || do_enter_game)
        {
            server_menu = new ServerMenuView.join_server(connection.tunneled_connection, do_create_game);
            server_menu.start.connect(do_start_game);
            server_menu.back.connect(game_back);
            load_sub_view(server_menu);

            game_list.visible = false;
            user_list.visible = false;

            do_create_game = false;
            do_enter_game = false;
        }
    }

    protected override void resized()
    {
        game_list.size = Size2(size.width - 3 * padding - user_list.size.width, size.height - 2 * padding - enter_button.size.height + game_list.position.y);
        user_list.size = Size2(user_list.size.width, game_list.size.height);
    }

    private void game_index_changed()
    {
        if (game_list.selected_index == -1)
        {
            enter_button.enabled = false;
            selected_game = null;
            return;
        }

        selected_game = lobby.games[game_list.selected_index];
        enter_button.enabled = true;
    }

    private void refresh_game_list()
    {
        do_refresh_game_list = true;
    }

    private void refresh_user_list()
    {
        do_refresh_user_list = true;
    }

    private void enter_game_result(LobbyConnection connection, bool success, int game_ID)
    {
        if (success)
        {
            current_game_ID = game_ID;
            do_enter_game = true;
        }
    }

    private void create_game_result(LobbyConnection connection, bool success, int game_ID)
    {
        if (success)
        {
            current_game_ID = game_ID;
            do_create_game = true;
        }
    }

    private void game_removed(ClientLobby lobby, ClientLobbyGame game, bool started)
    {
        if (!started && game.ID == current_game_ID)
            return_to_lobby();
    }

    private void do_start_game(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index)
    {
        GameController controller = start_game(info, settings, connection, player_index);
        controller.finished.connect(return_to_lobby);
    }

    private void game_back()
    {
        connection.leave_game();
        return_to_lobby();
    }

    private void return_to_lobby()
    {
        server_menu.do_finish();
        current_game_ID = -1;
    }

    private void enter_clicked()
    {
        connection.enter_game(selected_game);
    }

    private void create_clicked()
    {
        connection.create_game();
    }

    protected override void set_visibility(bool visible)
    {
        game_list.visible = visible;
        user_list.visible = visible;
    }

    protected override string get_name() { return lobby.name; }
}
