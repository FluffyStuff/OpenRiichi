using GameServer;

class MainMenuView : View
{
    private ServerController server;
    private IGameConnection connection;

    public signal void game_start(GameStartState state);
    public signal void quit();

    public MainMenuView()
    {
        connection = create_server();
        connection.received_message.connect(received_message);

        Threading.start0(start);
    }

    private void start()
    {
        Thread.usleep(1 * 1000000);
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

    private IGameConnection create_server()
    {
        server = new ServerController();

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
