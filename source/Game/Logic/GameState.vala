public class GameState
{
    public GameState(GameStartState state)
    {

    }

    public void receive_message(ServerMessage message)
    {

    }

    public void tile_selected(Tile tile)
    {
        // TODO: Validity checking
        ClientMessageTileDiscard message = new ClientMessageTileDiscard(tile.ID);
        send_message(message);
    }

    public signal void send_message(ClientMessage message);
}


