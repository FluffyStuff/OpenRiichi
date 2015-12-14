using Gee;

public class ScoringHandView : View3D
{
    private Scoring score;

    private ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
    private Camera camera = new Camera();
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();

    public ScoringHandView(Scoring score)
    {
        base();

        this.score = score;
        resize_style = ResizeStyle.ABSOLUTE;
    }

    public override void added()
    {
        string extension = "high";

        RenderModel model = store.load_model("tile_" + extension, true);
        float tile_scale = 1f;
        Vec3 tile_size = model.size.mul_scalar(tile_scale);

        for (int i = 0; i < score.player.hand.size; i++)
        {
            Tile t = score.player.hand[i];
            RenderTile tile = new RenderTile(store, extension, t, tile_scale);

            bool added = false;
            for (int j = 0; j < tiles.size; j++)
            {
                if (t.tile_type <= tiles[j].tile_type.tile_type)
                {
                    tiles.insert(j, tile);
                    added = true;
                    break;
                }
            }

            if (!added)
                tiles.add(tile);
        }

        for (int i = 0; i < tiles.size; i++)
            tiles[i].set_absolute_location(Vec3((i - (tiles.size + 1.0f) / 2 + 0.5f) * tile_size.x, 0, 0), Vec3(0.4f, 1, 0));

        RenderTile tile = new RenderTile(store, extension, score.round.win_tile, tile_scale);
        tile.set_absolute_location(Vec3((tiles.size + 1 - (tiles.size + 1.0f) / 2 + 0.5f) * tile_size.x, 0, 0), Vec3(0.4f, 1, 0));
        tiles.add(tile);

        float len = 15;
        camera.focal_length = 0.03f;

        Vec3 pos = Vec3(0, 0, len);
        camera.position = pos;

        light1.color = Color.white();
        light1.position = Vec3(len, len * 2, len);
        light1.intensity = 15;
        light2.color = Color.white();
        light2.position = Vec3(-len, len * 2, len);
        light2.intensity = 15;
    }

    public override void do_render_3D(RenderState state)
    {
        RenderScene3D scene = new RenderScene3D(state.screen_size, 10, rect);

        scene.set_camera(camera);
        scene.add_light_source(light1);
        scene.add_light_source(light2);

        for (int i = 0; i < tiles.size; i++)
            tiles[i].render(scene);

        state.add_scene(scene);
    }
}
