using SDL;

public class SDLWindowTarget : Object, IWindowTarget
{
    private bool is_fullscreen = false;
    private unowned Window window;

    public SDLWindowTarget(Window window)
    {
        this.window = window;
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
        SDL.Cursor.set_relative_mode(hidden);
    }

    public void set_cursor_position(int x, int y)
    {
        //window.set_cursor_position(x, y);
    }

    public Window sdl_window { get { return window; } }
}
