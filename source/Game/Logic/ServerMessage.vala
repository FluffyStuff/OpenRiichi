using Gee;

public class ServerMessageParser
{
    private ArrayList<ServerMessage> queue = new ArrayList<ServerMessage>();
    private Mutex mutex = new Mutex();

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
            parse(queue.remove_at(0));
        mutex.unlock();
    }

    public void parse(ServerMessage message)
    {
        if (message.get_type() == typeof(ServerMessageTileAssignment))
            tile_assignment((ServerMessageTileAssignment)message);
        else if (message.get_type() == typeof(ServerMessageTileDraw))
            tile_draw((ServerMessageTileDraw)message);
        else if (message.get_type() == typeof(ServerMessageTileDiscard))
            tile_discard((ServerMessageTileDiscard)message);
        else if (message.get_type() == typeof(ServerMessageTurnDecision))
            turn_decision((ServerMessageTurnDecision)message);
        else if (message.get_type() == typeof(ServerMessageCallDecision))
            call_decision((ServerMessageCallDecision)message);
        else if (message.get_type() == typeof(ServerMessageFlipDora))
            flip_dora((ServerMessageFlipDora)message);
    }

    public signal void tile_assignment(ServerMessageTileAssignment message);
    public signal void tile_draw(ServerMessageTileDraw message);
    public signal void tile_discard(ServerMessageTileDiscard message);
    public signal void turn_decision(ServerMessageTurnDecision message);
    public signal void call_decision(ServerMessageCallDecision message);
    public signal void flip_dora(ServerMessageFlipDora message);
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
