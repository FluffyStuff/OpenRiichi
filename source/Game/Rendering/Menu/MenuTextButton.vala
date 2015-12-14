class MenuTextButton : Control
{
    private ImageControl button;
    private LabelControl label;
    private string name;
    private string text;

    public MenuTextButton(string name, string text)
    {
        this.name = name;
        this.text = text;
    }

    public override void added()
    {
        button = new ImageControl("Buttons/" + name);
        add_child(button);
        button.resize_style = ResizeStyle.RELATIVE;

        label = new LabelControl();
        add_child(label);
        label.text = text;
        selectable = true;

        resize_style = ResizeStyle.ABSOLUTE;
        size = button.end_size;
    }

    public override void do_render(RenderState state, RenderScene2D scene)
    {
        if (!enabled)
        {
            button.diffuse_color = Color.with_alpha(0.05f);
            label.color = Color(1, 1, 1, 0.05f);
        }
        else
        {
            if (hovering)
            {
                if (mouse_down)
                {
                    button.diffuse_color = Color(0.2f, 0.2f, 0.05f, 1);
                    label.color = Color(1.2f, 1.2f, 1.05f, 1);
                }
                else
                {
                    button.diffuse_color = Color(0.4f, 0.4f, 0.2f, 1);
                    label.color = Color(1.4f, 1.4f, 1.2f, 1);
                }
            }
            else
            {
                button.diffuse_color = Color.with_alpha(1);
                label.color = Color(1, 1, 1, 1);
            }
        }
    }
}
