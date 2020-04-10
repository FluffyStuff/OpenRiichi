using Engine;
using Gee;
using GameServer;

class ServerMenuView : MenuSubView
{
    private ServerController? server = null;
    private IGameConnection? connection = null;
    private Mutex mutex = Mutex();
    private string player_name;
    private bool host = false;
    private bool listen = false;
    private bool can_control = false;
    private GameLog? log;
    private ServerSettings settings = new ServerSettings.from_disk();

    private ServerSettingsView settings_view;
    private ServerPlayerFieldView[] players = new ServerPlayerFieldView[4];
    private MenuTextButton? start_button;
    private MenuTextButton settings_button;

    public signal void start(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index);

    public ServerMenuView.create_server(string player_name, bool listen)
    {
        host = true;
        this.player_name = player_name;
        this.listen = listen;
        can_control = true;
    }

    public ServerMenuView.join_server(IGameConnection? connection, bool can_control)
    {
        this.connection = connection;
        this.connection.disconnected.connect(do_back);
        this.can_control = can_control;
    }

    public ServerMenuView.use_log(GameLog log)
    {
        host = true;
        player_name = "Log";
        this.log = log;
    }

    private void start_server()
    {
        server = new ServerController();

        ServerPlayerLocalConnection server_connection = new ServerPlayerLocalConnection();
        GameLocalConnection game_connection = new GameLocalConnection();

        server_connection.set_connection(game_connection);
        game_connection.set_connection(server_connection);

        connection = game_connection;

        ServerHumanPlayer player = new ServerHumanPlayer(server_connection, player_name);
        server.add_player(player);

        if (listen)
            server.start_listening(Environment.GAME_PORT);
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        settings_button = new MenuTextButton("MenuButton", "Settings");
        settings_button.clicked.connect(settings_clicked);
        buttons.add(settings_button);

        if (can_control || log != null)
        {
            start_button = new MenuTextButton("MenuButton", "Start");
            start_button.clicked.connect(start_clicked);
            buttons.add(start_button);
        }

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(back_clicked);
        buttons.add(back_button);

        return buttons;
    }

    protected override void load_finished()
    {
        int padding = 60;

        for (int i = players.length - 1; i >= 0; i--)
        {
            ServerPlayerFieldView player = new ServerPlayerFieldView(can_control, i);
            add_child(player);
            player.size = Size2(300, 40);
            player.position = Vec2(0, -(i - 1.5f) * padding);
            player.kick.connect(kick_slot);
            player.add_bot.connect(add_bot);
            players[i] = player;
        }

        settings_button.enabled = false; // Disable until we receive the settings from the server
        if (start_button != null)
            start_button.enabled = false;

        if (host)
            start_server();
        if (can_control)
            send_settings(settings);
        if (log != null)
            send_log(log);
    }

    private void kick_slot(int slot)
    {
        connection.send_message(new ClientMessageMenuKickPlayer(slot));
    }

    private void add_bot(string name, int slot)
    {
        connection.send_message(new ClientMessageMenuAddBot(name, slot));
    }

    private void start_clicked()
    {
        connection.send_message(new ClientMessageMenuGameStart());
    }

    private void settings_clicked()
    {
        if (settings == null)
            return;

        settings_view = new ServerSettingsView(can_control, can_control, settings);
        settings_view.finish.connect(apply_server_settings);
        load_sub_view(settings_view);
    }

    private void back_clicked()
    {
        if (host && server != null)
            server.kill();
        do_back();
    }

    private void apply_server_settings()
    {
        send_settings(settings_view.settings);
    }

    private void send_settings(ServerSettings settings)
    {
        connection.send_message(new ClientMessageMenuSettings(settings));
    }

    private void send_log(GameLog? log)
    {
        connection.send_message(new ClientMessageMenuGameLog(log));
    }

    protected override void set_visibility(bool visible)
    {
        for (int i = 0; i < players.length; i++)
            players[i].visible = visible;
    }

    protected override void process(DeltaArgs delta)
    {
        if (connection == null)
            return;

        mutex.lock();
        ServerMessage? message;

        while ((message = connection.dequeue_message()) != null)
        {
            if (message is ServerMessageGameStart)
            {
                start_message(message as ServerMessageGameStart);
                connection = null;
                break;
            }
            else if (message is ServerMessageMenuSlotAssign)
                assign_message(message as ServerMessageMenuSlotAssign);
            else if (message is ServerMessageMenuSlotClear)
                clear_message(message as ServerMessageMenuSlotClear);
            else if (message is ServerMessageMenuSettings)
                settings_message(message as ServerMessageMenuSettings);
            else if (message is ServerMessageMenuGameLog)
                game_log_message(message as ServerMessageMenuGameLog);
        }
        mutex.unlock();
    }

    private void start_message(ServerMessageGameStart message)
    {
        connection.disconnected.disconnect(do_back);
        start(message.info, message.settings, connection, message.player_index);
        do_back();
    }

    private void assign_message(ServerMessageMenuSlotAssign message)
    {
        players[message.slot].assign(message.name);
        check_can_start();
    }

    private void clear_message(ServerMessageMenuSlotClear message)
    {
        players[message.slot].unassign();
        check_can_start();
    }

    private void settings_message(ServerMessageMenuSettings message)
    {
        settings = message.settings;
        settings_button.enabled = true;
    }

    private void game_log_message(ServerMessageMenuGameLog message)
    {
        // TODO: name
        start_button.enabled = true;
    }

    private void check_can_start()
    {
        if (!can_control)
            return;

        for (int i = 0; i < players.length; i++)
        {
            if (!players[i].assigned)
            {
                start_button.enabled = false;
                return;
            }
        }

        start_button.enabled = true;
    }

    protected override string get_name() { return "Server"; }
}
