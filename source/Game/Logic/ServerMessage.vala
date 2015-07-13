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

public class ServerMessageGameStart : ServerMessage
{
    public ServerMessageGameStart(int player_ID, int dealer, int wall_index)
    {
        this.player_ID = player_ID;
        this.dealer = dealer;
        this.wall_index = wall_index;
    }

    public int player_ID { get; protected set; }
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
    public ServerMessageTileDraw(int player_ID, int tile_ID)
    {
        this.player_ID = player_ID;
        this.tile_ID = tile_ID;
    }

    public int player_ID { get; protected set; }
    public int tile_ID { get; protected set; }
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

public class ServerMessageChi : ServerMessage
{
    public ServerMessageChi(int player_ID, int discard_player_ID, int tile_ID, int tile_1_ID, int tile_2_ID)
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
