using Gee;

public class Yaku
{
    private Yaku.make_riichi()
    {
        han = 1;
        name = "Riichi";
    }

    private Yaku.make_double_riichi()
    {
        han = 2;
        name = "Double Riichi";
    }

    private Yaku.make_tsumo()
    {
        han = 1;
        name = "Tsumo";
    }

    private Yaku.make_tan_yao()
    {
        han = 2;
        name = "Tan-Yao";
    }

    public int han { get; private set; }
    public string name { get; private set; }

    // -------------- Yaku logic --------------

    public static Yaku? riichi(int turn)
    {
        if (turn == -1)
            return null;
        else if (turn == 1)
            return new Yaku.make_double_riichi();
        else
            return new Yaku.make_riichi();
    }

    public static Yaku? tsumo(bool open)
    {
        if (open)
            return null;

        return new Yaku.make_tsumo();
    }

    public static Yaku? tan_yao(ArrayList<Tile> hand, ArrayList<Call> calls)
    {
        foreach (Tile tile in hand)
            if (tile.tile_type <= TILE_TYPE.MAN1 ||
                tile.tile_type == TILE_TYPE.MAN9 ||
                tile.tile_type == TILE_TYPE.PIN1 ||
                tile.tile_type == TILE_TYPE.PIN9 ||
                tile.tile_type == TILE_TYPE.SOU1 ||
                tile.tile_type >= TILE_TYPE.SOU9)
                return null;

        foreach (Call call in calls)
            foreach (Tile tile in call.tiles)
                if (tile.tile_type <= TILE_TYPE.MAN1 ||
                    tile.tile_type == TILE_TYPE.MAN9 ||
                    tile.tile_type == TILE_TYPE.PIN1 ||
                    tile.tile_type == TILE_TYPE.PIN9 ||
                    tile.tile_type == TILE_TYPE.SOU1 ||
                    tile.tile_type >= TILE_TYPE.SOU9)
                    return null;

        return new Yaku.make_tan_yao();
    }
}
