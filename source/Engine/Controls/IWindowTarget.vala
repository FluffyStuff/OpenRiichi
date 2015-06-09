public interface IWindowTarget : Object
{
    public abstract bool fullscreen { get; set; }
    public abstract int width { get; }
    public abstract int height { get; }
    public abstract void swap();
    public abstract void pump_events();
    public abstract void set_cursor_hidden(bool hidden);
    public abstract void set_cursor_position(int x, int y);
}
