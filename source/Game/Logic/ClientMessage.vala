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

public class ClientMessageParser
{
    public void parse(ClientMessage message, Object state)
    {
        if (message.get_type() == typeof(ClientMessageTileDiscard))
            tile_discard((ClientMessageTileDiscard)message, state);
    }

    public signal void tile_discard(ClientMessageTileDiscard message, Object state);
}
