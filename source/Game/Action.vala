// TODO: Superclass/Subclass

public class TurnAction
{
    public TurnAction.discard(uint8 discard_tile)
    {
        action = TurnActionEnum.DISCARD;
        this.discard_tile = discard_tile;
    }

    public TurnAction.closed_kan(uint8[] kan)
    {
        action = TurnActionEnum.CLOSED_KAN;
        kan_tiles = kan;
    }

    public TurnAction.late_kan(uint8 kan_tile, uint8 pon)
    {
        action = TurnActionEnum.LATE_KAN;
        late_kan_tile = kan_tile;
        late_kan_pon = pon;
    }

    public TurnAction.riichi(uint8 discard_tile)
    {
        action = TurnActionEnum.RIICHI;
        this.discard_tile = discard_tile;
    }

    public TurnAction.open_riichi(uint8 discard_tile)
    {
        action = TurnActionEnum.OPEN_RIICHI;
        this.discard_tile = discard_tile;
    }

    public TurnAction.tsumo()
    {
        action = TurnActionEnum.TSUMO;
    }

    public TurnAction.set(TurnActionEnum action, uint8? discard_tile, uint8? late_kan_tile, uint8? late_kan_pon, uint8[]? kan_tiles)
    {
        this.action = action;
        this.discard_tile = discard_tile;
        this.late_kan_tile = late_kan_tile;
        this.late_kan_pon = late_kan_pon;
        this.kan_tiles = kan_tiles;
    }

    public TurnActionEnum action { get; private set; }
    public uint8? discard_tile { get; private set; }
    public uint8? late_kan_tile { get; private set; }
    public uint8? late_kan_pon { get; private set; }
    public uint8[]? kan_tiles { get; private set; }

    public enum TurnActionEnum
    {
        DISCARD,
        CLOSED_KAN,
        LATE_KAN,
        RIICHI,
        OPEN_RIICHI,
        TSUMO
    }
}

public class CallAction
{
    public CallAction.none()
    {
        action = CallActionEnum.NONE;
        tiles = null;
    }

    public CallAction.ron(uint8 tile)
    {
        action = CallActionEnum.RON;
        ron_tile = tile;
    }

    public CallAction(CallActionEnum action, uint8[]? tiles)
    {
        this.action = action;
        this.tiles = tiles;
    }

    public CallAction.set(CallActionEnum action, uint8[]? tiles, uint8? ron_tile)
    {
        this.action = action;
        this.tiles = tiles;
        this.ron_tile = ron_tile;
    }

    public CallActionEnum action { get; private set; }
    public uint8[] tiles { get; private set; }
    public uint8? ron_tile { get; private set; }

    public enum CallActionEnum
    {
        NONE,
        OPEN_KAN,
        PON,
        CHI,
        RON
    }
}
