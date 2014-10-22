using Gee;

// Asynchronous networking class
public static class Networking
{
    public static MessageSignal message_received;

    private static SocketListener server;
    private static bool listening = false;
    private static Cancellable server_cancel;

    private static ArrayList<Connection> connections;
    private static Mutex mutex;
    private static bool initialized = false;

    public static void init()
    {
        if (initialized)
            return;

        initialized = true;
        connections = new ArrayList<Connection>();
        message_received = new MessageSignal();
        mutex = new Mutex();
    }

    public static void close_connections()
    {
        // Need to explicitly cancel all connections, or we will leak memory (have zombie threads)
        mutex.lock();

        if (listening)
        {
            listening = false;
            server_cancel.cancel();
        }

        foreach (Connection c in connections)
            c.close();

        mutex.unlock();
    }

    private static void message_received_handler(Connection connection, Message message)
    {
        message_received.message(connection, message);
    }

    private static void connection_closed(Connection connection)
    {
        mutex.lock();

        connection.message_received.disconnect(message_received_handler);
        connection.closed.disconnect(connection_closed);
        connections.remove(connection);
        print("Connection closed. (" + connections.size.to_string() + " left)\n");

        mutex.unlock();
    }

    private static Connection add_connection(SocketConnection connection)
    {
        mutex.lock();

        Connection c = new Connection(connection);
        connections.add(c);
        print("New connection. (" + connections.size.to_string() + " now)\n");
        c.message_received.connect(message_received_handler);
        c.closed.connect(connection_closed);
        c.start();

        mutex.unlock();

        return c;
    }

    private static bool new_connection(SocketConnection connection)
    {
        add_connection(connection);
        return true;
    }

    private static void host_worker(Object obj)
    {
        if (listening)
            return;

        try
        {
            uint16 port = ((Obj<uint16>)obj).obj;
            server_cancel = new Cancellable();
            server = new SocketListener();
            server.add_inet_port(port, null);
            listening = true;

            while (true)
            {
                SocketConnection connection = server.accept(null, server_cancel);

                if (!listening)
                    break;

                new_connection(connection);
            }
        }
        catch { }

        server.close();
        listening = false;
    }

    public static bool host(uint16 port)
    {
        Threading.start1(host_worker, new Obj<uint16>(port));
        return true;
    }

    public static Connection? join(string addr, uint16 port)
    {
        try
        {
            Resolver resolver = Resolver.get_default();
            GLib.List<InetAddress> addresses = resolver.lookup_by_name(addr, null);
            InetAddress address = addresses.nth_data(0);

            var socket_address = new InetSocketAddress(address, port);
            var client = new SocketClient();
            var conn = client.connect(socket_address);

            return add_connection(conn);
        }
        catch
        {
            return null;
        }
    }
}

public class MessageSignal
{
    public signal void message(Connection connection, Message message);
}

public class Connection : Object
{
    public signal void message_received(Connection connection, Message message);
    public signal void closed(Connection connection);

    private SocketConnection connection;
    private bool run = true;
    private Cancellable cancel = new Cancellable();

    public Connection(SocketConnection connection)
    {
        this.connection = connection;
    }

    public void send(Message message)
    {
        try
        {
            connection.output_stream.write(int_to_data(message.data.length));
            connection.output_stream.write(message.data);
        }
        catch { } // Won't close here, because the thread will do it for us
    }

    public void start()
    {
        Threading.start1(reading_worker, this);
    }

    public void close()
    {
        run = false;
        cancel.cancel();
    }

    private static void reading_worker(Object conn)
    {
        Connection connection = (Connection)conn;

        connection.connection.socket.set_blocking(false);
        var input = new DataInputStream(connection.connection.input_stream);

        try
        {
            while (connection.run)
            {
                uint32 length = input.read_uint32();
                uint8[] buffer = new uint8[length];
                size_t read;

                if (!connection.connection.input_stream.read_all(buffer, out read, connection.cancel) || buffer == null)
                    break;

                connection.message_received(connection, new Message(buffer));
            }
        }
        catch {}

        try
        {
            if (connection.cancel.is_cancelled())
                connection.connection.close();

            connection.closed(connection);
        }
        catch {}
    }
}

public class Message : Object
{
    protected Message.empty() {}

    public Message(uint8[] data)
    {
        this.data = data;
    }

    public uint8[] data { get; private set; }
}
