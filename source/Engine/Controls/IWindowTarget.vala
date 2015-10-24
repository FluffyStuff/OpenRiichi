public interface IWindowTarget : Object
{
    public abstract bool fullscreen { get; set; }
    public abstract Size2i size { get; }
    public abstract void swap();
    public abstract void pump_events();
    public abstract void set_cursor_type(CursorType type);
    public abstract void set_cursor_hidden(bool hidden);
    public abstract void set_cursor_position(int x, int y);
}

public enum CursorType
{
    UNDEFINED,
    NORMAL,
    HOVER
}
