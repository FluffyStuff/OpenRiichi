using Gee;

public class TileRules
{
    private TileRules(){}

    public static bool can_ron(ArrayList<Tile> hand, Tile tile)
    {
        return false;
    }

    public static bool can_open_kan(ArrayList<Tile> hand, Tile tile)
    {
        int count = 0;
        for (int i = 0; i < hand.size; i++)
            if (hand[i].tile_type == tile.tile_type)
                if (++count == 3)
                    return true;
        return false;
    }

    public static bool can_pon(ArrayList<Tile> hand, Tile tile)
    {
        int count = 0;
        for (int i = 0; i < hand.size; i++)
            if (hand[i].tile_type == tile.tile_type)
                if (++count == 2)
                    return true;
        return false;
    }

    public static bool can_chi(ArrayList<Tile> hand, Tile tile)
    {
        int type = (int)tile.tile_type;
        if (type < (int)TileType.MAN1 || type > (int)TileType.SOU9)
            return false;



        return false;
    }
}
