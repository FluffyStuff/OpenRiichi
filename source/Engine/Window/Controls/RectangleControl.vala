public class RectangleControl : EndControl
{
    private RenderRectangle2D rectangle;

    public RectangleControl()
    {
        base();
        rectangle = new RenderRectangle2D();
    }

    public Color color
    {
        get { return rectangle.diffuse_color; }
        set { rectangle.diffuse_color = value; }
    }

    public override void render_end(RenderScene2D scene)
    {
        scene.add_object(rectangle);
    }

    public override void set_end_rect(Rectangle rect)
    {
        rectangle.position = rect.position;
        rectangle.scale = rect.size;
    }

    public override Size2 end_size { get { return Size2(100, 100); } }
}
