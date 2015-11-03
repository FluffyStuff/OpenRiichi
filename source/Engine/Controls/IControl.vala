public interface IControl
{
    protected abstract void added();
    protected abstract void start_text_input();
    protected abstract void stop_text_input();
    protected abstract string get_clipboard_text();
    protected abstract void set_clipboard_text(string text);
    public abstract Rectangle rect { get; }
    public abstract Size2i window_size { get; }
}
