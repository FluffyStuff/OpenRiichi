using Gee;

// Asynchronous networking class
public class Networking
{
    private const uint16 PORT = 1337;

    private SocketService server;
    private SocketConnection client_connection;
    private ArrayList<SocketConnection> clients;

    public Networking()
    {
    }

    private bool new_connection(SocketConnection connection)
    {
        print("New connection!\n");
        clients.add(connection);
        read_data.begin(connection);

        return true;
    }

    private async void read_data(SocketConnection client)
    {
        while (true)
        {

        }
    }

    void process_request (InputStream input, OutputStream output)
    {
        try
        {
            /*var data_in = new DataInputStream (input);
            string line;
            while ((line = data_in.read_line (null)) != null) {
                stdout.printf ("%s\n", line);
                if (line.strip () == "") break;
            }

            string content = "<html><h1>RiichiMahjong!</h1></html>";
            var header = new StringBuilder ();
            header.append ("HTTP/1.0 200 OK\r\n");
            header.append ("Content-Type: text/html\r\n");
            header.append_printf ("Content-Length: %lu\r\n\r\n", content.length);

            while (true)
            {
                output.write (header.str.data);
                output.write (content.data);
                output.flush ();
                Thread.usleep(1000000);
            }*/


        }
        catch {}
    }

    private void host_worker()
    {
        try
        {
            clients = new ArrayList<SocketConnection>();
            server = new SocketService();
            server.add_inet_port(PORT, null);
            server.start();

            while (true)
            {
                SocketConnection connection = server.accept(null, null);
                print("derp\n");
            }
        }
        catch { }
    }

    public bool host()
    {
        Threading.start0(host_worker);
        return true;
    }

    private void client_worker(Object addr_obj)
    {
        string addr = ((Obj<string>)addr_obj).obj;
        try
        {
            Resolver resolver = Resolver.get_default();
            GLib.List<InetAddress> addresses = resolver.lookup_by_name(addr, null);
            InetAddress address = addresses.nth_data(0);

            var socket_address = new InetSocketAddress(address, PORT);
            var client = new SocketClient();
            var conn = client.connect(socket_address);
            print("Connected to " + addr + ".\n");

            var message = "GET / HTTP/1.1\r\nHost: www.google.com\r\n\r\n";
            conn.output_stream.write(message.data);
            print("Wrote request.\n");

            //conn.socket.set_blocking(false);

            //var input = new DataInputStream(conn.input_stream);

            while (true)
            {
                //message = input.read_line(null).strip();
                //print("Client received line: %s\n", message);

                conn.output_stream.write(message.data);
                Thread.usleep(100000);
            }
        }
        catch { }
    }

    public bool join(string addr)
    {
        Threading.start1(client_worker, new Obj<string>(addr));
        return true;
    }
}
