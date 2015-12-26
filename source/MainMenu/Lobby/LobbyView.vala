using Gee;
using GameServer;

public class LobbyView : View2D
{
    private ClientLobby lobby;
    private LobbyConnection connection;
    private ClientLobbyGame? selected_game;
    private LabelControl lobby_label;
    private LobbyGameListControl game_list;
    private LobbyUserListControl user_list;
    private MenuTextButton enter_button;
    private MenuTextButton create_button;
    private MenuTextButton back_button;
    private ServerMenuView server_menu;
    private bool do_refresh_game_list = false;
    private bool do_refresh_user_list = false;
    private bool do_enter_game = false;
    private bool do_create_game = false;
    private int padding = 80;

    public signal void start_game(GameStartInfo info, IGameConnection connection, int player_index);
    public signal void back();

    public LobbyView(LobbyConnection connection)
    {
        this.connection = connection;
        lobby = connection.current_lobby;
        connection.enter_game_result.connect(enter_game_result);
        connection.create_game_result.connect(create_game_result);
        lobby.game_added.connect(refresh_game_list);
        lobby.game_removed.connect(refresh_game_list);
        lobby.user_added.connect(refresh_user_list);
        lobby.user_removed.connect(refresh_user_list);
        lobby.user_entered_game.connect(refresh_game_list);
        lobby.user_left_game.connect(refresh_game_list);
    }

    protected override void added()
    {
        lobby_label = new LabelControl();
        add_child(lobby_label);
        lobby_label.text = lobby.name;
        lobby_label.font_size = 40;
        lobby_label.outer_anchor = Vec2(0.5f, 1);
        lobby_label.inner_anchor = Vec2(0.5f, 1);
        lobby_label.position = Vec2(0, -60);

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

        enter_button = new MenuTextButton("MenuButton", "Enter Game");
        add_child(enter_button);
        enter_button.outer_anchor = Vec2(0, 0);
        enter_button.inner_anchor = Vec2(0, 0);
        enter_button.position = Vec2(padding, padding);
        enter_button.clicked.connect(enter_clicked);
        enter_button.enabled = false;

        create_button = new MenuTextButton("MenuButton", "Create Game");
        add_child(create_button);
        create_button.outer_anchor = Vec2(0.5f, 0);
        create_button.inner_anchor = Vec2(0.5f, 0);
        create_button.position = Vec2(0, padding);
        create_button.clicked.connect(create_clicked);

        back_button = new MenuTextButton("MenuButton", "Back");
        add_child(back_button);
        back_button.outer_anchor = Vec2(1, 0);
        back_button.inner_anchor = Vec2(1, 0);
        back_button.position = Vec2(-padding, padding);
        back_button.clicked.connect(back_clicked);

        resized();
    }

    protected override void do_process(DeltaArgs args)
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
            add_child(server_menu);
            server_menu.start.connect(do_start_game);
            server_menu.back.connect(game_back);
            server_menu.received_message();

            lobby_label.visible = false;
            game_list.visible = false;
            user_list.visible = false;
            enter_button.visible = false;
            create_button.visible = false;
            back_button.visible = false;

            do_create_game = false;
            do_enter_game = false;
        }
    }

    protected override void resized()
    {
        game_list.size = Size2(size.width - 3 * padding - user_list.size.width, size.height - 2 * padding - back_button.size.height + game_list.position.y);
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

    private void enter_game_result(LobbyConnection connection, bool success)
    {
        if (!success) // Should never happen, something bad must have happened
        {
            back();
            return;
        }

        do_enter_game = true;
    }

    private void create_game_result(LobbyConnection connection, bool success)
    {
        if (!success) // Should never happen, something bad must have happened
        {
            back();
            return;
        }

        do_create_game = true;
    }

    private void do_start_game(GameStartInfo info, IGameConnection connection, int player_index)
    {
        remove_child(server_menu);
        start_game(info, connection, player_index);
    }

    private void game_back()
    {
        remove_child(server_menu);
        server_menu = null;
        connection.leave_game();

        lobby_label.visible = true;
        game_list.visible = true;
        user_list.visible = true;
        enter_button.visible = true;
        create_button.visible = true;
        back_button.visible = true;
    }

    private void enter_clicked()
    {
        connection.enter_game(selected_game);
    }

    private void create_clicked()
    {
        connection.create_game();
    }

    private void back_clicked()
    {
        back();
    }
}
