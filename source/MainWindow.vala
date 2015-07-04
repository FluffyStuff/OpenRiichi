using SDL;
using GL;
using GameServer;

public class MainWindow : RenderWindow
{
    private GameController? game_controller;

    public MainWindow(IWindowTarget window, IRenderTarget renderer)
    {
        base(window, renderer);

        GamePlayer[] players = null;
        GamePlayer? controlled_player = null;

        IGameConnection game_connection = create_server();

        GameStartState state = new GameStartState(game_connection, players, controlled_player);

        game_controller = new GameController(main_view, state);

        back_color = Color() { r = 0, g = 0.01f, b = 0.02f };
    }

    protected override void do_process(DeltaArgs delta, IResourceStore store)
    {
        game_controller.process();
    }

    ServerController server;
    private IGameConnection create_server()
    {
        server = new ServerController();

        ServerPlayerLocalConnection server_connection = new ServerPlayerLocalConnection();
        GameLocalConnection game_connection = new GameLocalConnection();

        server_connection.set_connection(game_connection);
        game_connection.set_connection(server_connection);

        ServerHumanPlayer player = new ServerHumanPlayer(server_connection);
        server.add_player(player);


        ServerPlayerLocalConnection con1 = new ServerPlayerLocalConnection();
        ServerPlayerLocalConnection con2 = new ServerPlayerLocalConnection();
        ServerPlayerLocalConnection con3 = new ServerPlayerLocalConnection();

        GameLocalConnection loc1 = new GameLocalConnection();
        GameLocalConnection loc2 = new GameLocalConnection();
        GameLocalConnection loc3 = new GameLocalConnection();

        con1.set_connection(loc1);
        con2.set_connection(loc2);
        con3.set_connection(loc3);

        loc1.set_connection(con1);
        loc2.set_connection(con2);
        loc3.set_connection(con3);

        ServerComputerPlayer c1 = new ServerComputerPlayer(con1);
        ServerComputerPlayer c2 = new ServerComputerPlayer(con2);
        ServerComputerPlayer c3 = new ServerComputerPlayer(con3);
        /*ServerHumanPlayer c1 = new ServerHumanPlayer(con1);
        ServerHumanPlayer c2 = new ServerHumanPlayer(con2);
        ServerHumanPlayer c3 = new ServerHumanPlayer(con3);*/

        NullBot nul1 = new NullBot();
        NullBot nul2 = new NullBot();
        NullBot nul3 = new NullBot();

        bot1 = new BotConnection(nul1, loc1);
        bot2 = new BotConnection(nul2, loc2);
        bot3 = new BotConnection(nul3, loc3);

        server.add_player(c1);
        server.add_player(c2);
        server.add_player(c3);


        server.start_game();

        return game_connection;
    }

    protected override bool key_press(KeyArgs key)
    {
        switch (key.key)
        {
            case 27 :
            case 'q':
                finish();
                break;
            case 'f':
                fullscreen = !fullscreen;
                break;
            default:
                return false;
        }

        return true;
    }
}
BotConnection bot1;
BotConnection bot2;
BotConnection bot3;
