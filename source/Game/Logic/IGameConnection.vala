using Gee;

public abstract class IGameConnection : Object
{
    private ArrayList<ServerMessage> queue = new ArrayList<ServerMessage>();
    private Mutex mutex = Mutex();

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
    public abstract void close();
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

    public override void close()
    {
        connection.close();
    }

    private void parse_message(Connection connection, Message message)
    {
        Serializable? msg = Serializable.deserialize(message.data);

        if (msg == null || !msg.get_type().is_a(typeof(ServerMessage)))
        {
            Environment.log(LogType.NETWORK, "GameNetworkConnection", "Client discarding invalid server message");
            return;
        }

        receive_message((ServerMessage)msg);
    }

    private void forward_disconnected(Connection connection)
    {
        disconnected();
    }

    public override bool authoritative { get; protected set; }
}

public class GameLocalConnection : IGameConnection
{
    private unowned GameServer.ServerPlayerLocalConnection? connection;

    public GameLocalConnection()
    {
        authoritative = true;
    }

    ~GameLocalConnection()
    {
        if (connection != null)
        {
            connection.disconnected.disconnect(connection_disconnected);
            connection = null;
            disconnected();
        }
    }

    public void set_connection(GameServer.ServerPlayerLocalConnection connection)
    {
        ref();

        if (this.connection != null)
        {
            this.connection.disconnected.disconnect(connection_disconnected);
            this.connection.close();
        }

        this.connection = connection;
        this.connection.disconnected.connect(connection_disconnected);

        unref();
    }

    public override void send_message(ClientMessage message)
    {
        if (connection != null)
            connection.receive_message(message);
    }

    public override void close()
    {
        if (connection != null)
            connection_disconnected();
    }

    private void connection_disconnected()
    {
        ref();

        connection.disconnected.disconnect(connection_disconnected);
        connection = null;
        disconnected();

        unref();
    }

    public override bool authoritative { get; protected set; }
}

public class TunneledGameConnection : IGameConnection
{
    public signal void request_send_message(TunneledGameConnection connection, ClientMessage message);
    public signal void request_close(TunneledGameConnection connection);

    public TunneledGameConnection()
    {
        authoritative = false;
    }

    public void do_receive_message(ServerMessage message)
    {
        receive_message(message);
    }

    public override void send_message(ClientMessage message)
    {
        request_send_message(this, message);
    }

    public override void close()
    {
        request_close(this);
    }

    public override bool authoritative { get; protected set; }
}
