// TODO: Superclass/Subclass

public class TurnAction
{
    public TurnAction.discard(Tile discard_tile)
    {
        action = TurnActionEnum.DISCARD;
        this.discard_tile = discard_tile;
    }

    public TurnAction.closed_kan(Tile[] kan)
    {
        action = TurnActionEnum.CLOSED_KAN;
        kan_tiles = kan;
    }

    public TurnAction.late_kan(Tile kan_tile, Pon pon)
    {
        action = TurnActionEnum.LATE_KAN;
        late_kan_tile = kan_tile;
        late_kan_pon = pon;
    }

    public TurnAction.riichi(Tile discard_tile)
    {
        action = TurnActionEnum.RIICHI;
        this.discard_tile = discard_tile;
    }

    public TurnAction.open_riichi(Tile discard_tile)
    {
        action = TurnActionEnum.OPEN_RIICHI;
        this.discard_tile = discard_tile;
    }

    public TurnAction.tsumo()
    {
        action = TurnActionEnum.TSUMO;
    }

    public TurnActionEnum action { get; private set; }
    public Tile? discard_tile { get; private set; }
    public Tile? late_kan_tile { get; private set; }
    public Pon? late_kan_pon { get; private set; }
    public Tile[]? kan_tiles { get; private set; }

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

    public CallAction.ron(Tile tile)
    {
        action = CallActionEnum.RON;
        ron_tile = tile;
    }

    public CallAction(CallActionEnum action, Tile[]? tiles)
    {
        this.action = action;
        this.tiles = tiles;
    }

    public CallActionEnum action { get; private set; }
    public Tile[] tiles { get; private set; }
    public Tile ron_tile { get; private set; }

    public enum CallActionEnum
    {
        NONE,
        OPEN_KAN,
        PON,
        CHI,
        RON
    }
}
