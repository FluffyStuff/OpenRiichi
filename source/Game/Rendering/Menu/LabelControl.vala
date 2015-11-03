public class LabelControl : Control
{
    private RenderLabel2D label;

    public LabelControl(IResourceStore store)
    {
        base();

        label = store.create_label();
        label.text = "";
        label.font_size = 30;
        label.font_type = "Sans";
        color = Color.white();
    }

    public override void do_resize(Vec2 new_position, Size2 new_scale)
    {
        label.position = new_position;
        label.scale = new_scale;
    }

    public override void do_render(RenderScene2D scene)
    {
        scene.add_object(label);
    }

    public override Size2 size { get { return label.info.size.to_size2(); } }
    public Color color
    {
        get
        {
            Color d = label.diffuse_color;
            return Color(d.r + 1, d.g + 1, d.b + 1, d.a);
        }
        set
        {
            label.diffuse_color = Color(value.r - 1, value.g - 1, value.b - 1, value.a);
        }
    }

    public string font_type
    {
        get { return label.font_type; }
        set
        {
            label.font_type = value;
            resize();
        }
    }

    public float font_size
    {
        get { return label.font_size; } // Pixels
        set
        {
            label.font_size = value; // Pixels
            resize();
        }
    }

    public string text
    {
        get { return label.text; }
        set
        {
            label.text = value;
            resize();
        }
    }
}
