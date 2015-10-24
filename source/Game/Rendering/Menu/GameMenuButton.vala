class GameMenuButton : Control
{
    private RenderImage2D button;

    public GameMenuButton(IResourceStore store, string name)
    {
        base();

        RenderTexture texture = store.load_texture("Buttons/" + name);
        button = new RenderImage2D(texture);
    }

    public override void do_resize(Vec2 new_position, Size2 new_scale)
    {
        button.position = new_position;
        button.scale = new_scale;
    }

    public override void do_render(RenderScene2D scene)
    {
        if (!enabled)
        {
            button.diffuse_color = Color.with_alpha(0.05f);
        }
        else
        {
            if (hovering)
                button.diffuse_color = Color(0.5f, 0.5f, 0.3f, 1);
            else
                button.diffuse_color = Color.with_alpha(1);
        }

        scene.add_object(button);
    }

    public override Size2 size { get { return Size2(button.texture.size.width, button.texture.size.height); } }
}
