public class Tile
{
    public Tile(int ID, TileType type, bool dora)
    {
        this.ID = ID;
        tile_type = type;
        this.dora = dora;
    }

    public int ID { get; set; }
    public TileType tile_type { get; set; }
    public bool dora { get; set; }
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
    KITA,
    HIGASHI,
    MINAMI,
    NISHI,
    HAKU,
    HATSU,
    CHUN
}
