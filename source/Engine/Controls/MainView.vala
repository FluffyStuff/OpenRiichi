public class MainView : View
{
    public MainView(RenderWindow window)
    {
        parent_window = window;
        resize();
    }
}

public class MouseEventArgs
{
    public MouseEventArgs(Button button, MouseReference? reference, bool down, Vec2i position, Vec2i size)
    {
        this.button = button;
        this.down = down;
        this.position = position;
        this.size = size;
    }

    public bool handled { get; set; }
    public MouseReference? reference { get; set; }
    public Button button { get; private set; }
    public bool down { get; private set; }
    public Vec2i position { get; private set; }
    public Vec2i size { get; private set; }

    public enum Button
    {
        LEFT,
        CENTER,
        RIGHT,
    }
}

public class MouseMoveArgs
{
    public MouseMoveArgs(Vec2i position, Vec2i delta, Vec2i size)
    {
        this.position = position;
        this.delta = delta;
        this.size = size;
        cursor_type = CursorType.NORMAL;
    }

    public bool handled { get; set; }
    public CursorType cursor_type { get; set; }
    public Vec2i position { get; private set; }
    public Vec2i delta { get; private set; }
    public Vec2i size { get; private set; }
}

public class MouseReference {}

public class KeyArgs
{
    public KeyArgs(char key)
    {
        this.key = key;
    }

    public bool handled { get; set; }
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
