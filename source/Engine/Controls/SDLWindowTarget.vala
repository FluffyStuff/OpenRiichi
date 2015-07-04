using SDL;

public class SDLWindowTarget : Object, IWindowTarget
{
    private bool is_fullscreen = false;
    private unowned Window window;

    private Cursor normal_cursor;
    private Cursor hover_cursor;

    public SDLWindowTarget(Window window)
    {
        this.window = window;

        normal_cursor = new Cursor.from_system(SystemCursor.ARROW);
        hover_cursor = new Cursor.from_system(SystemCursor.HAND);
        current_cursor = CursorType.NORMAL;
    }

    public void pump_events()
    {
        Event.pump();
    }

    public bool fullscreen
    {
        get { return is_fullscreen; }
        set { window.set_fullscreen((is_fullscreen = value) ? WindowFlags.FULLSCREEN_DESKTOP : 0); }
    }

    public int width
    {
        get
        {
            int width, height;
            window.get_size(out width, out height);
            return width;
        }
    }

    public int height
    {
        get
        {
            int width, height;
            window.get_size(out width, out height);
            return height;
        }
    }

    public void swap()
    {
        SDL.GL.swap_window(window);
    }

    public void set_cursor_hidden(bool hidden)
    {
        //SDL.Cursor.show(hidden ? 0 : 1);
        Cursor.set_relative_mode(hidden);
    }

    public void set_cursor_type(CursorType type)
    {
        if (type == current_cursor)
            return;

        switch (type)
        {
        case CursorType.NORMAL:
            Cursor.set(normal_cursor);
            break;
        case CursorType.HOVER:
            Cursor.set(hover_cursor);
            break;
        }

        current_cursor = type;
    }

    public void set_cursor_position(int x, int y)
    {
        //window.set_cursor_position(x, y);
    }

    public Window sdl_window { get { return window; } }
    public CursorType current_cursor { get; private set; }
}
