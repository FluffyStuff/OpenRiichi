using Gee;

public class ServerMessageParser
{
    private ArrayList<Dispatcher> dispatchers = new ArrayList<Dispatcher>();
    private ArrayList<ServerMessage> queue = new ArrayList<ServerMessage>();
    private Mutex mutex = Mutex();

    public void connect(ServerMessageDelegate method, Type type)
    {
        dispatchers.add(new Dispatcher(method, type));
    }

    public void disconnect()
    {
        mutex.lock();
        dispatchers.clear();
        mutex.unlock();
    }

    public void add(ServerMessage message)
    {
        mutex.lock();
        queue.add(message);
        mutex.unlock();
    }

    public void dequeue()
    {
        mutex.lock();
        while (queue.size > 0)
            execute(queue.remove_at(0));
        mutex.unlock();
    }

    public void execute(ServerMessage message)
    {
        Type type = message.get_type();
        foreach (Dispatcher d in dispatchers)
            if (d.param_type == type)
                d.method(message);
    }

    public delegate void ServerMessageDelegate(ServerMessage message);
    private class Dispatcher
    {
        public Dispatcher(ServerMessageDelegate method, Type type)
        {
            this.method = method;
            param_type = type;
        }

        public unowned ServerMessageDelegate method { get; private set; }
        public Type param_type { get; private set; }
    }
}

public abstract class ServerMessage : Serializable {}

public class ServerMessageGameStart : ServerMessage
{
    public ServerMessageGameStart(GameStartInfo info, ServerSettings settings, int player_index)
    {
        this.info = info;
        this.settings = settings;
        this.player_index = player_index;
    }

    public GameStartInfo info { get; protected set; }
    public ServerSettings settings { get; protected set; }
    public int player_index { get; protected set; }
}

public class ServerMessageRoundStart : ServerMessage
{
    public ServerMessageRoundStart(RoundStartInfo info)
    {
        this.info = info;
    }

    public RoundStartInfo info { get; protected set; }
}

public class ServerMessagePlayerLeft : ServerMessage
{
    public ServerMessagePlayerLeft(int player_index)
    {
        this.player_index = player_index;
    }

    public int player_index { get; protected set; }
}

public class ServerMessageTileAssignment : ServerMessage
{
    public ServerMessageTileAssignment(Tile tile)
    {
        this.tile = tile;
    }

    public Tile tile { get; protected set; }
}

public class ServerMessageTileDraw : ServerMessage {}

public class ServerMessageTileDiscard : ServerMessage
{
    public ServerMessageTileDiscard(int tile_ID)
    {
        this.tile_ID = tile_ID;
    }

    public int tile_ID { get; protected set; }
}

public class ServerMessageCallDecision : ServerMessage {}

public class ServerMessageTurnDecision : ServerMessage {}

public class ServerMessageRon : ServerMessage
{
    public ServerMessageRon(int[] player_indices)
    {
        ObjInt[] ints = new ObjInt[player_indices.length];
        for (int i = 0; i < player_indices.length; i++)
            ints[i] = new ObjInt(player_indices[i]);

        list = new SerializableList<ObjInt>(ints);
    }

    public int[] get_player_indices()
    {
        var objs = list.to_array();

        int[] ints = new int[objs.length];
        for (int i = 0; i < objs.length; i++)
            ints[i] = objs[i].value;

        return ints;
    }

    protected SerializableList<ObjInt> list { get; protected set; }
    public int player_index { get; protected set; }
}

public class ServerMessageTsumo : ServerMessage {}

public class ServerMessageRiichi : ServerMessage
{
    public ServerMessageRiichi(bool open)
    {
        this.open = open;
    }

    public bool open { get; protected set; }
}

public class ServerMessageLateKan : ServerMessage
{
    public ServerMessageLateKan(int tile_ID)
    {
        this.tile_ID = tile_ID;
    }

    public int tile_ID { get; protected set; }
}

public class ServerMessageClosedKan : ServerMessage
{
    public ServerMessageClosedKan(TileType tile_type)
    {
        this.tile_type = tile_type;
    }

    public TileType tile_type { get; protected set; }
}

public class ServerMessageOpenKan : ServerMessage
{
    public ServerMessageOpenKan(int player_index, int tile_1_ID, int tile_2_ID, int tile_3_ID)
    {
        this.player_index = player_index;
        this.tile_1_ID = tile_1_ID;
        this.tile_2_ID = tile_2_ID;
        this.tile_3_ID = tile_3_ID;
    }

    public int player_index { get; protected set; }
    public int tile_1_ID { get; protected set; }
    public int tile_2_ID { get; protected set; }
    public int tile_3_ID { get; protected set; }
}

public class ServerMessagePon : ServerMessage
{
    public ServerMessagePon(int player_index, int tile_1_ID, int tile_2_ID)
    {
        this.player_index = player_index;
        this.tile_1_ID = tile_1_ID;
        this.tile_2_ID = tile_2_ID;
    }

    public int player_index { get; protected set; }
    public int tile_1_ID { get; protected set; }
    public int tile_2_ID { get; protected set; }
}

public class ServerMessageChii : ServerMessage
{
    public ServerMessageChii(int player_index, int tile_1_ID, int tile_2_ID)
    {
        this.player_index = player_index;
        this.tile_1_ID = tile_1_ID;
        this.tile_2_ID = tile_2_ID;
    }

    public int player_index { get; protected set; }
    public int tile_1_ID { get; protected set; }
    public int tile_2_ID { get; protected set; }
}

public class ServerMessageCallsFinished : ServerMessage {}

public class ServerMessageDraw : ServerMessage
{
    public ServerMessageDraw(int[] tenpai_indices, bool void_hand, bool triple_ron)
    {
        ObjInt[] ints = new ObjInt[tenpai_indices.length];
        for (int i = 0; i < tenpai_indices.length; i++)
            ints[i] = new ObjInt(tenpai_indices[i]);

        list = new SerializableList<ObjInt>(ints);

        this.void_hand = void_hand;
        this.triple_ron = triple_ron;
    }

    public int[] get_tenpai_indices()
    {
        var objs = list.to_array();

        int[] ints = new int[objs.length];
        for (int i = 0; i < objs.length; i++)
            ints[i] = objs[i].value;

        return ints;
    }

    protected SerializableList<ObjInt> list { get; protected set; }
    public bool void_hand { get; protected set; }
    public bool triple_ron { get; protected set; }
}

public class ServerMessageAcceptJoin : ServerMessage
{
    public ServerMessageAcceptJoin(bool version_mismatch, VersionInfo version_info)
    {
        this.version_mismatch = version_mismatch;
        this.version_info = version_info;
    }

    public bool version_mismatch { get; protected set; }
    public VersionInfo version_info { get; protected set; }
}

public class ServerMessageMenuSlotAssign : ServerMessage
{
    public ServerMessageMenuSlotAssign(int slot, string name)
    {
        this.slot = slot;
        this.name = name;
    }

    public int slot { get; protected set; }
    public string name { get; protected set; }
}

public class ServerMessageMenuSlotClear : ServerMessage
{
    public ServerMessageMenuSlotClear(int slot)
    {
        this.slot = slot;
    }

    public int slot { get; protected set; }
}

public class ServerMessageMenuSettings : ServerMessage
{
    public ServerMessageMenuSettings(ServerSettings settings)
    {
        this.settings = settings;
    }

    public ServerSettings settings { get; protected set; }
}

public class ServerMessageMenuGameLog : ServerMessage
{
    public ServerMessageMenuGameLog(string? name)
    {
        this.name = name;
    }

    public string? name { get; protected set; }
}
