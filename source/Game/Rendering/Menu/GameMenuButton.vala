using Engine;

class GameMenuButton : Control
{
    private ImageControl? button = null;
    private string name;

    private Sound click_sound;
    private Sound hover_sound;

    public GameMenuButton(string name)
    {
        this.name = name;
        selectable = true;
    }

    public override void added()
    {
        click_sound = store.audio_player.load_sound("click");
        hover_sound = store.audio_player.load_sound("mouse_over");

        resize_style = ResizeStyle.ABSOLUTE;

        button = new ImageControl("Buttons/" + name);
        add_child(button);
        button.resize_style = ResizeStyle.RELATIVE;
        size = button.end_size;
    }

    public override void render(RenderState state, RenderScene2D scene)
    {
        if (!enabled)
        {
            button.diffuse_color = Color.with_alpha(0.1f);
        }
        else
        {
            if (hovering)
            {
                if (mouse_pressed)
                    button.diffuse_color = Color(0.3f, 0.3f, 0.1f, 1);
                else
                    button.diffuse_color = Color(0.5f, 0.5f, 0.3f, 1);
            }
            else
                button.diffuse_color = Color.with_alpha(1);
        }
    }

    protected override void resized()
    {
        if (button != null)
            button.size = size;
    }

    protected override void on_mouse_over()
    {
        hover_sound.play();
    }

    protected override void on_click(Vec2 position)
    {
        click_sound.play();
    }
}
