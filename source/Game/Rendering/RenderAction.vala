using Engine;
using Gee;

public abstract class RenderAction : Object
{
    protected RenderAction(AnimationTime time)
    {
        this.time = time;
    }

    public AnimationTime time { get; private set; }
}

public class RenderActionDelay : RenderAction
{
    public RenderActionDelay(AnimationTime time)
    {
        base(time);
    }
}

public class RenderActionSplitDeadWall : RenderAction
{
    public RenderActionSplitDeadWall(AnimationTime time)
    {
        base(time);
    }
}

public class RenderActionInitialDraw : RenderAction
{
    public RenderActionInitialDraw(AnimationTime time, RenderPlayer player, int tiles)
    {
        base(time);

        this.player = player;
        this.tiles = tiles;
    }

    public RenderPlayer player { get; private set; }
    public int tiles { get; private set; }
}

public class RenderActionDraw : RenderAction
{
    public RenderActionDraw(AnimationTime time, RenderPlayer player)
    {
        base(time);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionDrawDeadWall : RenderAction
{
    public RenderActionDrawDeadWall(AnimationTime time, RenderPlayer player)
    {
        base(time);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionDiscard : RenderAction
{
    public RenderActionDiscard(AnimationTime time, RenderPlayer player, RenderTile tile)
    {
        base(time);

        this.player = player;
        this.tile = tile;
    }

    public RenderPlayer player { get; private set; }
    public RenderTile tile { get; private set; }
}

public class RenderActionRon : RenderAction
{
    private RenderPlayer[] winners;

    public RenderActionRon(AnimationTime time, RenderPlayer[] winners, RenderPlayer? discarder, RenderTile? tile, RenderPlayer? return_riichi_player, bool allow_dora_flip)
    {
        base(time);

        this.winners = winners;
        this.discarder = discarder;
        this.tile = tile;
        this.return_riichi_player = return_riichi_player;
        this.allow_dora_flip = allow_dora_flip;
    }

    public RenderPlayer[] get_winners()
    {
        return winners;
    }
    public RenderPlayer? discarder { get; private set; }
    public RenderTile? tile { get; private set; }
    public RenderPlayer? return_riichi_player { get; private set; }
    public bool allow_dora_flip { get; private set; }
}

public class RenderActionTsumo : RenderAction
{
    public RenderActionTsumo(AnimationTime time, RenderPlayer player)
    {
        base(time);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionRiichi : RenderAction
{
    public RenderActionRiichi(AnimationTime time, RenderPlayer player, bool open)
    {
        base(time);

        this.player = player;
        this.open = open;
    }

    public RenderPlayer player { get; private set; }
    public bool open { get; private set; }
}

public class RenderActionReturnRiichi : RenderAction
{
    public RenderActionReturnRiichi(AnimationTime time, RenderPlayer player)
    {
        base(time);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionLateKan : RenderAction
{
    public RenderActionLateKan(AnimationTime time, RenderPlayer player, RenderTile tile)
    {
        base(time);

        this.player = player;
        this.tile = tile;
    }

    public RenderPlayer player { get; private set; }
    public RenderTile tile { get; private set; }
}

public class RenderActionClosedKan : RenderAction
{
    public RenderActionClosedKan(AnimationTime time, RenderPlayer player, TileType tile_type)
    {
        base(time);

        this.player = player;
        this.tile_type = tile_type;
    }

    public RenderPlayer player { get; private set; }
    public TileType tile_type { get; private set; }
}

public class RenderActionOpenKan : RenderAction
{
    public RenderActionOpenKan(AnimationTime time, RenderPlayer player, RenderPlayer discarder, RenderTile tile, RenderTile tile_1, RenderTile tile_2, RenderTile tile_3)
    {
        base(time);

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
    public RenderActionPon(AnimationTime time, RenderPlayer player, RenderPlayer discarder, RenderTile tile, RenderTile tile_1, RenderTile tile_2)
    {
        base(time);

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
    public RenderActionChii(AnimationTime time, RenderPlayer player, RenderPlayer discarder, RenderTile tile, RenderTile tile_1, RenderTile tile_2)
    {
        base(time);

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
    public RenderActionGameDraw(AnimationTime time, ArrayList<RenderPlayer> players, GameDrawType draw_type)
    {
        base(time);

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
        base(new AnimationTime.zero());

        this.active = active;
    }

    public bool active { get; private set; }
}

public class RenderActionHandReveal : RenderAction
{
    public RenderActionHandReveal(AnimationTime time, RenderPlayer player)
    {
        base(time);

        this.player = player;
    }

    public RenderPlayer player { get; private set; }
}

public class RenderActionFlipDora : RenderAction
{
    public RenderActionFlipDora()
    {
        base(new AnimationTime.zero());
    }
}

public class RenderActionFlipUraDora : RenderAction
{
    public RenderActionFlipUraDora(AnimationTime time)
    {
        base(time);
    }
}
