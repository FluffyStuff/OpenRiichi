using SDL;

public class SDLWindowTarget : Object, IWindowTarget
{
    private bool is_fullscreen;
    private Window window;
    private GLContext context;

    private Cursor normal_cursor;
    private Cursor hover_cursor;
    private Cursor caret_cursor;

    public SDLWindowTarget(owned Window window, owned GLContext context, bool is_fullscreen)
    {
        this.window = (owned)window;
        this.context = (owned)context;
        this.is_fullscreen = is_fullscreen;

        normal_cursor = new Cursor.from_system(SystemCursor.ARROW);
        hover_cursor = new Cursor.from_system(SystemCursor.HAND);
        caret_cursor = new Cursor.from_system(SystemCursor.IBEAM);
        current_cursor = CursorType.NORMAL;
    }

    public void pump_events()
    {
        Event.pump();
    }

    public void set_icon(string icon)
    {
        var img = SDLImage.load(icon);
        window.set_icon(img);
    }

    public bool fullscreen
    {
        get { return is_fullscreen; }
        set { window.set_fullscreen((is_fullscreen = value) ? WindowFlags.FULLSCREEN_DESKTOP : 0); }
    }

    public Size2i size
    {
        get
        {
            int width, height;
            window.get_size(out width, out height);
            return Size2i(width, height);
        }
        set
        {
            window.set_size(value.width, value.height);
        }
    }

    public void swap()
    {
        SDL.GL.swap_window(window);
    }

    public void set_cursor_hidden(bool hidden)
    {
        Cursor.show(hidden ? 0 : 1);
    }

    public void set_cursor_relative_mode(bool relative)
    {
        Cursor.set_relative_mode(relative);
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
        case CursorType.CARET:
            Cursor.set(caret_cursor);
            break;
        }

        current_cursor = type;
    }

    public void set_cursor_position(int x, int y)
    {
        Cursor.warp_mouse(window, x, y);
    }

    public void start_text_input()
    {
        TextInput.start();
    }

    public void stop_text_input()
    {
        TextInput.stop();
    }

    public string get_clipboard_text()
    {
        return Clipboard.get_text();
    }

    public void set_clipboard_text(string text)
    {
        Clipboard.set_text(text);
    }

    public Window sdl_window { get { return window; } }
    public CursorType current_cursor { get; private set; }
}
