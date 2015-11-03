public abstract class View : Object, IControl
{
    private Vec2 _position = Vec2(0, 0);
    private Size2 _size = Size2(1, 1);
    private Vec2 _inner_anchor = Vec2(0.5f, 0.5f);
    private Vec2 _outer_anchor = Vec2(0.5f, 0.5f);
    private Size2 _relative_size = Size2(1, 1);
    private Rectangle _rect;
    private ResizeStyle _resize_style = ResizeStyle.RELATIVE;

    private Gee.ArrayList<View> child_views = new Gee.ArrayList<View>();
    protected weak RenderWindow parent_window;
    private weak View parent;

    public void add_child(View child)
    {
        child.set_parent(this);
        child.added();
        child_views.add(child);
    }

    public void add_child_back(View child)
    {
        child.set_parent(this);
        child.added();
        child_views.insert(0, child);
    }

    public void remove_child(View child)
    {
        child_views.remove(child);
        child.set_parent(null);
    }

    private void set_parent(View? parent)
    {
        this.parent = parent;

        if (parent == null)
            parent_window = null;
        else
        {
            parent_window = parent.parent_window;
            resize();
        }
    }

    public void process(DeltaArgs delta)
    {
        do_process(delta);

        foreach (View view in child_views)
            view.process(delta);
    }

    public void render(RenderState state)
    {
        do_render(state);

        foreach (View view in child_views)
            view.render(state);
    }

    public void mouse_event(MouseEventArgs mouse)
    {
        for (int i = child_views.size - 1; i >= 0; i--)
            child_views[i].mouse_event(mouse);
        do_mouse_event(mouse);
    }

    public void mouse_move(MouseMoveArgs mouse)
    {
        for (int i = child_views.size - 1; i >= 0; i--)
            child_views[i].mouse_move(mouse);
        do_mouse_move(mouse);
    }

    public void key_press(KeyArgs key)
    {
        for (int i = child_views.size - 1; i >= 0; i--)
            child_views[i].key_press(key);
        do_key_press(key);
    }

    public void text_input(TextInputArgs text)
    {
        for (int i = child_views.size - 1; i >= 0; i--)
            child_views[i].text_input(text);
        do_text_input(text);
    }

    public void resize()
    {
        Rectangle prect = parent_rect;

        if (resize_style == ResizeStyle.RELATIVE)
            _size = Size2(prect.width * relative_size.width, prect.height * relative_size.height);

        Vec2 pos = Vec2
        (
            position.x - size.width  * inner_anchor.x + prect.x + prect.width  * outer_anchor.x,
            position.y - size.height * inner_anchor.y + prect.y + prect.height * outer_anchor.y
        );

        _rect = Rectangle(pos.x, pos.y, size.width, size.height);

        foreach (View child in child_views)
            child.resize();

        resized();
    }

    protected void start_text_input()
    {
        window.start_text_input();
    }

    protected void stop_text_input()
    {
        window.stop_text_input();
    }

    protected string get_clipboard_text()
    {
        return window.get_clipboard_text();
    }

    protected void set_clipboard_text(string text)
    {
        window.set_clipboard_text(text);
    }

    public RenderWindow window { get { return parent_window; } }
    protected virtual void added() {}
    protected virtual void resized() {}
    protected virtual void do_render(RenderState state) {}
    protected virtual void do_process(DeltaArgs delta) {}
    protected virtual void do_mouse_event(MouseEventArgs mouse) { }
    protected virtual void do_mouse_move(MouseMoveArgs mouse) { }
    protected virtual void do_key_press(KeyArgs key) { }
    protected virtual void do_text_input(TextInputArgs text) { }

    protected IResourceStore store { get { return parent_window.store; } }

    protected Rectangle parent_rect
    {
        get
        {
            if (parent != null)
                return parent.rect;
            else if (parent_window != null)
                return Rectangle(0, 0, parent_window.size.width, parent_window.size.height);
            return Rectangle(0, 0, 1, 1);
        }
    }

    public Size2i window_size
    {
        get
        {
            if (parent_window == null)
                return Size2i(1, 1);
            return parent_window.size;
        }
    }

    public Vec2 position
    {
        get { return _position; }
        set
        {
            _position = value;
            resize();
        }
    }

    public Size2 size
    {
        get { return _size; }
        set
        {
            _size = value;
            resize();
        }
    }

    public Size2 relative_size
    {
        get { return _relative_size; }
        set
        {
            _relative_size = value;
            resize();
        }
    }

    public Vec2 outer_anchor
    {
        get { return _outer_anchor; }
        set
        {
            _outer_anchor = value;
            resize();
        }
    }

    public Vec2 inner_anchor
    {
        get { return _inner_anchor; }
        set
        {
            _inner_anchor = value;
            resize();
        }
    }

    public Rectangle rect { get { return _rect; } }
    public ResizeStyle resize_style
    {
        get { return _resize_style; }
        set
        {
            _resize_style = value;
            resize();
        }
    }
}

public enum ResizeStyle
{
    ABSOLUTE,
    RELATIVE
}
