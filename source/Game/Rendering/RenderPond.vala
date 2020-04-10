using Engine;
using Gee;

private class RenderPond : WorldObject
{
    private GameRenderContext context;
    private Vec3 tile_size;

    private WorldObject wrap;
    private ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
    private RenderTile? riichi_tile = null;
    private bool do_riichi = false;

    public RenderPond(GameRenderContext context)
    {
        this.context = context;
        this.tile_size = context.tile_size;
    }

    protected override void added()
    {
        wrap = new WorldObject();
        add_object(wrap);
        wrap.position = Vec3(-tile_size.x / 2, tile_size.y / 2, tile_size.z / 2);
    }

    public void add_tile(RenderTile tile)
    {
        convert_object(tile);

        if (do_riichi)
        {
            riichi_tile = tile;
            do_riichi = false;
        }

        tiles.add(tile);
        arrange_pond();
    }

    public void remove(RenderTile tile)
    {
        tiles.remove(tile);
        arrange_pond();

        if (tile == riichi_tile)
            do_riichi = true;
    }

    public void riichi()
    {
        do_riichi = true;
    }

    private void arrange_pond()
    {
        // Top left corner
        float width = -3 * tile_size.x;
        float height = 0;

        for (int i = 0; i < tiles.size; i++)
        {
            RenderTile tile = tiles[i];

            if (i == 6)
            {
                width = -3 * tile_size.x;
                height = tile_size.z;
            }
            else if (i == 12)
            {
                width = -3 * tile_size.x;
                height = 2 * tile_size.z;
            }

            float x;
            float y;
            float r = 0;

            if (tile == riichi_tile)
            {
                x = width + tile_size.z / 2;
                y = height + tile_size.z - tile_size.x / 2;
                r = 0.5f;

                width += tile_size.z;
            }
            else
            {
                x = width + tile_size.x / 2;
                y = height + tile_size.z / 2;

                width += tile_size.x;
            }

            Vec3 pos = Vec3(x, 0, y);
            Quat rot = Quat.from_euler(r, 0, 0);

            tile.animate_towards(pos, rot, context.server_times.tile_discard);
        }
    }
}