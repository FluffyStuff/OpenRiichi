class MainMenuBackgroundView : View2D
{
    private MainMenuBackgroundTileView tile_view = new MainMenuBackgroundTileView();
    private ImageControl background;
    private ImageControl text;

    public override void added()
    {
        background = new ImageControl("field_high");
        add_child(background);
        background.resize_style = ResizeStyle.RELATIVE;

        add_child(tile_view);
        tile_view.inner_anchor = Vec2(0, 0.5f);
        tile_view.outer_anchor = Vec2(0, 0.5f);

        text = new ImageControl("Menu/RiichiMahjong");
        add_child(text);
        text.inner_anchor = Vec2(0.5f, 1);
        text.outer_anchor = Vec2(0.5f, 1);
    }

    public override void resized()
    {
        tile_view.size = Size2(size.width / 3, size.height / 3);
    }
}

class MainMenuBackgroundTileView : View3D
{
    private RenderTile tile;
    private Camera camera = new Camera();
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();

    public MainMenuBackgroundTileView()
    {
        base();
    }

    public override void added()
    {
        resize_style = ResizeStyle.ABSOLUTE;

        string extension = "high";
        float tile_scale = 4f;

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

    public override void do_render_3D(RenderState state)
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
