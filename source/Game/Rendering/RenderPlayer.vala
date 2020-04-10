using Engine;
using Gee;

public class RenderPlayer : WorldObject
{
    private const float VIEW_ANGLE = 0.44f;

    private GameRenderContext context;
    private bool dealer;
    private Vec3 tile_size;
    private float hand_offset;
    private Vec3 riichi_offset;
    private bool observed;
    private Wind wind;

    private RenderHand hand;
    private RenderPond pond;
    private RenderCalls calls;
    private RenderStick render_riichi;

    public RenderPlayer(GameRenderContext context, int seat, bool dealer, float hand_offset, Vec3 riichi_offset, bool observed, Wind wind)
    {
        this.context = context;
        this.dealer = dealer;
        this.hand_offset = hand_offset;
        this.riichi_offset = riichi_offset;
        this.seat = seat;
        this.tile_size = context.tile_size;
        this.observed = observed;
        this.wind = wind;
    }

    protected override void added()
    {
        hand = new RenderHand(context, observed ? VIEW_ANGLE : 0);
        add_object(hand);
        hand.position = Vec3(0, 0, hand_offset);

        pond = new RenderPond(context);
        add_object(pond);
        pond.position = Vec3(0, tile_size.y / 2, 3 * tile_size.x);

        calls = new RenderCalls(context);
        add_object(calls);
        calls.position = Vec3(hand_offset, tile_size.y / 2, hand_offset);

        render_riichi = new RenderStick(RenderStick.StickType.STICK_1000);
        add_object(render_riichi);
        float scale = tile_size.x / render_riichi.obb.x * 4;
        render_riichi.scale = Vec3(scale, scale, scale);
        render_riichi.visible = false;
        render_riichi.position = Vec3(0, 0, hand_offset);

        if (dealer)
        {
            var indicator = new RenderWindIndicator(wind);
            add_object(indicator);
            indicator.position = Vec3(hand_offset - indicator.obb.x / 2 - tile_size.x * 3 - tile_size.z, indicator.obb.y / 2, hand_offset);
        }
    }

    public void draw_tile(RenderTile tile)
    {
        hand.draw_tile(tile);
    }

    public void discard(RenderTile tile)
    {
        hand.remove(tile);
        pond.add_tile(tile);
    }

    public void rob_tile(RenderTile tile)
    {
        pond.remove(tile);
    }

    public void ron(RenderTile tile)
    {
        hand.ron(tile);
    }

    public void tsumo()
    {
        hand.tsumo();
    }

    public void open_hand()
    {
        hand.open_hand();
    }

    public void close_hand()
    {
        hand.close_hand();
    }

    public void riichi(bool open)
    {
        render_riichi.visible = true;

        WorldObjectAnimation animation = new WorldObjectAnimation(new AnimationTime.preset(0.3f));
        Vec3 position = Vec3(0, riichi_offset.y, riichi_offset.z);
        Path3D path = new LinearPath3D(position);
        animation.do_absolute_position(path);
        animation.curve = new SmoothApproachCurve();

        render_riichi.animate(animation);

        pond.riichi();
        in_riichi = true;

        if (open)
            hand.open_hand();
    }

    public void return_riichi(AnimationTime time)
    {
        WorldObjectAnimation animation = new WorldObjectAnimation(new AnimationTime.preset(0.3f));
        Vec3 position = Vec3(0, riichi_offset.y, hand_offset);
        Path3D path = new LinearPath3D(position);
        animation.do_absolute_position(path);
        animation.curve = new SmoothApproachCurve();

        render_riichi.animate(animation);
    }

    public void late_kan(RenderTile tile, AnimationTime time)
    {
        hand.remove(tile);
        var pon = calls.get_pon(tile.tile_type.tile_type);
        var alignment = pon.alignment;

        calls.late_kan(pon, new RenderCalls.RenderCallLateKan(pon.tiles, tile, tile_size, alignment));
    }

    public void closed_kan(TileType type, AnimationTime time)
    {
        ArrayList<RenderTile> tiles = hand.get_tiles_type(type);

        foreach (RenderTile tile in tiles)
            hand.remove(tile);

        calls.add_call(new RenderCalls.RenderCallClosedKan(tiles, tile_size));
    }

    public void open_kan(RenderPlayer discard_player, RenderTile discard_tile, RenderTile tile_1, RenderTile tile_2, RenderTile tile_3)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);
        hand.remove(tile_3);

        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add(tile_1);
        tiles.add(tile_2);
        tiles.add(tile_3);

        var alignment = RenderCalls.players_to_alignment(this, discard_player);
        calls.add_call(new RenderCalls.RenderCallOpenKan(tiles, discard_tile, tile_size, alignment));
    }

    public void pon(RenderPlayer discard_player, RenderTile discard_tile, RenderTile tile_1, RenderTile tile_2)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);

        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add(tile_1);
        tiles.add(tile_2);

        var alignment = RenderCalls.players_to_alignment(this, discard_player);
        calls.add_call(new RenderCalls.RenderCallPon(tiles, discard_tile, tile_size, alignment));
    }

    public void chii(RenderTile discard_tile, RenderTile tile_1, RenderTile tile_2, AnimationTime time)
    {
        hand.remove(tile_1);
        hand.remove(tile_2);

        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add(tile_1);
        tiles.add(tile_2);
        calls.add_call(new RenderCalls.RenderCallChii(tiles, discard_tile, tile_size));
    }

    public void set_observed(bool observed)
    {
        this.observed = observed;
        hand.animate_angle(observed ? VIEW_ANGLE : 0);
    }

    public ArrayList<RenderTile> hand_tiles { get { return hand.tiles; } }
    //public RenderTile last_drawn_tile { get; private set; }
    public int seat { get; private set; }
    public bool in_riichi { get; private set; }
    public bool open { get { return hand.open; } set { hand.open = value; } } // Open riichi
}

private class RenderWindIndicator : WorldObjectTransformable
{
    private Wind wind;

    public RenderWindIndicator(Wind wind)
    {
        this.wind = wind;
    }

    protected override void added()
    {
        RenderObject3D center_piece = store.load_geometry_3D("wind_indicator", false).geometry[0] as RenderObject3D;
        center_piece.material.textures[0] = store.load_texture("WindIndicators/" + WIND_TO_STRING(wind));
        set_object(center_piece);
    }

    public Vec3 riichi_offset { get; private set; }
}