using Gee;
using GameServer;

class MainMenuView : View
{
    private ServerController? server = null;
    private IGameConnection connection;

    private ArrayList<GameMenuButton> buttons = new ArrayList<GameMenuButton>();
    private GameMenuButton? mouse_down_button;

    private GameMenuButton host_game_button;
    private GameMenuButton join_game_button;
    private GameMenuButton start_game_button;
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
        back_button.visible = false;
        quit_button.visible = false;
    }

    private void show_main_menu()
    {
        host_game_button.visible = true;
        join_game_button.visible = true;
        start_game_button.visible = false;
        back_button.visible = false;
        quit_button.visible = true;
    }

    private void show_host_menu()
    {
        host_game_button.visible = false;
        join_game_button.visible = false;
        start_game_button.visible = true;
        back_button.visible = true;
        quit_button.visible = false;
    }

    private void show_join_menu()
    {
        host_game_button.visible = false;
        join_game_button.visible = false;
        start_game_button.visible = false;
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

    public override void added()
    {
        host_game_button = new GameMenuButton(store, "Create");
        join_game_button = new GameMenuButton(store, "Join");
        start_game_button = new GameMenuButton(store, "Start");
        back_button = new GameMenuButton(store, "Back");
        quit_button = new GameMenuButton(store, "Quit");

        host_game_button.position = { 0, join_game_button.size.y / 2 + host_game_button.size.y };
        join_game_button.position = { 0, 0 };
        start_game_button.position = { 0, start_game_button.size.y / 4 * 3 };
        back_button.position = { 0, -back_button.size.y / 4 * 3 };
        quit_button.position = { 0, -join_game_button.size.y / 2 - quit_button.size.y };

        host_game_button.clicked.connect(press_host);
        join_game_button.clicked.connect(press_join);
        start_game_button.clicked.connect(press_start);
        back_button.clicked.connect(press_back);
        quit_button.clicked.connect(press_quit);

        buttons.add(host_game_button);
        buttons.add(join_game_button);
        buttons.add(start_game_button);
        buttons.add(back_button);
        buttons.add(quit_button);

        foreach (GameMenuButton button in buttons)
            button.enabled = true;

        show_main_menu();
    }

    public override void do_process(DeltaArgs delta)
    {

    }

    public override void do_render(RenderState state)
    {
        state.back_color = { 0, 0, 0 };
        RenderScene2D scene = new RenderScene2D(state.screen_width, state.screen_height);

        foreach (GameMenuButton button in buttons)
            button.render(scene, { state.screen_width, state.screen_height });

        state.add_scene(scene);
    }

    protected override void do_mouse_move(MouseMoveArgs mouse)
    {
        Vec2 pos = Vec2() { x = mouse.pos_x, y = mouse.pos_y };

        GameMenuButton? button = null;
        if (!mouse.handled)
            button = get_hover_button(pos);

        foreach (GameMenuButton b in buttons)
        {
            if ((b.hovering = (b == button)))
            {
                mouse.cursor_type = CursorType.HOVER;
                mouse.handled = true;
            }
        }
    }

    protected override void do_mouse_event(MouseEventArgs mouse)
    {
        if (mouse.button == MouseEventArgs.Button.LEFT)
        {
            if (mouse.handled)
            {
                mouse_down_button = null;
                return;
            }

            GameMenuButton? button = get_hover_button({mouse.pos_x, mouse.pos_y});

            if (mouse.down)
                mouse_down_button = button;
            else
            {
                if (button != null && button == mouse_down_button)
                    button.click();

                mouse_down_button = null;
            }
        }
    }

    private GameMenuButton? get_hover_button(Vec2 position)
    {
        foreach (GameMenuButton button in buttons)
            if (button.hover_check(position))
                return button;

        return null;
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
