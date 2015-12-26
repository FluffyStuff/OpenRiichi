public class TextInputControl : Control
{
    private LabelControl label;
    private string _text = "";
    private string back_text;

    private RectangleControl selection;
    private RectangleControl caret;
    private int caret_position = 0;
    private int selection_start = 0;
    private int selection_end = 0;

    private DelayTimer timer = new DelayTimer();
    private bool caret_visible = true;

    private LabelControl ime_label;
    private RectangleControl ime_rect;
    //private RectangleControl ime_caret;
    private bool ime_editing = false;

    public signal void text_changed();

    public TextInputControl(string back_text)
    {
        base();
        this.back_text = back_text;
        selectable = true;
        cursor_type = CursorType.CARET;
        resize_style = ResizeStyle.ABSOLUTE;
        size = Size2(400, 40);
        timer.set_time(0.55f);
    }

    protected override void added()
    {
        RectangleControl border = new RectangleControl();
        add_child(border);
        border.color = Color(0.3f, 0.01f, 0.01f, 1);
        border.size = Size2(size.width + 6, size.height + 6);

        RectangleControl rect = new RectangleControl();
        add_child(rect);
        rect.color = Color(0.6f, 0.02f, 0.02f, 1);
        rect.size = size;

        label = new LabelControl();
        add_child(label);
        label.inner_anchor = Vec2(0, 0.5f);
        label.outer_anchor = Vec2(0, 0.5f);
        label.position = Vec2(10, 0);

        ime_rect = new RectangleControl();
        add_child(ime_rect);
        ime_rect.inner_anchor = Vec2(0, 0.5f);
        ime_rect.outer_anchor = Vec2(0, 0.5f);
        ime_rect.color = rect.color;
        ime_rect.size = Size2(0, size.height);
        ime_rect.visible = false;

        /*ime_caret = new RectangleControl();
        ime_caret.outer_anchor = Vec2(0, 0);
        ime_caret.outer_anchor = Vec2(0, 0);
        ime_caret.color = Color(1, 1, 1, 0.5f);
        ime_caret.set_size(Size2(0, 3));
        ime_caret.visible = false;
        add_control(ime_caret);*/

        ime_label = new LabelControl();
        add_child(ime_label);
        ime_label.inner_anchor = Vec2(0, 0.5f);
        ime_label.outer_anchor = Vec2(0, 0.5f);
        ime_label.color = Color(1, 0, 0, 1);

        selection = new RectangleControl();
        add_child(selection);
        selection.inner_anchor = Vec2(0, 0.5f);
        selection.outer_anchor = Vec2(0, 0.5f);
        selection.size = Size2(0, label.size.height);
        selection.color = Color(1, 1, 1, 0.2f);

        caret = new RectangleControl();
        add_child(caret);
        caret.outer_anchor = Vec2(0, 0.5f);
        caret.size = Size2(1, label.size.height);
        caret.color = Color(1, 1, 1, 0.2f);
        caret.visible = false;

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
        selection_start = selection_end = caret_position = get_char_position(position.x);
        selection.visible = true;
        update_caret();
    }

    protected override void on_mouse_up(Vec2 position)
    {
        start_text_input();
    }

    protected override void on_focus_lost()
    {
        selection_start = 0;
        selection_end = 0;
        update_caret();
        caret.visible = false;
        ime_editing = false;
        ime_label.visible = false;
        ime_rect.visible = false;
        stop_text_input();
    }

    protected override void on_key_press(KeyArgs key)
    {
        if (ime_editing)
            return;

        if (key.keycode == KeyCode.BACKSPACE)
        {
            int min = 0, max = 0;
            if (selection_start != selection_end)
            {
                min = int.min(selection_start, selection_end);
                max = int.max(selection_start, selection_end);
            }
            else if (caret_position != 0)
            {
                min = caret_position - 1;
                max = caret_position;
            }

            if (min != max)
            {
                string pre = text.substring(0, text.index_of_nth_char(min));
                string post = text.substring(text.index_of_nth_char(max), text.index_of_nth_char(text.char_count()) - text.index_of_nth_char(max));
                text = pre + post;
                caret_position = min;
                selection_start = selection_end = 0;
            }
        }
        else if (key.keycode == KeyCode.DELETE)
        {
            int min = 0, max = 0;
            if (selection_start != selection_end)
            {
                min = int.min(selection_start, selection_end);
                max = int.max(selection_start, selection_end);
            }
            else if (caret_position != text.char_count())
            {
                min = caret_position;
                max = caret_position + 1;
            }

            if (min != max)
            {
                string pre = text.substring(0, text.index_of_nth_char(min));
                string post = text.substring(text.index_of_nth_char(max), text.index_of_nth_char(text.char_count()) - text.index_of_nth_char(max));
                text = pre + post;
                caret_position = min;
                selection_start = selection_end = 0;
            }
        }
        else if (key.keycode == KeyCode.LEFT)
        {
            caret_position = int.max(0, caret_position - 1);
            selection_start = selection_end = 0;
        }
        else if (key.keycode == KeyCode.RIGHT)
        {
            caret_position = int.min(text.char_count(), caret_position + 1);
            selection_start = selection_end = 0;
        }
        else if (key.keycode == KeyCode.UP || key.keycode == KeyCode.HOME)
        {
            caret_position = 0;
            selection_start = selection_end = 0;
        }
        else if (key.keycode == KeyCode.DOWN || key.keycode == KeyCode.END)
        {
            caret_position = text.char_count();
            selection_start = selection_end = 0;
        }
        else if (key.scancode == ScanCode.V && ((key.modifiers & Modifier.LCTRL) == Modifier.LCTRL || (key.modifiers & Modifier.RCTRL) == Modifier.RCTRL))
        {
            int min = caret_position, max = caret_position;
            if (selection_start != selection_end)
            {
                min = int.min(selection_start, selection_end);
                max = int.max(selection_start, selection_end);
            }

            string txt = get_clipboard_text();
            string pre = text.substring(0, text.index_of_nth_char(min));
            string post = text.substring(text.index_of_nth_char(max), text.index_of_nth_char(text.char_count()) - text.index_of_nth_char(max));
            text = pre + txt + post;

            caret_position = min + txt.char_count();
            selection_start = selection_end = 0;
        }

        update_caret();
    }

    protected override void on_text_input(TextInputArgs t)
    {
        ime_editing = false;

        int min = caret_position, max = caret_position;
        if (selection_start != selection_end)
        {
            min = int.min(selection_start, selection_end);
            max = int.max(selection_start, selection_end);
        }

        string txt = t.text;
        string pre = text.substring(0, text.index_of_nth_char(min));
        string post = text.substring(text.index_of_nth_char(max), text.index_of_nth_char(text.char_count()) - text.index_of_nth_char(max));

        text = pre + txt + post;
        caret_position = min + txt.char_count();
        selection_start = selection_end = 0;

        update_caret();
    }

    protected override void on_text_edit(TextEditArgs t)
    {

        if (t.length == 0 && t.start == 0 && t.text == "")
        {
            ime_editing = false;
            ime_label.visible = false;
            ime_rect.visible = false;
            //ime_caret.visible = false;
            return;
        }

        ime_editing = true;
        ime_label.visible = true;
        ime_rect.visible = true;
        //ime_caret.visible = true;

        ime_label.text = t.text;
        ime_label.position = caret.position;
        ime_rect.position = ime_label.position;
        ime_rect.size = Size2(ime_label.size.width, ime_rect.size.height);

        /* The length in the SDL message is broken, can't use this
        string start_text = t.text.substring(0, t.text.index_of_nth_char(t.start));
        string end_text = t.text.substring(t.text.index_of_nth_char(t.start), t.length - t.text.index_of_nth_char(t.start));
        LabelInfo info = LabelLoader.get_label_info_static(ime_label.font_type, ime_label.font_size, start_text);
        float start_pos = info.size.width + ime_label.position.x;
        info = LabelLoader.get_label_info_static(ime_label.font_type, ime_label.font_size, end_text);
        float width = info.size.width;

        ime_caret.position = Vec2(start_pos , 0);
        ime_caret.set_size(Size2(width, ime_caret.size.height));
        */
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

        selection.size = Size2(end - start, selection.size.height);
        selection.position = Vec2(start, 0);
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

    public string text
    {
        get { return _text; }
        set
        {
            _text = value;
            update_text();
        }
    }
}
