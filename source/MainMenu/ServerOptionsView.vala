public class ServerOptionsView : View2D
{
    private MenuTextButton create_button;
    private MenuTextButton back_button;
    private TextInputControl name_text;

    public signal void finished(string name);
    public signal void back();

    protected override void added()
    {
        LabelControl label = new LabelControl();
        add_child(label);
        label.text = "Create Server";
        label.font_size = 40;
        label.outer_anchor = Vec2(0.5f, 1);
        label.inner_anchor = Vec2(0.5f, 1);
        label.position = Vec2(0, -60);

        int padding = 50;

        name_text = new TextInputControl("Player name");
        add_child(name_text);
        name_text.position = Vec2(0, 0);

        create_button = new MenuTextButton("MenuButton", "Create");
        add_child(create_button);
        create_button.outer_anchor = Vec2(0.5f, 0);
        create_button.inner_anchor = Vec2(1, 0);
        create_button.position = Vec2(-padding, padding);
        create_button.clicked.connect(create_clicked);
        create_button.enabled = false;

        back_button = new MenuTextButton("MenuButton", "Back");
        add_child(back_button);
        back_button.outer_anchor = Vec2(0.5f, 0);
        back_button.inner_anchor = Vec2(0, 0);
        back_button.position = Vec2(padding, padding);
        back_button.clicked.connect(back_clicked);

        name_text.text_changed.connect(name_changed);
    }

    private void name_changed()
    {
        string name = name_text.text.strip();
        create_button.enabled = (name.char_count() > 0 && name.char_count() < 20);
    }

    private void create_clicked()
    {
        finished(name_text.text);
    }

    private void back_clicked()
    {
        back();
    }
}
