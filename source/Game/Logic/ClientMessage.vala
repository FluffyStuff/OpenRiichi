using Gee;
using Engine;

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
            if (d.param_type == type)
                d.method(player, message);
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

        public unowned ClientMessageDelegate method { get; private set; }
        public Type param_type { get; private set; }
    }
}

public abstract class ClientMessage : Serializable {}

public class ClientMessageAuthenticate : ClientMessage
{
    public ClientMessageAuthenticate(string name, VersionInfo version_info)
    {
        this.name = name;
        this.version_info = version_info;
    }

    public string name { get; protected set; }
    public VersionInfo version_info { get; protected set; }
}

public class ClientMessageControlDefaultCallAction : ClientMessage {}

public class ClientMessageControlDefaultTileAction : ClientMessage
{
    public ClientMessageControlDefaultTileAction(int tile_ID)
    {
        this.tile_ID = tile_ID;
    }

    public int tile_ID { get; protected set; }
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

public class ClientMessageMenuGameLog : ClientMessage
{
    public ClientMessageMenuGameLog(GameLog? log)
    {
        this.log = log;
    }

    public GameLog? log { get; protected set; }
}

public class ClientMessageMenuSettings : ClientMessage
{
    public ClientMessageMenuSettings(ServerSettings settings)
    {
        this.settings = settings;
    }

    public ServerSettings settings { get; protected set; }
}

public class ClientMessageMenuReady : ClientMessage {}

public class ClientMessageGameAction : ClientMessage
{
    public ClientMessageGameAction(ClientAction action)
    {
        this.action = action;
    }

    public ClientAction action { get; protected set; }
}
