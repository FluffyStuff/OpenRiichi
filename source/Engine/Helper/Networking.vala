using Gee;

// Asynchronous networking class
public class Networking : Object
{
    public signal void connected(Connection connection);
    public signal void message_received(Connection connection, Message message);

    private SocketListener server;
    private bool listening = false;
    private Cancellable server_cancel;

    private ArrayList<Connection> connections;
    private Mutex mutex;

    public Networking()
    {
        connections = new ArrayList<Connection>();
        mutex = Mutex();
    }

    ~Networking()
    {
        close();
    }

    public void close()
    {
        mutex.lock();

        if (listening)
        {
            listening = false;
            server_cancel.cancel();
        }

        // Need to explicitly cancel all connections, or we will leak memory (have zombie threads)
        while (connections.size > 0)
        {
            Connection c = connections[0];
            remove_connection(c);
            c.close();
        }

        mutex.unlock();
    }

    public void stop_listening()
    {
        mutex.lock();

        if (listening)
        {
            listening = false;
            server_cancel.cancel();
        }

        mutex.unlock();
    }

    private void message_received_handler(Connection connection, Message message)
    {
        message_received(connection, message);
    }

    private void remove_connection(Connection connection)
    {
        connection.message_received.disconnect(message_received_handler);
        connection.closed.disconnect(connection_closed);
        connections.remove(connection);
    }

    private void connection_closed(Connection connection)
    {
        mutex.lock();

        remove_connection(connection);

        mutex.unlock();
    }

    private void add_connection(SocketConnection connection)
    {
        mutex.lock();

        Connection c = new Connection(connection);
        connections.add(c);
        c.message_received.connect(message_received_handler);
        c.closed.connect(connection_closed);

        mutex.unlock();

        connected(c);
        c.start();
    }

    private void host_worker()
    {
        try
        {
            while (true)
            {
                SocketConnection? connection = server.accept(null, server_cancel);

                mutex.lock();
                if (!listening)
                {
                    mutex.unlock();
                    break;
                }
                mutex.unlock();

                add_connection(connection);
            }
        }
        catch { }

        server.close();
        listening = false;
        unref();
    }

    public bool host(uint16 port)
    {
        if (listening)
            return false;

        try
        {
            server_cancel = new Cancellable();
            server = new SocketListener();
            server.add_inet_port(port, null);
            listening = true;

            Threading.start0(host_worker);
        }
        catch
        {
            return false;
        }

        ref();
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

            Connection connection = new Connection(conn);
            connection.start();

            return connection;
        }
        catch
        {
            return null;
        }
    }

    public static uint8[] int_to_data(uint32 n)
    {
        // Don't do this, so we maintain consistency over network
        //int bytes = (int)sizeof(int);
        int bytes = 4;

        uint8[] buffer = new uint8[bytes];
        for (int i = 0; i < bytes; i++)
            buffer[i] = (uint8)(n >> ((bytes - i - 1) * 8));
        return buffer;
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
    private Mutex mutex = Mutex();

    public Connection(SocketConnection connection)
    {
        this.connection = connection;
    }

    public void send(Message message)
    {
        try
        {
            connection.output_stream.write(Networking.int_to_data(message.data.length));
            connection.output_stream.write(message.data);
        }
        catch { } // Won't close here, because the thread will do it for us
    }

    public void start()
    {
        ref();
        Threading.start0(reading_worker);
    }

    public void close()
    {
        mutex.lock();
        try
        {
            run = false;
            cancel.cancel();
            connection.close();
        }
        catch {}
        mutex.unlock();
    }

    private void reading_worker()
    {
        connection.socket.set_blocking(false);
        var input = new DataInputStream(connection.input_stream);

        try
        {
            while (true)
            {
                mutex.lock();
                if (!run)
                {
                    mutex.unlock();
                    break;
                }
                mutex.unlock();

                uint32 length = input.read_uint32();
                uint8[] buffer = new uint8[length];
                size_t read;

                if (!connection.input_stream.read_all(buffer, out read, cancel) || buffer == null)
                    break;

                message_received(this, new Message(buffer));
            }
        }
        catch {}

        try
        {
            connection.close();
        }
        catch {}

        closed(this);

        unref();
    }
}

public class Message : Object
{
    protected Message.empty() {}

    public Message(uint8[] data)
    {
        this.data = data;
    }

    public uint8[] data { get; protected set; }
}

class UIntData
{
    private ArrayList<UInt> data = new ArrayList<UInt>();
    private int length = 0;

    public void add_data(uint8[] data)
    {
        this.data.add(new UInt(data));
        length += data.length;
    }

    public uint8[] get_data()
    {
        uint8[] ret = new uint8[length];

        int a = 0;
        for (int i = 0; i < data.size; i++)
        {
            UInt u = data[i];
            uint8[] d = u.data; // Can't inline due to bug in vala

            for (int j = 0; j < d.length; j++)
                ret[a++] = d[j];
        }

        return ret;
    }

    public static uint8[] serialize_string(string str)
    {
        return str.data;
    }

    public static uint8[] serialize_int(int i)
    {
        return Networking.int_to_data(i);
    }

    private class UInt
    {
        public UInt(uint8[] data) { this.data = data; }
        public uint8[] data;
    }
}

class DataUInt
{
    private uint8[] data;
    private int index = 0;

    public DataUInt(uint8[] data)
    {
        this.data = data;
    }

    public int get_int()
    {
        // Don't do this, so we maintain consistency over network
        //int bytes = (int)sizeof(int);
        int bytes = 4;

        int ret = 0;
        for (int i = 0; i < bytes; i++)
            ret += (int)data[index++] << ((bytes - i - 1) * 8);

        return ret;
    }

    public string get_string(int length)
    {
        uint8[] str = new uint8[length + 1];
        str[length] = 0;
        for (int i = 0; i < length; i++)
            str[i] = data[index++];
        string ret = (string)str;

        return ret;
    }

    public uint8[] get_data(int length)
    {
        uint8[] new_data = new uint8[length];
        for (int i = 0; i < length; i++)
            new_data[i] = data[index++];

        return new_data;
    }
}

public abstract class Serializable : Object
{
    // TODO: Secure against arbitrary code injections...
    public static Serializable? deserialize(uint8[] bytes)
    {
        DataUInt data = new DataUInt(bytes);

        int type_name_len = data.get_int();
        string type_name = data.get_string(type_name_len);
        int param_count = data.get_int();

        Type? type = Type.from_name(type_name);
        if (!type.is_a(typeof(Serializable)))
            return null;

        Parameter?[] params = new Parameter?[param_count];
        string[] names = new string[param_count];

        for (int i = 0; i < params.length; i++)
        {
            int name_len = data.get_int();
            string name = data.get_string(name_len);
            names[i] = name;

            bool has_value = true;
            Value val = Value(typeof(int));
            int t = data.get_int();
            DataType data_type = (DataType)t;

            if (data_type == DataType.INT)
            {
                val = Value(typeof(int));
                int v = data.get_int();
                val.set_int(v);
            }
            else if (data_type == DataType.BOOL)
            {
                val = Value(typeof(bool));
                bool b = (bool)data.get_int();
                val.set_boolean(b);
            }
            else if (data_type == DataType.STRING)
            {
                val = Value(typeof(string));
                int len = data.get_int();
                string str = data.get_string(len);
                val.set_string(str);
            }
            else if (data_type == DataType.SERIALIZABLE)
            {
                val = Value(typeof(Serializable));
                int len = data.get_int();

                if (len != 0)
                {
                    uint8[] sub_data = data.get_data(len);
                    Serializable sub_obj = deserialize(sub_data);
                    val.set_object(sub_obj);
                }
                else
                {
                    Object? obj = null;
                    val.set_object(obj);
                }
            }
            else
                has_value = false;

            if (has_value)
            {
                params[i] = Parameter();
                params[i].name = names[i];
                params[i].value = val;
            }
            else
                params[i] = null;
        }

        int count = 0;
        for (int i = 0; i < params.length; i++)
            if (params[i] != null)
                count++;
        Parameter[] p = new Parameter[count];
        count = 0;
        for (int i = 0; i < params.length; i++)
            if (params[i] != null)
                p[count++] = params[i];

        Object obj = Object.newv(type, p);

        return (Serializable)obj;
    }

    public uint8[] serialize()
    {
        UIntData data = new UIntData();

        ObjectClass cls = (ObjectClass)(this.get_type()).class_ref();
        ParamSpec[] specs = cls.list_properties();
        uint8[] name_data = UIntData.serialize_string(get_type().name());

        data.add_data(UIntData.serialize_int(name_data.length));
        data.add_data(name_data);
        data.add_data(UIntData.serialize_int(specs.length));

        for (int i = 0; i < specs.length; i++)
        {
            ParamSpec p = specs[i];
            name_data = UIntData.serialize_string(p.get_name());
            data.add_data(UIntData.serialize_int(name_data.length));
            data.add_data(name_data);

            if (p.value_type == typeof(int))
            {
                int type = (int)DataType.INT;

                Value val = Value(typeof(int));
                get_property(p.get_name(), ref val);
                int v = val.get_int();

                data.add_data(UIntData.serialize_int(type));
                data.add_data(UIntData.serialize_int(v));
            }
            else if (p.value_type == typeof(bool))
            {
                int type = (int)DataType.BOOL;

                Value val = Value(typeof(bool));
                get_property(p.get_name(), ref val);
                bool b = val.get_boolean();

                data.add_data(UIntData.serialize_int(type));
                data.add_data(UIntData.serialize_int((int)b));
            }
            else if (p.value_type == typeof(string))
            {
                int type = (int)DataType.STRING;

                Value val = Value(typeof(string));
                get_property(p.get_name(), ref val);
                string str = val.get_string();

                uint8[] str_data;
                if (str == null)
                    str_data = new uint8[0];
                else
                    str_data = UIntData.serialize_string(str);

                data.add_data(UIntData.serialize_int(type));
                data.add_data(UIntData.serialize_int(str_data.length));
                data.add_data(str_data);
            }
            else if (p.value_type.is_a(typeof(Serializable)))
            {
                int type = (int)DataType.SERIALIZABLE;

                Value val = Value(typeof(Serializable));
                get_property(p.get_name(), ref val);
                Serializable? obj = (Serializable?)val.get_object();

                if (obj != null)
                {
                    uint8[] obj_data = obj.serialize();

                    data.add_data(UIntData.serialize_int(type));
                    data.add_data(UIntData.serialize_int(obj_data.length));
                    data.add_data(obj_data);
                }
                else
                {
                    data.add_data(UIntData.serialize_int(type));
                    data.add_data(UIntData.serialize_int(0));
                }
            }
            else
            {
                int type = (int)DataType.UNKNOWN;
                data.add_data(UIntData.serialize_int(type));
            }
        }

        return data.get_data();
    }

    private enum DataType
    {
        UNKNOWN,
        INT,
        BOOL,
        STRING,
        SERIALIZABLE
    }
}

public class SerializableList<T> : Serializable
{
    public SerializableList(T[] objs)
    {
        SerializableListItem[] list = new SerializableListItem[objs.length];

        for (int i = 0; i < objs.length; i++)
            list[i] = new SerializableListItem((Serializable)objs[i]);
        for (int i = 0; i < objs.length - 1; i++)
            list[i].next = list[i + 1];

        if (list.length > 0)
            root = list[0];
        else
            root = null;
    }

    public T[] to_array()
    {
        ArrayList<Serializable> list = new ArrayList<Serializable>();

        SerializableListItem? p = root;
        while (p != null)
        {
            list.add(p.item);
            p = p.next;
        }

        return (T[])list.to_array();
    }

    protected SerializableListItem? root { get; protected set; }
}

public class SerializableListItem : Serializable
{
    public SerializableListItem(Serializable item)
    {
        this.item = item;
        next = null;
    }

    public Serializable item { get; protected set; }
    public SerializableListItem? next { get; set; }
}

public class ObjInt : Serializable
{
    public ObjInt(int value)
    {
        this.value = value;
    }

    public int value { get; protected set; }
}
