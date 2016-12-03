using Gee;

public class ScoringDoraView : View3D
{
    private ArrayList<Tile> tile_list;
    private int front_tiles;
    private int back_tiles;

    private ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
    private Camera camera = new Camera();
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();
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
        /*RectangleControl rect = new RectangleControl();
        add_child(rect);
        rect.resize_style = ResizeStyle.RELATIVE;
        rect.color = Color(1, 0, 0, 0.1f);*/

        Options options = new Options.from_disk();

        string extension = Options.quality_enum_to_string(options.model_quality);
        string texture_type = options.tile_textures;
        float tile_scale = 1.55f;

        RenderGeometry3D model = store.load_geometry_3D("tile_" + extension, false);
        Vec3 tile_size = ((RenderBody3D)model.geometry[0]).model.size;
        tile_size = Vec3(tile_size.x, tile_size.y + ((RenderBody3D)model.geometry[1]).model.size.y, tile_size.z).mul_scalar(tile_scale);

        width = (tile_list.size + front_tiles + back_tiles) * tile_size.x;
        float p = (tile_size.x - width) / 2;

        for (int i = 0; i < tile_list.size + front_tiles + back_tiles; i++)
        {
            bool revealed = i >= front_tiles && i < front_tiles + tile_list.size && tile_list[i - front_tiles].tile_type != TileType.BLANK;
            Tile t = revealed ? tile_list[i - front_tiles] : new Tile(-1, TileType.BLANK, false);
            RenderTile tile = new RenderTile(store, extension, texture_type, t, tile_scale);
            tiles.add(tile);

            tile.set_absolute_location(Vec3(p, 0, 0), new Quat.from_euler(revealed ? 0 : 1, 1, 0));
            tile.front_color = options.tile_fore_color;
            tile.back_color = options.tile_back_color;
            p += tile_size.x;
        }

        float len = 15;
        camera.focal_length = 0.03f;

        Vec3 pos = Vec3(0, len, len);
        camera.position = pos;
        camera.pitch = -0.25f;
        camera.roll = 0;

        light1.color = Color.white();
        light1.position = Vec3(len, len * 2, -len);
        light1.intensity = 15;
        light2.color = Color.white();
        light2.position = Vec3(-len, len * 2, -len);
        light2.intensity = 15;
    }

    public override void do_render_3D(RenderState state)
    {
        RenderScene3D scene = new RenderScene3D(state.screen_size, 1.31f * width, rect);

        scene.set_camera(camera);
        scene.add_light_source(light1);
        scene.add_light_source(light2);

        for (int i = 0; i < tiles.size; i++)
            tiles[i].render(scene);

        state.add_scene(scene);
    }

    /*float mul = 1;
    float pitch;
    protected override void do_key_press(KeyArgs key)
    {
        pitch = camera.pitch;

        if (key.keycode == KeyCode.NUM_0)
            mul += 0.001f;
        else if (key.keycode == KeyCode.NUM_1)
            mul -= 0.001f;
        else if (key.keycode == KeyCode.NUM_2)
            pitch += 0.001f;
        else if (key.keycode == KeyCode.NUM_3)
            pitch -= 0.001f;

        camera.pitch = pitch;
    }*/
}
