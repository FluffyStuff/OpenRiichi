using Gee;

public class ClientMessageParser
{
    private ArrayList<Dispatcher> dispatchers = new ArrayList<Dispatcher>();
    private ArrayList<ClientMessageTuple> queue = new ArrayList<ClientMessageTuple>();
    private Mutex mutex = Mutex();

    public void connect(ClientMessageDelegate method, Type type)
    {
        dispatchers.add(new Dispatcher(method, type));
    }

    public void disconnect()
    {
        mutex.lock();
        dispatchers.clear();
        mutex.unlock();
    }

    public void add(GameServer.ServerPlayer player, ClientMessage message)
    {
        mutex.lock();
        queue.add(new ClientMessageTuple(player, message));
        mutex.unlock();
    }

    public void execute_all()
    {
        mutex.lock();
        while (queue.size > 0)
        {
            ClientMessageTuple tuple = queue.remove_at(0);
            execute(tuple.player, tuple.message);
        }
        mutex.unlock();
    }

    public ClientMessageTuple? dequeue()
    {
        ClientMessageTuple? message = null;

        mutex.lock();
        if (queue.size > 0)
            message = queue.remove_at(0);
        mutex.unlock();

        return message;
    }

    public void execute(GameServer.ServerPlayer player, ClientMessage message)
    {
        Type type = message.get_type();
        foreach (Dispatcher d in dispatchers)
        {
            if (d.param_type == type)
            {
                ClientMessageDelegate method = d.method;
                method(player, message);
            }
        }
    }

    public class ClientMessageTuple : Object
    {
        public ClientMessageTuple(GameServer.ServerPlayer player, ClientMessage message)
        {
            this.player = player;
            this.message = message;
        }

        public GameServer.ServerPlayer player { get; private set; }
        public ClientMessage message { get; private set; }
    }

    public delegate void ClientMessageDelegate(GameServer.ServerPlayer player, ClientMessage message);
    private class Dispatcher
    {
        public Dispatcher(ClientMessageDelegate method, Type type)
        {
            this.method = method;
            param_type = type;
        }

        public ClientMessageDelegate method { get; private set; }
        public Type param_type { get; private set; }
    }
}

public abstract class ClientMessage : Serializable
{

}

public class ClientMessageAuthenticate : ClientMessage
{
    public ClientMessageAuthenticate(string name)
    {
        this.name = name;
    }

    public string name { get; protected set; }
}

public class ClientMessageMenuGameStart : ClientMessage {}

public class ClientMessageMenuAddBot : ClientMessage
{
    public ClientMessageMenuAddBot(string name, int slot)
    {
        this.name = name;
        this.slot = slot;
    }

    public string name { get; protected set; }
    public int slot { get; protected set; }
}

public class ClientMessageMenuKickPlayer : ClientMessage
{
    public ClientMessageMenuKickPlayer(int slot)
    {
        this.slot = slot;
    }

    public int slot { get; protected set; }
}

public class ClientMessageTileDiscard : ClientMessage
{
    public ClientMessageTileDiscard(int tile_ID)
    {
        this.tile_ID = tile_ID;
    }

    public int tile_ID { get; protected set; }
}

public class ClientMessageNoCall : ClientMessage {}

public class ClientMessageChii : ClientMessage
{
    public ClientMessageChii(int tile_1_ID, int tile_2_ID)
    {
        this.tile_1_ID = tile_1_ID;
        this.tile_2_ID = tile_2_ID;
    }

    public int tile_1_ID { get; protected set; }
    public int tile_2_ID { get; protected set; }
}

public class ClientMessagePon : ClientMessage {}

public class ClientMessageOpenKan : ClientMessage {}

public class ClientMessageClosedKan : ClientMessage
{
    public ClientMessageClosedKan(int tile_type)
    {
        this.tile_type = tile_type;
    }

    public TileType get_type_enum()
    {
        return (TileType)tile_type;
    }

    public int tile_type { get; protected set; }
}

public class ClientMessageLateKan : ClientMessage
{
    public ClientMessageLateKan(int tile_ID)
    {
        this.tile_ID = tile_ID;
    }

    public int tile_ID { get; protected set; }
}

public class ClientMessageRiichi : ClientMessage {}

public class ClientMessageTsumo : ClientMessage {}

public class ClientMessageRon : ClientMessage {}
