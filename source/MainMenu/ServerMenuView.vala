using GameServer;

public class ServerMenuView : View2D
{
    private ServerController? server = null;
    private IGameConnection? connection = null;
    private string name;
    private bool host = false;

    private ServerPlayerFieldView[] players = new ServerPlayerFieldView[4];
    private GameMenuButton start_button;

    public signal void start(GameStartInfo info, IGameConnection connection, int player_index);
    public signal void back();

    public ServerMenuView.create_server(string name)
    {
        host = true;
        this.name = name;
    }

    public ServerMenuView.join_server(IGameConnection? connection)
    {
        this.connection = connection;
        this.connection.disconnected.connect(disconnected);
        this.connection.received_message.connect(received_message);
    }

    ~ServerMenuView()
    {
        connection = null; // Fixes warnings because of reasons
    }

    private void start_server()
    {
        server = new ServerController();

        ServerPlayerLocalConnection server_connection = new ServerPlayerLocalConnection();
        GameLocalConnection game_connection = new GameLocalConnection();

        server_connection.set_connection(game_connection);
        game_connection.set_connection(server_connection);

        connection = game_connection;
        connection.disconnected.connect(disconnected);
        connection.received_message.connect(received_message);

        ServerHumanPlayer player = new ServerHumanPlayer(server_connection, name);
        server.add_player(player);

        server.start_listening(1337);
    }

    protected override void added()
    {
        LabelControl label = new LabelControl(store);
        label.text = "Server";
        label.font_size = 40;
        label.outer_anchor = Vec2(0.5f, 1);
        label.inner_anchor = Vec2(0.5f, 1);
        add_control(label);

        int padding = 50;

        if (host)
        {
            start_button = new GameMenuButton(store, "Start");
            start_button.outer_anchor = Vec2(0.5f, 0);
            start_button.inner_anchor = Vec2(1, 0);
            start_button.position = Vec2(-padding, padding);
            start_button.clicked.connect(start_clicked);
            start_button.enabled = false;
            add_control(start_button);
        }

        GameMenuButton back_button = new GameMenuButton(store, "Back");
        back_button.outer_anchor = Vec2(0.5f, 0);
        back_button.inner_anchor = Vec2(0, 0);
        back_button.position = Vec2(padding, padding);
        back_button.clicked.connect(back_clicked);
        add_control(back_button);

        for (int i = 3; i >= 0; i--)
        {
            ServerPlayerFieldView player = new ServerPlayerFieldView(store, host, i);
            player.set_size(Size2(300, 40));
            player.position = Vec2(0, -(i - 1.5f) * 60);
            player.kick.connect(kick_slot);
            player.add_bot.connect(add_bot);
            add_control(player);
            players[i] = player;
        }

        if (host)
            start_server();
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

    private void back_clicked()
    {
        if (host && server != null)
            server.kill();
        back();
    }

    private void disconnected()
    {
        back();
    }

    private void received_message()
    {
        ServerMessage? message = connection.dequeue_message();

        if (message is ServerMessageGameStart)
            start_message(message as ServerMessageGameStart);
        else if (message is ServerMessageMenuSlotAssign)
            assign_message(message as ServerMessageMenuSlotAssign);
        else if (message is ServerMessageMenuSlotClear)
            clear_message(message as ServerMessageMenuSlotClear);
    }

    private void start_message(ServerMessageGameStart message)
    {
        connection.received_message.disconnect(received_message);
        start(message.info, connection, message.player_index);
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

    private void check_can_start()
    {
        if (!host)
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
}
