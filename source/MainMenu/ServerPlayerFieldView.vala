using Engine;
using Gee;

public class ServerPlayerFieldView : Control
{
    private const string[] BOTS = { "NullBot", "SimpleBot" };

    private bool editable;
    private int slot;
    private LabelControl name_label;
    private RectangleControl border;
    private RectangleControl background;
    private GameMenuButton expand_button;
    private ArrayList<TextClickControl> texts = new ArrayList<TextClickControl>();

    public signal void kick(int slot);
    public signal void add_bot(string name, int slot);

    public ServerPlayerFieldView(bool editable, int slot)
    {
        this.editable = editable;
        this.slot = slot;
    }

    public override void added()
    {
        border = new RectangleControl();
        add_child(border);
        border.color = Color(0.3f, 0.01f, 0.01f, 1);

        background = new RectangleControl();
        add_child(background);
        background.resize_style = ResizeStyle.RELATIVE;
        background.color = Color(0.6f, 0.02f, 0.02f, 1);

        name_label = new LabelControl();
        add_child(name_label);
        name_label.inner_anchor = Vec2(0, 0.5f);
        name_label.outer_anchor = Vec2(0, 0.5f);
        name_label.text = "Open";
        name_label.position = Vec2(10, 0);

        if (editable)
        {
            expand_button = new GameMenuButton("Expand");
            add_child(expand_button);
            expand_button.inner_anchor = Vec2(1, 0.5f);
            expand_button.outer_anchor = Vec2(1, 0.5f);
            expand_button.clicked.connect(expand_clicked);

            TextClickControl control = new TextClickControl("Open");
            control.clicked.connect(kick_clicked);
            texts.add(control);

            foreach (string bot in BOTS)
            {
                control = new TextClickControl(bot);
                control.clicked.connect(add_bot_clicked);
                texts.add(control);
            }

            for (int i = 0; i < texts.size; i++)
            {
                var text = texts[i];
                add_child(text);
                text.inner_anchor = Vec2(0, 1);
                text.outer_anchor = Vec2(0, 0);
                text.visible = false;
            }
        }

        resize_style = ResizeStyle.ABSOLUTE;
    }

    protected override void mouse_event(MouseEventArgs mouse)
    {
        base.mouse_event(mouse);

        if (!editable || expand_button.focused)
            return;

        bool focus = false;
        foreach (TextClickControl control in texts)
        {
            if (control.focused)
            {
                focus = true;
                break;
            }
        }

        if (!focus)
            menu_toggle(false);
    }

    protected override void resized()
    {
        border.size = Size2(size.width + 6, size.height + 6);

        for (int i = 0; i < texts.size; i++)
        {
            texts[i].position = Vec2(0, -size.height * i);
            texts[i].size = size;
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

    private void kick_clicked()
    {
        kick(slot);
        menu_toggle(false);
    }

    private void add_bot_clicked(Control control, Vec2 position)
    {
        var text = control as TextClickControl;
        add_bot(text.text, slot);
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

    public bool assigned { get; private set; }

    private class TextClickControl : Control
    {
        private RectangleControl background = new RectangleControl();
        private LabelControl label;

        private Sound click_sound;
        private Sound hover_sound;

        public TextClickControl(string text)
        {
            this.text = text;
            selectable = true;
        }

        protected override void added()
        {
            click_sound = store.audio_player.load_sound("click");
            hover_sound = store.audio_player.load_sound("mouse_over");

            add_child(background);
            background.color = Color(0.6f, 0.02f, 0.02f, 1);
            background.resize_style = ResizeStyle.RELATIVE;

            label = new LabelControl();
            add_child(label);
            label.inner_anchor = Vec2(0, 0.5f);
            label.outer_anchor = Vec2(0, 0.5f);
            label.text = text;
            label.position = Vec2(10, 0);
        }

        protected override void render(RenderState state, RenderScene2D scene)
        {
            if (hovering)
            {
                if (mouse_pressed)
                    background.color = Color(0.75f, 0.025f, 0.025f, 1);
                else
                    background.color = Color(0.9f, 0.03f, 0.03f, 1);
            }
            else
                background.color = Color(0.6f, 0.02f, 0.02f, 1);
        }

        protected override void on_mouse_over()
        {
            hover_sound.play();
        }

        protected override void on_click(Vec2 position)
        {
            click_sound.play();
        }

        public string text { get; private set; }
    }
}
