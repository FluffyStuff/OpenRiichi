using Gee;

public class TileRules
{
    private TileRules(){}

    public static bool can_ron(ArrayList<Tile> hand, Tile tile)
    {
        return false;
    }

    public static bool can_late_kan(ArrayList<Tile> hand, ArrayList<GameStateCall> calls)
    {
        foreach (GameStateCall call in calls)
            if (call.call_type == GameStateCall.CallType.PON)
                foreach (Tile tile in hand)
                    if (tile.tile_type == call.tiles[0].tile_type)
                        return true;

        return false;
    }

    public static bool can_closed_kan(ArrayList<Tile> hand)
    {
        for (int i = 0; i < hand.size; i++)
        {
            int same = 0;
            for (int j = 0; j < hand.size; j++)
            {
                if (hand[i].tile_type == hand[j].tile_type)
                    same++;
            }

            if (same == 4)
                return true;
        }

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
        return get_chi_groups(hand, tile).size > 0;
    }

    public static ArrayList<Tile> get_late_kan_tiles(ArrayList<Tile> hand, ArrayList<GameStateCall> calls)
    {
        ArrayList<Tile> tiles = new ArrayList<Tile>();

        foreach (GameStateCall call in calls)
            if (call.call_type == GameStateCall.CallType.PON)
                foreach (Tile tile in hand)
                    if (tile.tile_type == call.tiles[0].tile_type)
                    {
                        tiles.add(tile);
                        break;
                    }

        return tiles;
    }

    public static ArrayList<ArrayList<Tile>> get_closed_kan_groups(ArrayList<Tile> hand_in)
    {
        ArrayList<ArrayList<Tile>> list = new ArrayList<ArrayList<Tile>>();

        ArrayList<Tile> hand = new ArrayList<Tile>();
        hand.add_all(hand_in);

        while (hand.size > 0)
        {
            int i = 0;

            ArrayList<Tile> tiles = new ArrayList<Tile>();
            for (int j = 0; j < hand.size; j++)
            {
                if (hand[i].tile_type == hand[j].tile_type)
                    tiles.add(hand[j]);
            }

            if (tiles.size == 4)
                list.add(tiles);

            hand.remove_at(i);
        }

        return list;
    }

    public static ArrayList<ArrayList<Tile>> get_chi_groups(ArrayList<Tile> hand, Tile tile)
    {
        ArrayList<ArrayList<Tile>> list = new ArrayList<ArrayList<Tile>>();

        int type = (int)tile.tile_type;
        if (type < (int)TileType.MAN1 || type > (int)TileType.SOU9)
            return list;

        int d = (int)TileType.MAN1;

        ArrayList<Tile> tiles = new ArrayList<Tile>();

        foreach (Tile t in hand)
            if (((int)t.tile_type - d) / 9 == (type - d) / 9)
                tiles.add(t);

        Tile? m2 = null;
        Tile? m1 = null;
        Tile? p1 = null;
        Tile? p2 = null;

        foreach (Tile t in tiles)
        {
            int otype = (int)t.tile_type;

            if (otype - type == -2)
                m2 = t;
            else if (otype - type == -1)
                m1 = t;
            else if (otype - type == 1)
                p1 = t;
            else if (otype - type == 2)
                p2 = t;
        }

        if (m1 != null && p1 != null)
        {
            ArrayList<Tile> l = new ArrayList<Tile>();
            l.add(m1);
            l.add(p1);
            list.add(l);
        }

        if (m2 != null && m1 != null)
        {
            ArrayList<Tile> l = new ArrayList<Tile>();
            l.add(m2);
            l.add(m1);
            list.add(l);
        }

        if (p1 != null && p2 != null)
        {
            ArrayList<Tile> l = new ArrayList<Tile>();
            l.add(p1);
            l.add(p2);
            list.add(l);
        }

        return list;
    }
}

class GameStateCall
{
    public GameStateCall(CallType type, ArrayList<Tile> tiles)
    {
        call_type = type;
        this.tiles = tiles;
    }

    public CallType call_type { get; private set; }
    public ArrayList<Tile> tiles { get; private set; }

    public enum CallType
    {
        CHI,
        PON,
        OPEN_KAN,
        CLOSED_KAN,
        LATE_KAN
    }
}
