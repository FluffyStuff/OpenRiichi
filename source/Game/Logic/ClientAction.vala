using Engine;

public abstract class ClientAction : Serializable {}

public class TileDiscardClientAction : ClientAction
{
    public TileDiscardClientAction(int tile)
    {
        this.tile = tile;
    }

    public int tile { get; protected set; }
}

public class NoCallClientAction : ClientAction {}

public class RonClientAction : ClientAction {}

public class TsumoClientAction : ClientAction {}

public class VoidHandClientAction : ClientAction {}

public class RiichiClientAction : ClientAction
{
    public RiichiClientAction(bool open)
    {
        this.open = open;
    }

    public bool open { get; protected set; }
}

public class LateKanClientAction : ClientAction
{
    public LateKanClientAction(int tile)
    {
        this.tile = tile;
    }

    public int tile { get; protected set; }
}

public class ClosedKanClientAction : ClientAction
{
    public ClosedKanClientAction(TileType tile_type)
    {
        this.tile_type = tile_type;
    }

    public TileType tile_type { get; protected set; }
}

public class OpenKanClientAction : ClientAction {}

public class PonClientAction : ClientAction {}

public class ChiiClientAction : ClientAction
{
    public ChiiClientAction(int tile_1, int tile_2)
    {
        this.tile_1 = tile_1;
        this.tile_2 = tile_2;
    }

    public int tile_1 { get; protected set; }
    public int tile_2 { get; protected set; }
}