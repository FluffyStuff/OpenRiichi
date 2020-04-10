using Engine;
using Gee;

private class RenderHand : WorldObject
{
    private GameRenderContext context;
    private int drawn;
    private Vec3 tile_size;
    private WorldObject wrap;

    public RenderHand(GameRenderContext context, float view_angle)
    {
        tiles = new ArrayList<RenderTile>();
        this.context = context;
        this.tile_size = context.tile_size;
        this.view_angle = view_angle;
        last_drawn_tile = null;
    }

    public override void added()
    {
        rotation = Quat.from_euler(0, 0.5f - view_angle, 0);
        wrap = new WorldObject();
        add_object(wrap);
        wrap.position = Vec3(0, tile_size.y / 2, -tile_size.z / 2);
    }

    public void draw_tile(RenderTile tile)
    {
        wrap.convert_object(tile);
        drawn++;

        if (tiles.size > 1 && drawn >= 14)
        {
            sort_hand();
            order_hand(true);
            order_draw_tile(tile);
            tiles.add(tile);
        }
        else
        {
            tiles.add(tile);
            sort_hand();
            order_hand(true);
        }

        last_drawn_tile = tile;
    }

    public void remove(RenderTile tile)
    {
        tiles.remove(tile);
        sort_hand();
        order_hand(true);
    }

    public ArrayList<RenderTile> get_tiles_type(TileType type)
    {
        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();

        foreach (RenderTile tile in this.tiles)
            if (tile.tile_type.tile_type == type)
                tiles.add(tile);

        return tiles;
    }

    public void sort_hand()
    {
        tiles = RenderTile.sort_tiles(tiles);
    }

    public void order_hand(bool animate)
    {
        for (int i = 0; i < tiles.size; i++)
            order_tile(tiles[i], i, animate);
    }

    public void ron(RenderTile tile)
    {
        //animate_open();
    }

    public void tsumo()
    {
        order_tile(last_drawn_tile, tiles.size + 0.5f, true);
    }

    public void open_hand()
    {
        open = true;
        animate_open();
    }

    private void animate_open()
    {
        WorldObjectAnimation animation = new WorldObjectAnimation(context.server_times.hand_reveal);
        PathQuat rot = new LinearPathQuat(Quat());
        animation.do_absolute_rotation(rot);
        animation.curve = new SmoothDepartCurve();
        
        cancel_buffered_animations();
        animate(animation, true);
    }

    public void close_hand()
    {
        WorldObjectAnimation animation = new WorldObjectAnimation(context.server_times.hand_reveal);
        PathQuat rot = new LinearPathQuat(Quat.from_euler(0, 1, 0));
        animation.do_absolute_rotation(rot);
        animation.curve = new SmoothDepartCurve();
        cancel_buffered_animations();
        animate(animation, true);

        animation = new WorldObjectAnimation(context.server_times.hand_reveal);
        Path3D path = new LinearPath3D(Vec3(0, -tile_size.y / 2, -tile_size.z / 2));
        animation.do_absolute_position(path);
        animation.curve = new SmoothDepartCurve();
        wrap.animate(animation, true);
    }

    public void animate_angle(float angle)
    {
        if (open)
            return;

        WorldObjectAnimation animation = new WorldObjectAnimation(context.server_times.hand_angle);
        PathQuat rot = new LinearPathQuat(Quat.from_euler(0, 0.5f - angle, 0));
        animation.do_absolute_rotation(rot);
        animation.curve = new SCurve(0.5f);

        cancel_buffered_animations();
        animate(animation, true);
    }

    private void order_tile(RenderTile tile, float tile_position, bool animate)
    {
        Vec3 pos = Vec3((tile_position - (tiles.size - 1) / 2.0f) * tile_size.x, 0, 0);

        if (animate)
            tile.animate_towards(pos, Quat(), context.server_times.hand_order);
        else
            tile.set_absolute_location(pos, Quat());
    }

    private void order_draw_tile(RenderTile tile)
    {
        Vec3 pos = Vec3
        (
            (tiles.size / 2.0f - 1) * tile_size.x,
            0,
            -(tile_size.z + tile_size.x) / 2
        );

        Quat rot = Quat.from_euler(0.5f, 0, 0);

        tile.animate_towards(pos, rot, context.server_times.tile_draw);
    }

    public ArrayList<RenderTile> tiles { get; private set; }
    public float view_angle { get; set; }
    public RenderTile? last_drawn_tile { get; private set; }
    public bool open { get; set; }  // Open riichi
}