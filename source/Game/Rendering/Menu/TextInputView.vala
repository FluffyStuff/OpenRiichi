public class TextInputView : Control
{
    private IResourceStore store;
    private LabelControl label;
    private string _text = "";
    private string back_text;
    private Size2 _size = Size2(400, 40);

    private RectangleControl selection;
    private RectangleControl caret;
    private int caret_position = 0;
    private int selection_start = 0;
    private int selection_end = 0;

    private DelayTimer timer = new DelayTimer();
    private bool caret_visible = true;

    public signal void text_changed();

    public TextInputView(IResourceStore store, string back_text)
    {
        base();
        this.store = store;
        this.back_text = back_text;
        selectable = true;
        resize_style = ResizeStyle.ABSOLUTE;
        cursor_type = CursorType.CARET;
        timer.set_time(0.55f);
    }

    protected override void on_added()
    {
        RectangleControl border = new RectangleControl();
        border.color = Color(0.05f, 0, 0.4f, 1);
        border.set_size(Size2(size.width + 6, size.height + 6));

        RectangleControl rect = new RectangleControl();
        rect.color = Color(0.1f, 0, 0.8f, 1);
        rect.set_size(size);
        add_control(border);
        add_control(rect);

        label = new LabelControl(store);
        label.inner_anchor = Vec2(0, 0.5f);
        label.outer_anchor = Vec2(0, 0.5f);
        label.position = Vec2(10, 0);
        add_control(label);

        selection = new RectangleControl();
        selection.inner_anchor = Vec2(0, 0.5f);
        selection.outer_anchor = Vec2(0, 0.5f);
        selection.set_size(Size2(0, label.size.height));
        selection.color = Color(1, 1, 1, 0.2f);
        add_control(selection);

        caret = new RectangleControl();
        caret.outer_anchor = Vec2(0, 0.5f);
        caret.set_size(Size2(1, label.size.height));
        caret.color = Color(1, 1, 1, 0.2f);
        caret.visible = false;
        add_control(caret);

        update_text();
        update_caret();
    }

    protected override void on_mouse_move(Vec2 position)
    {
        if (!mouse_down)
            return;

        selection_end = caret_position = get_char_position(position.x);
        update_caret();
    }

    protected override void on_mouse_down(Vec2 position)
    {
        caret.visible = true;
        selection_start = caret_position = get_char_position(position.x);
        update_caret();
    }

    protected override void on_mouse_up(Vec2 position)
    {
        start_text_input();
    }

    protected override void on_focus_lost()
    {
        caret.visible = false;
        stop_text_input();
    }

    protected override void on_key_press(KeyArgs key)
    {
        if (key.keycode == KeyCode.BACKSPACE)
        {
            if (caret_position != 0)
            {
                string pre = text.substring(0, text.index_of_nth_char(caret_position - 1));
                string post = text.substring(text.index_of_nth_char(caret_position), text.index_of_nth_char(text.char_count()) - text.index_of_nth_char(caret_position));
                text = pre + post;
                caret_position--;
            }
        }
        else if (key.keycode == KeyCode.DELETE)
        {
            if (caret_position != text.char_count())
            {
                string pre = text.substring(0, text.index_of_nth_char(caret_position));
                string post = text.substring(text.index_of_nth_char(caret_position + 1), text.index_of_nth_char(text.char_count()) - text.index_of_nth_char(caret_position + 1));
                text = pre + post;
            }
        }
        else if (key.keycode == KeyCode.LEFT)
            caret_position = int.max(0, caret_position - 1);
        else if (key.keycode == KeyCode.RIGHT)
            caret_position = int.min(text.char_count(), caret_position + 1);
        else if (key.keycode == KeyCode.UP || key.keycode == KeyCode.HOME)
            caret_position = 0;
        else if (key.keycode == KeyCode.DOWN || key.keycode == KeyCode.END)
            caret_position = text.char_count();
        else if (key.scancode == ScanCode.V && ((key.modifiers & Modifier.LCTRL) == Modifier.LCTRL || (key.modifiers & Modifier.RCTRL) == Modifier.RCTRL))
        {
            string txt = get_clipboard_text();
            string pre = text.substring(0, text.index_of_nth_char(caret_position));
            string post = text.substring(text.index_of_nth_char(caret_position), text.index_of_nth_char(text.char_count()) - text.index_of_nth_char(caret_position));
            text = pre + txt + post;

            caret_position += txt.char_count();
        }

        update_caret();
    }

    protected override void on_text_input(TextInputArgs t)
    {
        string txt = t.text;
        string pre = text.substring(0, text.index_of_nth_char(caret_position));
        string post = text.substring(text.index_of_nth_char(caret_position), text.index_of_nth_char(text.char_count()) - text.index_of_nth_char(caret_position));

        text = pre + txt + post;
        caret_position += txt.char_count();

        update_caret();
    }

    private int get_char_position(float x)
    {
        int char_index = 0;
        float prev_width = 0;
        for (; char_index < text.char_count(); char_index++)
        {
            string t = text.substring(0, text.index_of_nth_char(char_index + 1));
            LabelInfo info = LabelLoader.get_label_info_static(label.font_type, label.font_size, t);

            float p = (info.size.width - prev_width) / 2;
            prev_width = info.size.width;
            if (x - label.position.x < info.size.width - p)
                break;
        }

        return char_index;
    }

    private void update_text()
    {
        if (text == "")
        {
            label.text = back_text;
            label.color = Color(1, 1, 1, 0.1f);
        }
        else
        {
            label.text = text;
            label.color = Color.white();
        }

        text_changed();
    }

    private void update_caret()
    {
        string t = text.substring(0, text.index_of_nth_char(caret_position));

        LabelInfo info = LabelLoader.get_label_info_static(label.font_type, label.font_size, t);
        caret.position = Vec2(info.size.width + label.position.x, 0);

        timer.set_time(timer.delay);
        caret_visible = true;

        int min = int.min(selection_start, selection_end);
        int max = int.max(selection_start, selection_end);

        t = text.substring(0, text.index_of_nth_char(min));
        info = LabelLoader.get_label_info_static(label.font_type, label.font_size, t);
        float start = info.size.width + label.position.x;

        t = text.substring(0, text.index_of_nth_char(max));
        info = LabelLoader.get_label_info_static(label.font_type, label.font_size, t);
        float end = info.size.width + label.position.x;

        selection.set_size(Size2(end - start, selection.size.height));
        selection.position = Vec2(start, 0);
    }

    public void set_size(Size2 size)
    {
        _size = size;
        resize();
    }

    public override void do_process(DeltaArgs delta)
    {
        if (!focused)
        {
            caret.visible = false;
            return;
        }

        caret.visible = caret_visible;

        if (timer.active(delta.time))
        {
            caret_visible = !caret_visible;
            timer.set_time(timer.delay);
        }
    }

    public override void do_render(RenderScene2D scene) {}
    public override void do_resize(Vec2 new_position, Size2 new_scale) {}

    public string text
    {
        get { return _text; }
        set
        {
            _text = value;
            update_text();
        }
    }

    public override Size2 size { get { return _size; } }
}
