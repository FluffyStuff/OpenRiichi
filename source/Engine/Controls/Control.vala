public abstract class Control : IControl
{
    private Vec2 _position = Vec2(0, 0);
    private Size2 _scale = Size2(1, 1);
    private Vec2 _inner_anchor = Vec2(0.5f, 0.5f);
    private Vec2 _outer_anchor = Vec2(0.5f, 0.5f);
    private Size2 _relative_scale = Size2(1, 1);
    private Rectangle _rect;
    private ResizeStyle _resize_style = ResizeStyle.ABSOLUTE;
    private weak IControl? parent = null;

    protected Gee.ArrayList<Control> child_controls = new Gee.ArrayList<Control>();

    private bool added_called = false;

    protected virtual void on_added() {}
    protected virtual void do_process(DeltaArgs delta) {}
    protected abstract void do_render(RenderScene2D scene);
    public abstract void do_resize(Vec2 new_position, Size2 new_scale);

    protected virtual void on_mouse_move(Vec2 position) {}
    protected virtual void on_click(Vec2 position) {}
    protected virtual void on_mouse_down(Vec2 position) {}
    protected virtual void on_mouse_up(Vec2 position) {}
    protected virtual void on_focus_lost() {}
    protected virtual void on_key_press(KeyArgs key) {}
    protected virtual void on_text_input(TextInputArgs text) {}
    public signal void clicked(Vec2 position);

    protected Control()
    {
        enabled = true;
        visible = true;
        cursor_type = CursorType.HOVER;
    }

    protected void added()
    {
        if (added_called)
            return;

        added_called = true;
        on_added();
    }

    public void set_parent(IControl? parent)
    {
        this.parent = parent;
        resize();
    }

    public void resize()
    {
        if (parent == null)
            return;

        Size2i window_size = window_size;
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

        foreach (Control control in child_controls)
            control.resize();
    }

    public void process(DeltaArgs delta)
    {
        do_process(delta);

        foreach (Control control in child_controls)
            control.process(delta);
    }

    public void render(RenderScene2D scene)
    {
        if (!visible)
            return;

        do_render(scene);

        foreach (Control control in child_controls)
            control.render(scene);
    }

    public void mouse_move(MouseMoveArgs mouse)
    {
        if (mouse.handled || !visible || !selectable)
        {
            hovering = false;
            return;
        }

        if (!hover_check(mouse.position) && !mouse_down)
        {
            hovering = false;
            return;
        }

        mouse.handled = true;
        hovering = true;

        if (enabled)
            mouse.cursor_type = cursor_type;

        on_mouse_move(Vec2(mouse.position.x - rect.x, mouse.position.y - rect.y));
    }

    public void mouse_event(MouseEventArgs mouse)
    {
        if (mouse.handled || !visible || !selectable)
        {
            mouse_down = false;
            if (focused)
                focus_lost();
            return;
        }

        if (!hover_check(mouse.position))
        {
            mouse_down = false;
            if (focused)
                focus_lost();
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
            do_mouse_down(Vec2(mouse.position.x - rect.x, mouse.position.y - rect.y));
            return;
        }

        on_mouse_up(Vec2(mouse.position.x - rect.x, mouse.position.y - rect.y));

        if (mouse_down)
            click(Vec2(mouse.position.x - rect.x, mouse.position.y - rect.y));

        mouse_down = false;
    }

    public void key_press(KeyArgs key)
    {
        if (key.handled || !visible || !focused)
            return;

        key.handled = true;

        on_key_press(key);
    }

    public void text_input(TextInputArgs text)
    {
        if (text.handled || !visible || !focused)
            return;

        text.handled = true;

        on_text_input(text);
    }

    private void click(Vec2 position)
    {
        on_click(position);
        clicked(position);
    }

    private void do_mouse_down(Vec2 position)
    {
        focused = true;
        on_mouse_down(position);
    }

    private void focus_lost()
    {
        focused = false;
        on_focus_lost();
    }

    protected void add_control(Control control)
    {
        child_controls.add(control);
        control.set_parent(this);
        control.added();
    }

    protected void remove_control(Control control)
    {
        control.set_parent(null);
        child_controls.remove(control);
    }

    private bool hover_check(Vec2i point)
    {
        if (!enabled || !visible || !selectable)
            return false;

        Vec2 bottom_left = Vec2(rect.x, rect.y);
        Vec2 top_right = Vec2(rect.x + rect.width, rect.y + rect.height);

        return
            point.x >= bottom_left.x &&
            point.x <= top_right.x &&
            point.y >= bottom_left.y &&
            point.y <= top_right.y;
    }

    protected void start_text_input()
    {
        parent.start_text_input();
    }

    protected void stop_text_input()
    {
        parent.stop_text_input();
    }

    protected string get_clipboard_text()
    {
        return parent.get_clipboard_text();
    }

    protected void set_clipboard_text(string text)
    {
        parent.set_clipboard_text(text);
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
    public bool focused { get; private set; }
    public bool mouse_down { get; private set; }
    public bool selectable { get; set; }
    public abstract Size2 size { get; }
    public CursorType cursor_type { get; protected set; }

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

    public Size2i window_size
    {
        get { return parent.window_size; }
    }
}
