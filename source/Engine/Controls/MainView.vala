public class MainView : View
{
    public MainView(RenderWindow window)
    {
        parent_window = window;
    }

    public override void do_render(RenderState state){}
    protected override void do_mouse_event(MouseEventArgs mouse){}
    protected override void do_mouse_move(MouseMoveArgs mouse){}
    protected override void added(){}
    protected override void do_process(DeltaArgs args){}
    protected override void do_key_press(KeyArgs keys){}
}

public class MouseEventArgs
{
    public MouseEventArgs(Button button, bool down)
    {
        this.button = button;
        this.down = down;
    }


    public Button button { get; private set; }
    public bool down { get; private set; }

    public enum Button
    {
        LEFT,
        CENTER,
        RIGHT,
    }
}

public class MouseMoveArgs
{
    public MouseMoveArgs(int pos_x, int pos_y, int delta_x, int delta_y)
    {
        this.pos_x = pos_x;
        this.pos_y = pos_y;
        this.delta_x = delta_x;
        this.delta_y = delta_y;
    }

    public int pos_x { get; private set; }
    public int pos_y { get; private set; }
    public int delta_x { get; private set; }
    public int delta_y { get; private set; }
}

public class KeyArgs
{
    public KeyArgs(char key)
    {
        this.key = key;
    }

    public char key { get; private set; }
}

public class DeltaArgs
{
    public DeltaArgs(float time, float delta)
    {
        this.time = time;
        this.delta = delta;
    }

    public float time { get; private set; }
    public float delta { get; private set; }
}
