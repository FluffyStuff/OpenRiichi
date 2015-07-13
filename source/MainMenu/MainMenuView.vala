using GameServer;

Networking menu_net;
class MainMenuView : View
{
    private ServerController? server = null;
    private IGameConnection connection;

    public signal void game_start(GameStartState state);
    public signal void quit();

    public MainMenuView()
    {
        // TODO: Fix class reflection bug...
        typeof(SerializableMessage).class_ref();
        typeof(ServerMessage).class_ref();
        typeof(ServerMessageGameStart).class_ref();

        connection = create_server();
        //connection = join_server();
        connection.received_message.connect(received_message);

        Threading.start0(start);
    }

    private void start()
    {
        Thread.usleep(1 * 1000000);
        //create_server();
        server.start_game();
    }

    public override void added()
    {

    }

    public override void do_process(DeltaArgs delta)
    {

    }

    public override void do_render(RenderState state)
    {

    }

    private void received_message()
    {
        ServerMessage? message = connection.dequeue_message();

        if (message.get_type() != typeof(ServerMessageGameStart))
            return;

        connection.received_message.disconnect(received_message);

        ServerMessageGameStart start = (ServerMessageGameStart)message;
        GamePlayer[] players = null;
        GameStartState state = new GameStartState(connection, players, start.player_ID, start.dealer, start.wall_index, server);

        game_start(state);
    }

    private IGameConnection join_server()
    {
        menu_net = new Networking();
        Connection connection = menu_net.join("server.fluffy.is", 1337);
        GameNetworkConnection game_connection = new GameNetworkConnection(connection);

        return game_connection;
    }

    private IGameConnection create_server()
    {
        server = new ServerController();
        server.listen(1337);

        ServerPlayerLocalConnection server_connection = new ServerPlayerLocalConnection();
        GameLocalConnection game_connection = new GameLocalConnection();

        server_connection.set_connection(game_connection);
        game_connection.set_connection(server_connection);

        ServerHumanPlayer player = new ServerHumanPlayer(server_connection);
        ServerComputerPlayer c1 = new ServerComputerPlayer(new NullBot());
        ServerComputerPlayer c2 = new ServerComputerPlayer(new NullBot());
        ServerComputerPlayer c3 = new ServerComputerPlayer(new NullBot());

        server.add_player(player);
        server.add_player(c1);
        server.add_player(c2);
        server.add_player(c3);

        return game_connection;
    }
}
