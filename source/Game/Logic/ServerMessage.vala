using Gee;

public class ServerMessageParser
{
    private ArrayList<Dispatcher> dispatchers = new ArrayList<Dispatcher>();
    private ArrayList<ServerMessage> queue = new ArrayList<ServerMessage>();
    private Mutex mutex = new Mutex();

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
        {
            if (d.param_type == type)
            {
                ServerMessageDelegate method = d.method;
                method(message);
            }
        }
    }

    public delegate void ServerMessageDelegate(ServerMessage message);
    private class Dispatcher
    {
        public Dispatcher(ServerMessageDelegate method, Type type)
        {
            this.method = method;
            param_type = type;
        }

        public ServerMessageDelegate method { get; private set; }
        public Type param_type { get; private set; }
    }
}

public abstract class ServerMessage : SerializableMessage
{

}

public class ServerMessageRoundStart : ServerMessage
{
    public ServerMessageRoundStart(int player_ID, Wind round_wind, int dealer, int wall_index)
    {
        this.player_ID = player_ID;
        this.round_wind = (int)round_wind;
        this.dealer = dealer;
        this.wall_index = wall_index;
    }

    public Wind get_wind()
    {
        return (Wind)round_wind;
    }

    public int player_ID { get; protected set; }
    public int round_wind { get; protected set; }
    public int dealer { get; protected set; }
    public int wall_index { get; protected set; }
}

public class ServerMessageTileAssignment : ServerMessage
{
    public ServerMessageTileAssignment(int tile_ID, int tile_type, bool dora)
    {
        this.tile_ID = tile_ID;
        this.tile_type = tile_type;
        this.dora = dora;
    }

    public Tile get_tile()
    {
        return new Tile(tile_ID, (TileType)tile_type, dora);
    }

    public int tile_ID { get; protected set; }
    public int tile_type { get; protected set; }
    public bool dora { get; protected set; }
}

public class ServerMessageTileDraw : ServerMessage
{
    public ServerMessageTileDraw(int player_ID, int tile_ID, bool dead_wall)
    {
        this.player_ID = player_ID;
        this.tile_ID = tile_ID;
        this.dead_wall = dead_wall;
    }

    public int player_ID { get; protected set; }
    public int tile_ID { get; protected set; }
    public bool dead_wall { get; protected set; }
}

public class ServerMessageTileDiscard : ServerMessage
{
    public ServerMessageTileDiscard(int player_ID, int tile_ID)
    {
        this.player_ID = player_ID;
        this.tile_ID = tile_ID;
    }

    public int player_ID { get; protected set; }
    public int tile_ID { get; protected set; }
}

public class ServerMessageCallDecision : ServerMessage
{
    public ServerMessageCallDecision(int player_ID, int tile_ID)
    {
        this.player_ID = player_ID;
        this.tile_ID = tile_ID;
    }

    public int player_ID { get; protected set; }
    public int tile_ID { get; protected set; }
}

public class ServerMessageTurnDecision : ServerMessage {}

public class ServerMessageFlipDora : ServerMessage
{
    public ServerMessageFlipDora(int tile_ID)
    {
        this.tile_ID = tile_ID;
    }

    public int tile_ID { get; protected set; }
}

public class ServerMessageFlipUraDora : ServerMessage
{
    public ServerMessageFlipUraDora(int tile_ID)
    {
        this.tile_ID = tile_ID;
    }

    public int tile_ID { get; protected set; }
}

public class ServerMessageDeadTileAdd : ServerMessage
{
    public ServerMessageDeadTileAdd(int tile_ID)
    {
        this.tile_ID = tile_ID;
    }

    public int tile_ID { get; protected set; }
}

public class ServerMessageRon : ServerMessage
{
    public ServerMessageRon(int player_ID, int discard_player_ID, int tile_ID)
    {
        this.player_ID = player_ID;
        this.discard_player_ID = discard_player_ID;
        this.tile_ID = tile_ID;
    }

    public int player_ID { get; protected set; }
    public int discard_player_ID { get; protected set; }
    public int tile_ID { get; protected set; }
}

public class ServerMessageTsumo : ServerMessage
{
    public ServerMessageTsumo(int player_ID)
    {
        this.player_ID = player_ID;
    }

    public int player_ID { get; protected set; }
}

public class ServerMessageRiichi : ServerMessage
{
    public ServerMessageRiichi(int player_ID)
    {
        this.player_ID = player_ID;
    }

    public int player_ID { get; protected set; }
}

public class ServerMessageLateKan : ServerMessage
{
    public ServerMessageLateKan(int player_ID, int tile_ID)
    {
        this.player_ID = player_ID;
        this.tile_ID = tile_ID;
    }

    public int player_ID { get; protected set; }
    public int tile_ID { get; protected set; }
}

public class ServerMessageClosedKan : ServerMessage
{
    public ServerMessageClosedKan(int player_ID, TileType tile_type)
    {
        this.player_ID = player_ID;
        this.tile_type = (int)tile_type;
    }

    public TileType get_type_enum()
    {
        return (TileType)tile_type;
    }

    public int player_ID { get; protected set; }
    public int tile_type { get; protected set; }
}

public class ServerMessageOpenKan : ServerMessage
{
    public ServerMessageOpenKan(int player_ID, int discard_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID, int tile_3_ID)
    {
        this.player_ID = player_ID;
        this.discard_player_ID = discard_player_ID;
        this.tile_ID = tile_ID;
        this.tile_1_ID = tile_1_ID;
        this.tile_2_ID = tile_2_ID;
        this.tile_3_ID = tile_3_ID;
    }

    public int player_ID { get; protected set; }
    public int discard_player_ID { get; protected set; }
    public int tile_ID { get; protected set; }
    public int tile_1_ID { get; protected set; }
    public int tile_2_ID { get; protected set; }
    public int tile_3_ID { get; protected set; }
}

public class ServerMessagePon : ServerMessage
{
    public ServerMessagePon(int player_ID, int discard_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        this.player_ID = player_ID;
        this.discard_player_ID = discard_player_ID;
        this.tile_ID = tile_ID;
        this.tile_1_ID = tile_1_ID;
        this.tile_2_ID = tile_2_ID;
    }

    public int player_ID { get; protected set; }
    public int discard_player_ID { get; protected set; }
    public int tile_ID { get; protected set; }
    public int tile_1_ID { get; protected set; }
    public int tile_2_ID { get; protected set; }
}

public class ServerMessageChii : ServerMessage
{
    public ServerMessageChii(int player_ID, int discard_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        this.player_ID = player_ID;
        this.discard_player_ID = discard_player_ID;
        this.tile_ID = tile_ID;
        this.tile_1_ID = tile_1_ID;
        this.tile_2_ID = tile_2_ID;
    }

    public int player_ID { get; protected set; }
    public int discard_player_ID { get; protected set; }
    public int tile_ID { get; protected set; }
    public int tile_1_ID { get; protected set; }
    public int tile_2_ID { get; protected set; }
}

public class ServerMessageTenpaiPlayer : ServerMessage
{
    public ServerMessageTenpaiPlayer(int player_ID)
    {
        this.player_ID = player_ID;
    }

    public int player_ID { get; protected set; }
}

public class ServerMessageDraw : ServerMessage {}
