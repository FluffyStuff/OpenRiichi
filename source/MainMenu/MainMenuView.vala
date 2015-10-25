using Gee;
using GameServer;

class MainMenuView : View2D
{
    private ServerController? server = null;
    private IGameConnection connection;

    private OptionsMenuView options;

    private GameMenuButton host_game_button;
    private GameMenuButton join_game_button;
    private GameMenuButton start_game_button;
    private GameMenuButton options_button;
    private GameMenuButton back_button;
    private GameMenuButton quit_button;

    public signal void game_start(GameStartState state);
    public signal void quit();

    public MainMenuView()
    {
        // TODO: Fix class reflection bug...
        typeof(SerializableMessage).class_ref();
        typeof(ServerMessage).class_ref();
        typeof(ServerMessageRoundStart).class_ref();
    }

    ~MainMenuView()
    {
        host_game_button.clicked.disconnect(press_host);
        join_game_button.clicked.disconnect(press_join);
        start_game_button.clicked.disconnect(press_start);
        options_button.clicked.disconnect(press_options);
        back_button.clicked.disconnect(press_back);
        quit_button.clicked.disconnect(press_quit);
    }

    private void start_server()
    {
        for (int i = server.get_player_count(); i < 4; i++)
        {
            ServerComputerPlayer bot = new ServerComputerPlayer(new NullBot());
            server.add_player(bot);
        }
    }

    private void clear_all()
    {
        host_game_button.visible = false;
        join_game_button.visible = false;
        start_game_button.visible = false;
        options_button.visible = false;
        back_button.visible = false;
        quit_button.visible = false;
    }

    private void show_main_menu()
    {
        host_game_button.visible = true;
        join_game_button.visible = true;
        start_game_button.visible = false;
        options_button.visible = true;
        back_button.visible = false;
        quit_button.visible = true;
    }

    private void show_host_menu()
    {
        host_game_button.visible = false;
        join_game_button.visible = false;
        start_game_button.visible = true;
        options_button.visible = false;
        back_button.visible = true;
        quit_button.visible = false;
    }

    private void show_join_menu()
    {
        host_game_button.visible = false;
        join_game_button.visible = false;
        start_game_button.visible = false;
        options_button.visible = false;
        back_button.visible = true;
        quit_button.visible = false;
    }

    private void connection_created(IGameConnection connection, bool server)
    {
        this.connection = connection;
        this.connection.disconnected.connect(disconnected);
        this.connection.received_message.connect(received_message);

        if (server)
            show_host_menu();
        else
            show_join_menu();
    }

    private void connection_failed()
    {
        show_main_menu();
    }

    private void disconnected()
    {
        connection = null;

        show_main_menu();
    }

    private void press_host()
    {
        clear_all();

        Threading.start0(create_server);
    }

    private void press_join()
    {
        clear_all();

        Threading.start0(join_server);
    }

    private void press_start()
    {
        clear_all();

        Threading.start0(start_server);
    }

    private void press_options()
    {
        clear_all();

        options = new OptionsMenuView();
        options.apply_clicked.connect(options_apply);
        options.back_clicked.connect(options_back);
        add_child(options);
    }

    private void press_back()
    {
        server = null;
        connection = null;

        show_main_menu();
    }

    private void press_quit()
    {
        quit();
    }

    private void options_apply()
    {
        remove_child(options);

        show_main_menu();
    }

    private void options_back()
    {
        remove_child(options);
        show_main_menu();
    }

    public override void added()
    {
        host_game_button = new GameMenuButton(store, "Create");
        join_game_button = new GameMenuButton(store, "Join");
        start_game_button = new GameMenuButton(store, "Start");
        options_button = new GameMenuButton(store, "Options");
        back_button = new GameMenuButton(store, "Back");
        quit_button = new GameMenuButton(store, "Quit");

        ArrayList<GameMenuButton> buttons = new ArrayList<GameMenuButton>();

        buttons.add(host_game_button);
        buttons.add(join_game_button);
        buttons.add(start_game_button);
        buttons.add(options_button);
        buttons.add(back_button);
        buttons.add(quit_button);

        foreach (GameMenuButton button in buttons)
            add_control(button);

        int padding = 30;
        float height = host_game_button.size.y + padding;

        host_game_button.position = Vec2(0, height * 1.5f);
        join_game_button.position = Vec2(0, height * 0.5f);
        start_game_button.position = Vec2(0, height * 0.5f);
        options_button.position = Vec2(0, -height * 0.5f);
        back_button.position = Vec2(0, -height * 0.5f);
        quit_button.position = Vec2(0, -height * 1.5f);

        host_game_button.clicked.connect(press_host);
        join_game_button.clicked.connect(press_join);
        start_game_button.clicked.connect(press_start);
        options_button.clicked.connect(press_options);
        back_button.clicked.connect(press_back);
        quit_button.clicked.connect(press_quit);

        show_main_menu();
    }

    public override void do_render_2D(RenderState state, RenderScene2D scene)
    {
        state.back_color = Color.black();
    }

    private void received_message()
    {
        ServerMessage? message = connection.dequeue_message();

        if (message.get_type() != typeof(ServerMessageRoundStart))
            return;

        connection.received_message.disconnect(received_message);

        ServerMessageRoundStart start = (ServerMessageRoundStart)message;
        GamePlayer[] players = null;
        GameStartState state = new GameStartState(connection, players, start.player_ID, start.get_wind(), start.dealer, start.wall_index);

        game_start(state);
    }

    private void join_server()
    {
        Connection? connection = Networking.join("riichi.mahjong", 1337);

        if (connection == null)
            connection_failed();
        else
            connection_created(new GameNetworkConnection(connection), false);
    }

    private void create_server()
    {
        server = new ServerController();
        server.start_network(1337);

        ServerPlayerLocalConnection server_connection = new ServerPlayerLocalConnection();
        GameLocalConnection game_connection = new GameLocalConnection();

        server_connection.set_connection(game_connection);
        game_connection.set_connection(server_connection);

        ServerHumanPlayer player = new ServerHumanPlayer(server_connection);
        server.add_player(player);

        connection_created(game_connection, true);
    }
}
