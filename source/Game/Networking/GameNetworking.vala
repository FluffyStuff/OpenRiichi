class GameNetworking
{
    private const uint16 PORT = 1337;
    private List<GameConnection> players = new List<GameConnection>();

    public GameNetworking()
    {
        Networking.message_received.message.connect(message_received);
    }

    ~GameNetworking()
    {
        Networking.message_received.message.disconnect(message_received);
        Networking.close_connections();
    }

    private void player_message(GameConnection player, Message message)
    {

    }

    private void message_received(Connection connection, Message message)
    {
        foreach (GameConnection gc in players)
            if (connection == gc.connection)
            {
                player_message(gc, message);
                return;
            }

        print("Received message: %s\n", message.message);
    }

    public bool host()
    {
        return Networking.host(PORT);
    }

    public bool join(string address)
    {
        Connection connection = Networking.join(address, PORT);
        connection.send_message(new Message("Authenticate meh!"));
        return true;
    }
}

class GameConnection
{
    public GameConnection(Connection connection)
    {
        this.connection = connection;
    }

    public Connection connection { get; private set; }
}

class GameMessage : Message
{
    public GameMessage()
    {
        base.empty();
    }

    public static GameMessage? parse_message(Message message)
    {
        return null;
    }
}
