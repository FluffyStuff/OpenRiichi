using Gee;

public abstract class RenderAction : Object
{
    public RenderAction(float time)
    {
        this.time = time;
    }

    public float time { get; private set; }
}

public class RenderActionDelay : RenderAction
{
    public RenderActionDelay(float delay)
    {
        base(delay);
    }
}

public class RenderActionSplitDeadWall : RenderAction
{
    public RenderActionSplitDeadWall()
    {
        base(0.5f);
    }
}

public class RenderActionInitialDraw : RenderAction
{
    public RenderActionInitialDraw(RenderPlayer player, int tiles)
    {
        base(0.1f);

        this.player = player;
        this.tiles = tiles;
    }

    public RenderPlayer player { get; private set; }
    public int tiles { get; private set; }
}

public class RenderActionDraw : RenderAction
{
    public RenderActionDraw(RenderPlayer player)
    {
        base(0.5f);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionDrawDeadWall : RenderAction
{
    public RenderActionDrawDeadWall(RenderPlayer player)
    {
        base(0.5f);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionDiscard : RenderAction
{
    public RenderActionDiscard(RenderPlayer player, RenderTile tile)
    {
        base(0.5f);

        this.player = player;
        this.tile = tile;
    }

    public RenderPlayer player { get; private set; }
    public RenderTile tile { get; private set; }
}

public class RenderActionRon : RenderAction
{
    public RenderActionRon(RenderPlayer[] winners, RenderPlayer? discarder, RenderTile? tile, RenderPlayer? return_riichi_player, bool allow_dora_flip)
    {
        base(0.5f);

        this.winners = winners;
        this.discarder = discarder;
        this.tile = tile;
        this.return_riichi_player = return_riichi_player;
        this.allow_dora_flip = allow_dora_flip;
    }

    public RenderPlayer[] winners { get; private set; }
    public RenderPlayer? discarder { get; private set; }
    public RenderTile? tile { get; private set; }
    public RenderPlayer? return_riichi_player { get; private set; }
    public bool allow_dora_flip { get; private set; }
}

public class RenderActionTsumo : RenderAction
{
    public RenderActionTsumo(RenderPlayer player)
    {
        base(0.5f);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionRiichi : RenderAction
{
    public RenderActionRiichi(RenderPlayer player, bool open)
    {
        base(0.5f);

        this.player = player;
        this.open = open;
    }

    public RenderPlayer player { get; private set; }
    public bool open { get; private set; }
}

public class RenderActionReturnRiichi : RenderAction
{
    public RenderActionReturnRiichi(RenderPlayer player)
    {
        base(0.5f);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionLateKan : RenderAction
{
    public RenderActionLateKan(RenderPlayer player, RenderTile tile)
    {
        base(0.2f);

        this.player = player;
        this.tile = tile;
    }

    public RenderPlayer player { get; private set; }
    public RenderTile tile { get; private set; }
}

public class RenderActionClosedKan : RenderAction
{
    public RenderActionClosedKan(RenderPlayer player, TileType tile_type)
    {
        base(0.2f);

        this.player = player;
        this.tile_type = tile_type;
    }

    public RenderPlayer player { get; private set; }
    public TileType tile_type { get; private set; }
}

public class RenderActionOpenKan : RenderAction
{
    public RenderActionOpenKan(RenderPlayer player, RenderPlayer discarder, RenderTile tile, RenderTile tile_1, RenderTile tile_2, RenderTile tile_3)
    {
        base(0.2f);

        this.player = player;
        this.discarder = discarder;
        this.tile = tile;
        this.tile_1 = tile_1;
        this.tile_2 = tile_2;
        this.tile_3 = tile_3;
    }

    public RenderPlayer player { get; private set; }
    public RenderPlayer discarder { get; private set; }
    public RenderTile tile { get; private set; }
    public RenderTile tile_1 { get; private set; }
    public RenderTile tile_2 { get; private set; }
    public RenderTile tile_3 { get; private set; }
}

public class RenderActionPon : RenderAction
{
    public RenderActionPon(RenderPlayer player, RenderPlayer discarder, RenderTile tile, RenderTile tile_1, RenderTile tile_2)
    {
        base(0.5f);

        this.player = player;
        this.discarder = discarder;
        this.tile = tile;
        this.tile_1 = tile_1;
        this.tile_2 = tile_2;
    }

    public RenderPlayer player { get; private set; }
    public RenderPlayer discarder { get; private set; }
    public RenderTile tile { get; private set; }
    public RenderTile tile_1 { get; private set; }
    public RenderTile tile_2 { get; private set; }
}

public class RenderActionChii : RenderAction
{
    public RenderActionChii(RenderPlayer player, RenderPlayer discarder, RenderTile tile, RenderTile tile_1, RenderTile tile_2)
    {
        base(0.5f);

        this.player = player;
        this.discarder = discarder;
        this.tile = tile;
        this.tile_1 = tile_1;
        this.tile_2 = tile_2;
    }

    public RenderPlayer player { get; private set; }
    public RenderPlayer discarder { get; private set; }
    public RenderTile tile { get; private set; }
    public RenderTile tile_1 { get; private set; }
    public RenderTile tile_2 { get; private set; }
}

public class RenderActionGameDraw : RenderAction
{
    public RenderActionGameDraw(ArrayList<RenderPlayer> players, GameDrawType draw_type)
    {
        base(0.5f);

        this.players = players;
        this.draw_type = draw_type;
    }

    public ArrayList<RenderPlayer> players { get; private set; }
    public GameDrawType draw_type { get; private set; }
}

public class RenderActionSetActive : RenderAction
{
    public RenderActionSetActive(bool active)
    {
        base(0);

        this.active = active;
    }

    public bool active { get; private set; }
}

public class RenderActionHandReveal : RenderAction
{
    public RenderActionHandReveal(RenderPlayer player)
    {
        base(0.5f);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionFlipDora : RenderAction
{
    public RenderActionFlipDora()
    {
        base(0);
    }
}

public class RenderActionFlipUraDora : RenderAction
{
    public RenderActionFlipUraDora()
    {
        base(0.5f);
    }
}
