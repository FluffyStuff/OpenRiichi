class GameNetworking
{
    public signal void game_start(GameStartMessage message);

    private const uint16 PORT = 1337;
    private List<GameConnection> players = new List<GameConnection>();
    private bool hosting = false;
    private uint32 connection_id;

    public GameNetworking()
    {
        Networking.message_received.message.connect(message_received);
    }

    ~GameNetworking()
    {
        Networking.message_received.message.disconnect(message_received);
        Networking.close_connections();
    }

    private void message_received(Connection connection, Message message)
    {
        GameMessage msg = GameMessage.parse(message);

        if (hosting)
            host_received(connection, msg);
        else
            client_received(connection, msg);
    }

    private void host_received(Connection connection, GameMessage message)
    {
        foreach (GameConnection gc in players)
            if (connection == gc.connection)
            {
                gc.message_received(message);
                return;
            }

        if (message.get_type() == typeof(InitiateMessage))
        {
            InitiateMessage i = (InitiateMessage)message;

            if (!i.reply)
            {
                bool accepted = Environment.is_compatible(i.major, i.minor, i.revision);
                connection.send(new InitiateMessage.initiate_reply(accepted, ""));

                if (!accepted)
                    connection.close();
            }
            else
            {
                if (!i.accepted)
                    connection.close();
                else
                {
                    foreach (GameConnection gc in players)
                    {
                        PlayerConnectedMessage msg = new PlayerConnectedMessage.message(gc.id, gc.name, true);
                        connection.send(msg);
                    }

                    GameConnection g = new GameConnection(connection, connection_id++, i.name);
                    players.append(g);

                    PlayerConnectedMessage msg = new PlayerConnectedMessage.message(g.id, g.name, false);
                    send_to_all(msg);

                    Rand rnd = new Rand();
                    uint8[] tiles = new uint8[136];
                    for (uint8 j = 0; j < tiles.length; j++)
                        tiles[j] = j;
                    for (uint8 j = 0; j < tiles.length; j++)
                    {
                        int r = rnd.int_range(0, tiles.length - 1);
                        uint8 t = tiles[r];
                        tiles[r] = tiles[j];
                        tiles[j] = t;
                    }
                    uint8 wall_split = (uint8)rnd.int_range(2, 12);

                    for (int j = 0; j < players.length(); j++)
                        players.nth_data(j).connection.send(new GameStartMessage.message(0, tiles, wall_split, (uint8)j));
                }
            }
        }
    }

    private void send_to_all(GameMessage message)
    {
        foreach (GameConnection gc in players)
            gc.connection.send(message);
    }

    private void client_received(Connection connection, GameMessage message)
    {
        if (message.get_type() == typeof(InitiateMessage))
        {
            InitiateMessage i = (InitiateMessage)message;

            if (i.accepted)
            {
                bool accepted = Environment.is_compatible(i.major, i.minor, i.revision);
                connection.send(new InitiateMessage.initiate_reply(accepted, "Human-I"));

                if (!accepted)
                    connection.close();
            }
        }
        else if (message.get_type() == typeof(PlayerConnectedMessage))
        {
            PlayerConnectedMessage msg = (PlayerConnectedMessage)message;
            print("Got PCM id = '%d' name = '%s'\n", (int)msg.id, msg.name);
        }
        else if (message.get_type() == typeof(GameStartMessage))
        {
            GameStartMessage msg = (GameStartMessage)message;
            game_start(msg);
        }
    }

    public bool host()
    {
        if (hosting)
            return false;

        if (Networking.host(PORT))
        {
            hosting = true;
            connection_id = 1;
        }

        return hosting;
    }

    public bool join(string address)
    {
        if (hosting)
            return false;

        Connection connection = Networking.join(address, PORT);
        if (connection != null)
            connection.send(new InitiateMessage.initiate(Environment.version_major, Environment.version_minor, Environment.version_revision));
        return connection != null;
    }
}

class GameConnection
{
    public GameConnection(Connection connection, uint32 id, string name)
    {
        this.connection = connection;
        this.id = id;
        this.name = name;
    }

    public void message_received(GameMessage message)
    {

    }

    public Connection connection { get; private set; }
    public uint32 id { get; private set; }
    public string name { get; private set; }
}
