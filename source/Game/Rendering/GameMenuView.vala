public class GameMenuView : View
{
    RenderObject2D menu;

    public GameMenuView()
    {

    }

    public override void added()
    {
        RenderTexture texture = store.load_texture("Tiles/Blank");
        menu = new RenderObject2D(texture);
    }

    public override void do_process(DeltaArgs delta)
    {
        Vec2 pos = menu.position;
        //pos = { pos.x + 0.001f, pos.y + 0.01f * 0 };
        menu.position = pos;

        menu.rotation += 0.01f;
    }

    public override void do_render(RenderState state)
    {
        RenderScene2D scene = new RenderScene2D(state.screen_width, state.screen_height);

        //scene.add_object(menu);

        state.add_scene(scene);
    }
}
