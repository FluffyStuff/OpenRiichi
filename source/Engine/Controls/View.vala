public abstract class View : Object
{
    private Vec2 _position = Vec2(0, 0);
    private Size2 _size = Size2(1, 1);
    private Size2 _relative_size = Size2(1, 1);
    private Rectangle _rect;
    private ResizeStyle _resize_style = ResizeStyle.RELATIVE;

    private Gee.ArrayList<View> child_views = new Gee.ArrayList<View>();
    protected RenderWindow parent_window;
    private View parent;

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

    public void resize()
    {
        Rectangle prect = parent_rect;

        if (resize_style == ResizeStyle.RELATIVE)
            _size = Size2(prect.width * relative_size.width, prect.height * relative_size.height);

        _rect = Rectangle(prect.x + position.x, prect.y + position.y, size.width, size.height);

        foreach (View child in child_views)
            child.resize();

        resized();
    }

    protected virtual void added() {}
    protected virtual void resized() {}
    protected virtual void do_render(RenderState state) {}
    protected virtual void do_process(DeltaArgs delta) {}
    protected virtual void do_mouse_event(MouseEventArgs mouse) { }
    protected virtual void do_mouse_move(MouseMoveArgs mouse) { }
    protected virtual void do_key_press(KeyArgs key) { }

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
