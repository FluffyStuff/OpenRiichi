public abstract class Control : Container
{
    //protected virtual void on_added() {}
    //public abstract void do_resize(Vec2 new_position, Size2 new_scale);

    protected virtual void on_mouse_move(Vec2 position) {}
    protected virtual void on_click(Vec2 position) {}
    protected virtual void on_mouse_down(Vec2 position) {}
    protected virtual void on_mouse_up(Vec2 position) {}
    protected virtual void on_focus_lost() {}
    protected virtual void on_child_focus_lost() {}
    protected virtual void on_key_press(KeyArgs key) {}
    protected virtual void on_text_input(TextInputArgs text) {}
    protected virtual void on_text_edit(TextEditArgs text) {}
    public signal void clicked(Control control, Vec2 position);

    protected Control()
    {
        enabled = true;
        cursor_type = CursorType.HOVER;
    }

    public override void do_mouse_move(MouseMoveArgs mouse)
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

        if (!enabled)
        {
            hovering = false;
            return;
        }

        mouse.cursor_type = cursor_type;
        hovering = true;

        on_mouse_move(Vec2(mouse.position.x - rect.x, mouse.position.y - rect.y));
    }

    public override void do_mouse_event(MouseEventArgs mouse)
    {
        if (mouse.handled || !visible || !selectable)
        {
            mouse_down = false;
            if (focused && mouse.down)
                focus_lost();
            return;
        }

        if (!hover_check(mouse.position))
        {
            mouse_down = false;
            if (focused && mouse.down)
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

    public override void do_key_press(KeyArgs key)
    {
        if (key.handled || !visible || !focused)
            return;

        key.handled = true;

        on_key_press(key);
    }

    public override void do_text_input(TextInputArgs text)
    {
        if (text.handled || !visible || !focused)
            return;

        text.handled = true;

        on_text_input(text);
    }

    public override void do_text_edit(TextEditArgs text)
    {
        if (text.handled || !visible || !focused)
            return;

        text.handled = true;

        on_text_edit(text);
    }

    private void click(Vec2 position)
    {
        on_click(position);
        clicked(this, position);
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

    public bool enabled { get; set; }
    public bool hovering { get; private set; }
    public bool focused { get; private set; }
    public bool mouse_down { get; private set; }
    public bool selectable { get; set; }
    public CursorType cursor_type { get; protected set; }
}

public abstract class EndControl : Control
{
    protected EndControl()
    {
        base();
    }

    public override void added()
    {
        on_added();

        resize_style = ResizeStyle.ABSOLUTE;
        size = end_size;
    }

    public override void do_render(RenderState state, RenderScene2D scene)
    {
        render_end(scene);
    }

    public override void resized()
    {
        Vec2 new_pos = Vec2((rect.x + rect.width / 2) / window_size.width * 2 - 1, (rect.y + rect.height / 2) / window_size.height * 2 - 1);
        Size2 new_scale = Size2(rect.width / window_size.width, rect.height / window_size.height);

        set_end_rect(Rectangle.vec(new_pos, new_scale));
    }

    protected virtual void on_added() {}
    protected abstract void set_end_rect(Rectangle rect);
    protected abstract void render_end(RenderScene2D scene);
    public abstract Size2 end_size { get; }
}
