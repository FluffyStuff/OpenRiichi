using Engine;
using Gee;
using GameServer;
using Lobby;

class LobbyConnectionView : MenuSubView
{
    private LabelControl message_label = new LabelControl();
    private MenuTextButton ok_button;
    private DelayTimer timer = new DelayTimer();
    private int delay_time = 5;

    private bool connecting_finished;
    private bool processed;
    private LobbyConnection? connection;

    public signal GameController start_game(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index);

    protected override void load()
    {
        message_label = new LabelControl();
        add_child(message_label);
        message_label.text = "Connecting to lobby...";
        message_label.font_size = 50;
        timer.set_time(delay_time);

        Threading.start2(try_join, new Obj<string>(Environment.LOBBY_ADDRESS), new Obj<int>(Environment.LOBBY_PORT));
    }

    private void try_join(Object host_obj, Object port_obj)
    {
        string host = ((Obj<string>)host_obj).obj;
        int port = ((Obj<int>)port_obj).obj;

        connection = LobbyConnection.create(host, port);
        connecting_finished = true;
    }

    protected override void process(DeltaArgs time)
    {
        if (processed)
            return;

        if (timer.active(time.time))
        {
            connecting_finished = true;
            processed = true;
            message_label.text = "Error: Could not connect to lobby";
            ok_button.visible = true;
            return;
        }

        if (!connecting_finished)
            return;

        if (connection == null || connection.is_disconnected)
        {
            processed = true;

            string text = "Error: ";
            if (connection != null && connection.version_mismatch)
                text += "Lobby version mismatch\n" + "Please get the latest version";
            else
                text += "Could not connect to lobby";
            message_label.text = text;
            ok_button.visible = true;
        }
        else if (connection.server_version != null)
        {
            processed = true;
            LobbySelectionView view = new LobbySelectionView(connection);
            view.start_game.connect(do_start_game);
            view.back.connect(do_back);
            load_sub_view(view);
        }
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        ok_button = new MenuTextButton("MenuButton", "OK");
        ok_button.clicked.connect(do_back);
        buttons.add(ok_button);

        return buttons;
    }

    protected override void load_finished()
    {
        ok_button.visible = false;
    }

    protected override void set_visibility(bool visible)
    {
        message_label.visible = visible;
    }

    private GameController do_start_game(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index)
    {
        return start_game(info, settings, connection, player_index);
    }

    protected override string get_name() { return "Online lobby"; }
}

class LobbySelectionView : MenuSubView
{
    private LobbyInformationListControl? lobby_info;
    private LobbyInformation? selected_lobby;
    private LobbyConnection connection;
    private TextInputControl name_text;
    private MenuTextButton join_button;
    private LobbyView lobby_view;

    private int padding = 80;

    public signal GameController start_game(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index);

    public LobbySelectionView(LobbyConnection connection)
    {
        this.connection = connection;
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        join_button = new MenuTextButton("MenuButton", "Enter Lobby");
        join_button.clicked.connect(enter_clicked);
        buttons.add(join_button);

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

        return buttons;
    }

    protected override void load_finished()
    {
        name_text = new TextInputControl("Player name", Environment.MAX_NAME_LENGTH);
        add_child(name_text);
        name_text.text_changed.connect(button_enable_check);
        name_text.outer_anchor = Vec2(0, 0);
        name_text.inner_anchor = Vec2(0, 0);
        name_text.position = Vec2(padding + 5, 2 * padding + join_button.size.height);

        lobby_info = new LobbyInformationListControl();
        add_child(lobby_info);
        lobby_info.resize_style = ResizeStyle.ABSOLUTE;
        lobby_info.inner_anchor = Vec2(0.5f, 1);
        lobby_info.outer_anchor = Vec2(0.5f, 1);
        lobby_info.position = Vec2(0, -120);
        lobby_info.selected_index_changed.connect(lobby_index_changed);

        connection.disconnected.connect(do_back);
        connection.lobby_enumeration_result.connect(lobby_enumeration_result);
        connection.enter_lobby_result.connect(enter_lobby_result);
        connection.get_lobby_information();

        button_enable_check();
    }

    protected override void resized()
    {
        lobby_info.size = Size2(size.width - 2 * padding, size.height - 450);
    }

    private void lobby_index_changed()
    {
        if (lobby_info.selected_index == -1)
            selected_lobby = null;
        else
            selected_lobby = connection.lobbies[lobby_info.selected_index];

        button_enable_check();
    }

    private void button_enable_check()
    {
        join_button.enabled = Environment.is_valid_name(name_text.text);
    }

    private void enter_clicked()
    {
        connection.authenticate(name_text.text);
        connection.enter_lobby(selected_lobby);
    }

    private void lobby_enumeration_result(LobbyConnection connection, bool success)
    {
        if (!success) // Should never happen, something bad must have happened
        {
            do_back();
            return;
        }

        lobby_info.set_lobbies(connection.lobbies);
    }

    private void enter_lobby_result(LobbyConnection connection, bool success)
    {
        if (!success) // Should never happen, something bad must have happened
        {
            do_back();
            return;
        }

        lobby_view = new LobbyView(this.connection);
        lobby_view.start_game.connect(do_start_game);
        lobby_view.back.connect(lobby_back);
        load_sub_view(lobby_view);
    }

    private GameController do_start_game(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index)
    {
        return start_game(info, settings, connection, player_index);
    }

    private void lobby_back()
    {
        connection.leave_lobby();
        connection.get_lobby_information();
    }

    protected override void set_visibility(bool visible)
    {
        lobby_info.visible = visible;
        name_text.visible = visible;
    }

    protected override string get_name() { return "Select Lobby"; }
}
