using Engine;
using Gee;

public class ScoringDoraView : View3D
{
    private ArrayList<Tile> tile_list;
    private int front_tiles;
    private int back_tiles;

    private ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
    private float width = 1;

    public ScoringDoraView(ArrayList<Tile> tile_list, int front_tiles, int back_tiles)
    {
        this.tile_list = tile_list;
        this.front_tiles = front_tiles;
        this.back_tiles = back_tiles;
        resize_style = ResizeStyle.ABSOLUTE;
    }

    public override void added()
    {
        Options options = new Options.from_disk();

        RenderTile size_tile = new RenderTile();
        world.add_object(size_tile);
        Vec3 tile_size = size_tile.obb;
        world.remove_object(size_tile);

        width = (tile_list.size + front_tiles + back_tiles) * tile_size.x;
        float p = (tile_size.x - width) / 2;

        for (int i = 0; i < tile_list.size + front_tiles + back_tiles; i++)
        {
            bool revealed = i >= front_tiles && i < front_tiles + tile_list.size && tile_list[i - front_tiles].tile_type != TileType.BLANK;
            Tile t = revealed ? tile_list[i - front_tiles] : new Tile(-1, TileType.BLANK, false);
            RenderTile tile = new RenderTile()
            {
                tile_type = t,
                model_quality = options.model_quality,
                texture_type = options.tile_textures
            };
            world.add_object(tile);

            tiles.add(tile);

            tile.set_absolute_location(Vec3(p, 0, 0), Quat.from_euler(0, 0, revealed ? 0 : 1));
            tile.front_color = options.tile_fore_color;
            tile.back_color = options.tile_back_color;
            p += tile_size.x;
        }

        float len = 2;

        Vec3 pos = Vec3(0, len, len);

        WorldObject target = new WorldObject();
        world.add_object(target);
        WorldCamera camera = new TargetWorldCamera(target);
        world.add_object(camera);
        world.active_camera = camera;
        camera.position = pos;

        WorldLight light1 = new WorldLight();
        WorldLight light2 = new WorldLight();
        world.add_object(light1);
        world.add_object(light2);

        light1.color = Color.white();
        light1.position = Vec3(len, len * 2, len);
        light1.intensity = 3;
        light2.color = light1.color;
        light2.position = Vec3(-len, len * 2, len);
        light2.intensity = light1.intensity;
    }

    public float alpha
    {
        set
        {
            foreach (RenderTile tile in tiles)
                tile.alpha = value;
        }
    }
}
