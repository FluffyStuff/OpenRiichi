using Gee;

public class ClientMessageParser
{
    private ArrayList<Dispatcher> dispatchers = new ArrayList<Dispatcher>();

    public void connect(ClientMessageDelegate method, Type type)
    {
        dispatchers.add(new Dispatcher(method, type));
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

public abstract class ClientMessage : SerializableMessage
{

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

public class ClientMessageChi : ClientMessage
{
    public ClientMessageChi(int tile_1_ID, int tile_2_ID)
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

public class ClientMessageRon : ClientMessage {}
