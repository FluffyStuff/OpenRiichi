public class Tile
{
    public Tile(int ID, TileType type, bool dora)
    {
        this.ID = ID;
        tile_type = type;
        this.dora = dora;
    }

    public bool is_same_sort(Tile other)
    {
        if (tile_type >= TileType.MAN1 && tile_type <= TileType.MAN9 &&
            other.tile_type >= TileType.MAN1 && other.tile_type <= TileType.MAN9)
            return true;
        if (tile_type >= TileType.PIN1 && tile_type <= TileType.PIN9 &&
            other.tile_type >= TileType.PIN1 && other.tile_type <= TileType.PIN9)
            return true;
        if (tile_type >= TileType.SOU1 && tile_type <= TileType.SOU9 &&
            other.tile_type >= TileType.SOU1 && other.tile_type <= TileType.SOU9)
            return true;

        return tile_type == other.tile_type;
    }

    public bool is_suit_tile()
    {
        if (tile_type >= TileType.MAN1 && tile_type <= TileType.MAN9)
            return true;
        if (tile_type >= TileType.PIN1 && tile_type <= TileType.PIN9)
            return true;
        if (tile_type >= TileType.SOU1 && tile_type <= TileType.SOU9)
            return true;

        return false;
    }

    public bool is_honor_tile()
    {
        if (tile_type == TileType.TON   ||
            tile_type == TileType.NAN   ||
            tile_type == TileType.SHAA  ||
            tile_type == TileType.PEI   ||
            tile_type == TileType.HAKU  ||
            tile_type == TileType.HATSU ||
            tile_type == TileType.CHUN)
            return true;

        return false;
    }

    public bool is_dragon_tile()
    {
        if (tile_type == TileType.HAKU  ||
            tile_type == TileType.HATSU ||
            tile_type == TileType.CHUN)
            return true;

        return false;
    }

    public bool is_wind_tile()
    {
        if (tile_type == TileType.TON  ||
            tile_type == TileType.NAN  ||
            tile_type == TileType.SHAA ||
            tile_type == TileType.PEI)
            return true;

        return false;
    }

    public bool is_terminal_tile()
    {
        if (tile_type == TileType.MAN1 ||
            tile_type == TileType.MAN9 ||
            tile_type == TileType.PIN1 ||
            tile_type == TileType.PIN9 ||
            tile_type == TileType.SOU1 ||
            tile_type == TileType.SOU9)
            return true;

        return false;
    }

    public bool is_wind(Wind wind)
    {
        return ((tile_type == TileType.TON  && wind == Wind.EAST)  ||
                (tile_type == TileType.NAN  && wind == Wind.SOUTH) ||
                (tile_type == TileType.SHAA && wind == Wind.WEST)  ||
                (tile_type == TileType.PEI  && wind == Wind.NORTH));
    }

    public int get_number_index()
    {
        if (tile_type >= TileType.MAN1 && tile_type <= TileType.MAN9)
            return tile_type - TileType.MAN1;
        if (tile_type >= TileType.PIN1 && tile_type <= TileType.PIN9)
            return tile_type - TileType.PIN1;
        if (tile_type >= TileType.SOU1 && tile_type <= TileType.SOU9)
            return tile_type - TileType.SOU1;

        return 0;
    }

    public int ID { get; set; }
    public TileType tile_type { get; set; }
    public bool dora { get; set; }

    /*public TileSuit tile_sort
    {
        get
        {
            if (tile_type == TileType.BLANK)
                return TileSuit.BLANK;

            if (tile_type >= TileType.MAN1 && tile_type <= TileType.MAN9)
                return TileSuit.MAN;
            if (tile_type >= TileType.PIN1 && tile_type <= TileType.PIN9)
                return TileSuit.PIN;
            if (tile_type >= TileType.SOU1 && tile_type <= TileType.SOU9)
                return TileSuit.SOU;

            return TileSuit.DRAGON;
        }
    }*/
}

/*public enum TileSuit
{
    BLANK,
    MAN,
    PIN,
    SOU,
    WIND,
    DRAGON
}*/

public enum Wind
{
    EAST,
    SOUTH,
    WEST,
    NORTH
}

public static Wind NEXT_WIND(Wind wind)
{
    switch (wind)
    {
    case Wind.EAST:
        return Wind.SOUTH;
    case Wind.SOUTH:
        return Wind.WEST;
    case Wind.WEST:
        return Wind.NORTH;
    case Wind.NORTH:
    default:
        return Wind.EAST;
    }
}

public enum TileType
{
    BLANK,
    MAN1,
    MAN2,
    MAN3,
    MAN4,
    MAN5,
    MAN6,
    MAN7,
    MAN8,
    MAN9,
    PIN1,
    PIN2,
    PIN3,
    PIN4,
    PIN5,
    PIN6,
    PIN7,
    PIN8,
    PIN9,
    SOU1,
    SOU2,
    SOU3,
    SOU4,
    SOU5,
    SOU6,
    SOU7,
    SOU8,
    SOU9,
    TON,
    NAN,
    SHAA,
    PEI,
    HAKU,
    HATSU,
    CHUN
}
