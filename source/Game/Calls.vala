public abstract class Call
{
    public Tile[] tiles { get; protected set; }
}

public class Chi : Call
{
    public Chi(Tile[] tiles)
    {
        this.tiles = new Tile[3];
        for (int i = 0; i < 3; i++)
            this.tiles[i] = tiles[i];
    }
}

public class Pon : Call
{
    public Pon(Tile[] tiles, int direction)
    {
        this.tiles = new Tile[3];
        for (int i = 0; i < 3; i++)
            this.tiles[i] = tiles[i];
        this.direction = direction;
    }

    public int direction { get; private set; }
}

public class Kan : Call
{
    public Kan(Tile[] tiles, int direction, bool open)
    {
        this.tiles = new Tile[4];
        for (int i = 0; i < 4; i++)
            this.tiles[i] = tiles[i];
    }

    public bool open { get; private set; }
    public int direction { get; private set; }
}

