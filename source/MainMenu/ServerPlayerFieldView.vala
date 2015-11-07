using Gee;

public class ServerPlayerFieldView : Control
{
    private IResourceStore store;
    private bool editable;
    private int slot;
    private LabelControl name_label;
    private ArrayList<TextClickControl> texts = new ArrayList<TextClickControl>();
    private Size2 _size = Size2(100, 100);

    public signal void kick(int slot);
    public signal void add_bot(string name, int slot);

    public ServerPlayerFieldView(IResourceStore store, bool editable, int slot)
    {
        this.store = store;
        this.editable = editable;
        this.slot = slot;
        resize_style = ResizeStyle.ABSOLUTE;
    }

    public override void on_added()
    {
        RectangleControl border = new RectangleControl();
        border.color = Color(0.05f, 0, 0.4f, 1);
        border.set_size(Size2(size.width + 6, size.height + 6));

        RectangleControl rect = new RectangleControl();
        rect.color = Color(0.1f, 0, 0.8f, 1);
        rect.set_size(size);
        add_control(border);
        add_control(rect);

        name_label = new LabelControl(store);
        name_label.inner_anchor = Vec2(0, 0.5f);
        name_label.outer_anchor = Vec2(0, 0.5f);
        name_label.text = "Open";
        name_label.position = Vec2(10, 0);
        add_control(name_label);

        if (editable)
        {
            GameMenuButton expand_button = new GameMenuButton(store, "Expand");
            expand_button.inner_anchor = Vec2(1, 0.5f);
            expand_button.outer_anchor = Vec2(1, 0.5f);
            expand_button.clicked.connect(expand_clicked);
            add_control(expand_button);

            TextClickControl control = new TextClickControl(store, "Open");
            control.clicked.connect(kick_clicked);
            texts.add(control);
            control = new TextClickControl(store, "NullBot");
            control.clicked.connect(add_bot_clicked);
            texts.add(control);

            for (int i = 0; i < texts.size; i++)
            {
                var text = texts[i];
                text.inner_anchor = Vec2(0, 1);
                text.outer_anchor = Vec2(0, 0);
                text.position = Vec2(0, -size.height * i);
                text.visible = false;
                add_control(text);
                text.set_size(size);
            }
        }
    }

    private void expand_clicked()
    {
        menu_toggle(true);
    }

    private void menu_toggle(bool open)
    {
        foreach (TextClickControl text in texts)
            text.visible = open;
    }

    protected override void on_child_focus_lost()
    {
        menu_toggle(false);
    }

    private void kick_clicked()
    {
        kick(slot);
        menu_toggle(false);
    }

    private void add_bot_clicked()
    {
        add_bot("NullBot", slot);
        menu_toggle(false);
    }

    public void assign(string name)
    {
        name_label.text = name;
        assigned = true;
    }

    public void unassign()
    {
        name_label.text = "Open";
        assigned = false;
    }

    public void set_size(Size2 size)
    {
        _size = size;
        resize();
    }

    public override void do_render(RenderScene2D scene) {}
    public override void do_resize(Vec2 new_position, Size2 new_scale) {}

    public override Size2 size { get { return _size; } }
    public bool assigned { get; private set; }

    private class TextClickControl : Control
    {
        private IResourceStore store;
        private string text;
        private RectangleControl background = new RectangleControl();
        private LabelControl label;
        private Size2 _size;

        public TextClickControl(IResourceStore store, string text)
        {
            this.store = store;
            this.text = text;
            selectable = true;
        }

        protected override void on_added()
        {
            background.color = Color(0.1f, 0, 0.8f, 1);
            add_control(background);

            label = new LabelControl(store);
            label.inner_anchor = Vec2(0, 0.5f);
            label.outer_anchor = Vec2(0, 0.5f);
            label.text = text;
            label.position = Vec2(10, 0);
            add_control(label);
        }

        public void set_size(Size2 size)
        {
            _size = size;
            resize();
        }

        public override void do_render(RenderScene2D scene)
        {
            if (hovering)
            {
                if (mouse_down)
                    background.color = Color(0.4f, 0.3f, 1, 1);
                else
                    background.color = Color(0.6f, 0.5f, 1, 1);
            }
            else
                background.color = Color(0.1f, 0, 0.8f, 1);
        }

        public override void do_resize(Vec2 new_position, Size2 new_scale)
        {
            background.set_size(size);
        }

        public override Size2 size { get { return _size; } }
    }
}
