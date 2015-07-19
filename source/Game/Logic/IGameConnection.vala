using Gee;

public abstract class IGameConnection
{
    private ArrayList<ServerMessage> queue = new ArrayList<ServerMessage>();
    private Mutex mutex = new Mutex();

    public signal void received_message();
    public signal void disconnected();

    public void receive_message(ServerMessage message)
    {
        mutex.lock();
        queue.add(message);
        mutex.unlock();

        received_message();
    }

    public ServerMessage? dequeue_message()
    {
        ServerMessage? message = null;

        mutex.lock();
        if (queue.size > 0)
            message = queue.remove_at(0);
        mutex.unlock();

        return message;
    }

    public ServerMessage? peek_message()
    {
        ServerMessage? message = null;

        mutex.lock();
        if (queue.size > 0)
            message = queue.get(0);
        mutex.unlock();

        return message;
    }

    public abstract void send_message(ClientMessage message);
    public abstract bool authoritative { get; protected set; }
}

public class GameNetworkConnection : IGameConnection
{
    private Connection connection;

    public GameNetworkConnection(Connection connection)
    {
        this.connection = connection;
        connection.message_received.connect(parse_message);
        connection.closed.connect(forward_disconnected);

        authoritative = false;
    }

    ~GameNetworkConnection()
    {
        connection.message_received.disconnect(parse_message);
        connection.closed.disconnect(forward_disconnected);
        connection.close();
    }

    public override void send_message(ClientMessage message)
    {
        Message msg = new Message(message.serialize());
        connection.send(msg);
    }

    private void parse_message(Connection connection, Message message)
    {
        SerializableMessage? msg = SerializableMessage.deserialize(message.data);

        if (msg == null || !msg.get_type().is_a(typeof(ServerMessage)))
        {
            print("Client discarding invalid server message!\n");
            return;
        }

        receive_message((ServerMessage)msg);
    }

    private void forward_disconnected(Connection connection)
    {
        disconnected();
    }

    public override bool authoritative { get; private set; }
}

public class GameLocalConnection : IGameConnection
{
    private GameServer.ServerPlayerLocalConnection? connection;

    public GameLocalConnection()
    {
        authoritative = true;
    }

    public void set_connection(GameServer.ServerPlayerLocalConnection connection)
    {
        this.connection = connection;
    }

    public override void send_message(ClientMessage message)
    {
        if (connection != null)
            connection.receive_message(message);
    }

    public void close()
    {
        connection = null;
        disconnected();
    }

    public override bool authoritative { get; private set; }
}
