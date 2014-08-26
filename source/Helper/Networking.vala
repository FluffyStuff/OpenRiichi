using Gee;

// Asynchronous networking class
public /*static*/ class Networking
{
    private const uint16 PORT = 1337;

    private static SocketListener server;
    private static bool listening = false;
    private static Cancellable server_cancel;

    private static Socket socket;

    private static ArrayList<Connection> connections;
    private static Mutex mutex = new Mutex();
    private static bool initialized = false;

    public static void init()
    {
        if (initialized)
            return;

        initialized = true;
        connections = new ArrayList<Connection>();
        //mutex = new Mutex();

	socket = new Socket(SocketFamily.IPV4, SocketType.STREAM, SocketProtocol.TCP);
	InetAddress address = new InetAddress.loopback(SocketFamily.IPV4);
	InetSocketAddress inetaddress = new InetSocketAddress (address, PORT);
	socket.bind(inetaddress, true);
	socket.set_listen_backlog(10);

        server_cancel = new Cancellable();
        //server = new SocketListener();
        //server.add_inet_port(PORT, null);
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
            c.stop();

        mutex.unlock();
    }

    private static void message_received(Connection connection, Message message)
    {
        //print("Received message: %s\n", message.message);
        connection.send_message(message);
    }

    private static void connection_closed(Connection connection)
    {
        mutex.lock();

        connection.message_received.disconnect(message_received);
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
        c.message_received.connect(message_received);
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

    private static void host_worker()
    {
        if (listening)
            return;

        try
        {
            listening = true;
            //server.incoming.connect(new_connection);
	    socket.listen();

            while (true)
            {
                //server = new SocketListener();
                //SocketConnection connection = server.accept(null, server_cancel);
		//socket.listen();
		Socket sock = socket.accept(server_cancel);
		print("new sock\n");

		if (!listening)
			break;

		SocketConnection connection = SocketConnection.factory_create_connection(sock);

                new_connection(connection);
            }
        }
        catch
        {
            print("Host derped out...\n");
        }

        //server.incoming.disconnect(new_connection);
        socket.close();
        listening = false;
        print("Hosting ended...\n");
    }

    public static bool host()
    {
        Threading.start0(host_worker);
        return true;
    }

    public static bool join(string addr)
    {
    	print("Joining...\n");
        try
        {
            Resolver resolver = Resolver.get_default();
            GLib.List<InetAddress> addresses = resolver.lookup_by_name(addr, null);
            InetAddress address = addresses.nth_data(0);
	    print("join 1\n");

            var socket_address = new InetSocketAddress(address, PORT);
            var client = new SocketClient();
	    print("join 2\n");
            var conn = client.connect(socket_address);
	    print("join 3\n");

            Connection c = add_connection(conn);

            c.send_message(new Message("GET / HTTP/1.1\r\n"));
        }
        catch (Error e)
	{
		print(e.message);
		print(" :Joining derped out...\n");
	}
	
	print("join over...\n");
        return true;
    }
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

    public void send_message(Message message)
    {
        try
        {
            connection.output_stream.write((message.message + "\n").data);
        }
        catch { } // Won't close here, because the thread will do it for us
    }

    public void start()
    {
        Threading.start1(reading_worker, this);
    }

    public void stop()
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
                string? message = input.read_line(null, connection.cancel);
                if (message == null)
                    break;

                connection.message_received(connection, new Message(message));
            }
        }
        catch { }

        connection.closed(connection);
    }
}

public class Message
{
    public Message(string message)
    {
        this.message = message.strip();
    }

    public string message { get; private set; }
}
