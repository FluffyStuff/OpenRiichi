class ImageControl : EndControl
{
    private RenderImage2D image;
    private string name;

    public ImageControl(string name)
    {
        this.name = name;
    }

    public override void on_added()
    {
        RenderTexture texture = store.load_texture(name, false);
        image = new RenderImage2D(texture);
    }

    public Color diffuse_color
    {
        get { return image.diffuse_color; }
        set { image.diffuse_color = value; }
    }

    public override void set_end_rect(Rectangle rect)
    {
        image.position = rect.position;
        image.scale = rect.size;
    }

    protected override void render_end(RenderScene2D scene)
    {
        scene.add_object(image);
    }

    public override Size2 end_size { get { return Size2(image.texture.size.width, image.texture.size.height); } }
}
