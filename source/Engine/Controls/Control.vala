public abstract class Control
{
    private Vec2 _position = Vec2(0, 0);
    private Size2 _scale = Size2(1, 1);
    private Vec2 _inner_anchor = Vec2(0.5f, 0.5f);
    private Vec2 _outer_anchor = Vec2(0.5f, 0.5f);
    private Size2 _relative_scale = Size2(1, 1);
    private Rectangle _rect;
    private ResizeStyle _resize_style = ResizeStyle.ABSOLUTE;
    private View? parent;

    private bool mouse_down = false;

    public virtual void process(DeltaArgs delta) {}
    public abstract void do_render(RenderScene2D scene);
    public abstract void do_resize(Vec2 new_position, Size2 new_scale);

    protected virtual void click() { clicked(); }
    public signal void clicked();

    protected Control()
    {
        enabled = true;
        visible = true;
    }

    public void set_parent(View? parent)
    {
        this.parent = parent;
        resize();
    }

    public void resize()
    {
        if (parent == null)
            return;

        Size2i window_size = parent.window_size;
        Rectangle prect = parent.rect;

        if (resize_style == ResizeStyle.RELATIVE)
            _scale = Size2(prect.width / size.width * relative_scale.width, prect.height / size.height * relative_scale.height);

        Vec2 pos = Vec2
        (
            position.x - size.width  * scale.width  * inner_anchor.x + prect.x + prect.width  * outer_anchor.x,
            position.y - size.height * scale.height * inner_anchor.y + prect.y + prect.height * outer_anchor.y
        );

        Size2 sz = Size2
        (
            scale.width  * size.width,
            scale.height * size.height
        );

        _rect = Rectangle(pos.x, pos.y, sz.width, sz.height);

        Vec2 new_pos = Vec2((rect.x + rect.width / 2) / window_size.width * 2 - 1, (rect.y + rect.height / 2) / window_size.height * 2 - 1);
        Size2 new_scale = Size2(rect.width / window_size.width, rect.height / window_size.height);

        do_resize(new_pos, new_scale);
    }

    public void render(RenderScene2D scene)
    {
        if (!visible)
            return;

        do_render(scene);
    }

    public void mouse_move(MouseMoveArgs mouse)
    {
        if (mouse.handled || !visible)
        {
            hovering = false;
            return;
        }

        if (!hover_check(mouse.position))
        {
            hovering = false;
            return;
        }

        mouse.handled = true;
        hovering = true;

        if (enabled)
            mouse.cursor_type = cursor_type;
    }

    public void mouse_event(MouseEventArgs mouse)
    {
        if (mouse.handled || !visible || !selectable)
        {
            mouse_down = false;
            return;
        }

        if (!hover_check(mouse.position))
        {
            mouse_down = false;
            return;
        }

        mouse.handled = true;

        if (!enabled)
        {
            mouse_down = false;
            return;
        }

        if (mouse.down)
        {
            mouse_down = true;
            return;
        }

        if (mouse_down)
            click();

        mouse_down = false;
    }

    private bool hover_check(Vec2i point)
    {
        if (!enabled || !visible || !selectable)
            return false;

        Vec2 top_left = Vec2(rect.x, rect.y);
        Vec2 bottom_right = Vec2(rect.x + rect.width, rect.y + rect.height);

        return
            point.x >= top_left.x &&
            point.x <= bottom_right.x &&
            point.y >= top_left.y &&
            point.y <= bottom_right.y;
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

    public bool visible { get; set; }
    public bool enabled { get; set; }
    public bool hovering { get; private set; }
    public bool selectable { get; set; }
    public abstract Size2 size { get; }
    protected virtual CursorType cursor_type { get { return CursorType.HOVER; } }

    public Vec2 position
    {
        get { return _position; }
        set
        {
            _position = value;
            resize();
        }
    }

    public Size2 scale
    {
        get { return _scale; }
        set
        {
            _scale = value;
            resize();
        }
    }

    public Size2 relative_scale
    {
        get { return _relative_scale; }
        set
        {
            _relative_scale = value;
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
