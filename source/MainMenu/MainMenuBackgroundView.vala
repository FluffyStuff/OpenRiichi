class MainMenuBackgroundView : View
{
    private Scoring score;

    private RenderTile tile;
    private Camera camera = new Camera();
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();

    public MainMenuBackgroundView()
    {
        base();
        resize_style = ResizeStyle.ABSOLUTE;
    }

    public override void added()
    {
        string extension = "high";

        RenderModel model = store.load_model("tile_" + extension, true);
        float tile_scale = 4f;
        Vec3 tile_size = model.size.mul_scalar(tile_scale);

        Tile t = new Tile(0, TileType.PIN1, false);
        tile = new RenderTile(store, extension, t, tile_scale);
        tile.set_absolute_location(Vec3(0, 0, 0), Vec3(0, 0, 0));

        float len = 3;
        camera.focal_length = 0.8f;

        Vec3 pos = Vec3(0, 0, len);
        camera.position = pos;

        light1.color = Color.white();
        light1.position = Vec3(len, len, len / 2);
        light1.intensity = 5;
        light2.color = Color.white();
        light2.position = Vec3(-len, len, len / 2);
        light2.intensity = 5;
    }

    public override void do_process(DeltaArgs delta)
    {
        float r = delta.time;
        tile.set_absolute_location(Vec3(0, 0, 0), Vec3(-0.2f, r * 0.1f, 0));
    }

    public override void do_render(RenderState state)
    {
        window.renderer.shader_3D = "open_gl_shader_3D_high";
        RenderScene3D scene = new RenderScene3D(state.screen_size, 1, rect);

        scene.set_camera(camera);
        scene.add_light_source(light1);
        scene.add_light_source(light2);

        tile.render(scene);

        state.add_scene(scene);
    }
}
