class ImageControl : Control
{
    private RenderImage2D image;

    public ImageControl(IResourceStore store, string name)
    {
        base();

        RenderTexture texture = store.load_texture(name, false);
        image = new RenderImage2D(texture);
    }

    public override void do_resize(Vec2 new_position, Size2 new_scale)
    {
        image.position = new_position;
        image.scale = new_scale;
    }

    public override void do_render(RenderScene2D scene)
    {
        scene.add_object(image);
    }

    public override Size2 size { get { return Size2(image.texture.size.width, image.texture.size.height); } }
}
