public interface IWindowTarget : Object
{
    public abstract bool fullscreen { get; set; }
    public abstract Size2i size { get; set; }
    public abstract void swap();
    public abstract void pump_events();
    public abstract void set_icon(string icon);
    public abstract void set_cursor_type(CursorType type);
    public abstract void set_cursor_hidden(bool hidden);
    public abstract void set_cursor_position(int x, int y);
    public abstract string get_clipboard_text();
    public abstract void set_clipboard_text(string text);
    public abstract void start_text_input();
    public abstract void stop_text_input();
}

public enum CursorType
{
    UNDEFINED,
    NORMAL,
    HOVER,
    CARET
}
