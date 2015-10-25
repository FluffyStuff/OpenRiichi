public class RectangleControl : Control
{
    private RenderRectangle2D rectangle;
    private Size2 _size = Size2(100, 100);

    public RectangleControl()
    {
        base();

        rectangle = new RenderRectangle2D();
    }

    public override void do_render(RenderScene2D scene)
    {
        scene.add_object(rectangle);
    }

    public override void do_resize(Vec2 new_position, Size2 new_scale)
    {
        rectangle.position = new_position;
        rectangle.scale = new_scale;
    }

    public void set_size(Size2 size)
    {
        _size = size;
    }

    public override Size2 size { get { return _size; } }

    public Color diffuse_color
    {
        get { return rectangle.diffuse_color; }
        set { rectangle.diffuse_color = value; }
    }
}
