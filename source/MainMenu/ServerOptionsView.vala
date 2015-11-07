public class ServerOptionsView : View2D
{
    private GameMenuButton create_button;
    private GameMenuButton back_button;
    private TextInputView name_text;

    public signal void finished(string name);
    public signal void back();

    protected override void added()
    {
        LabelControl label = new LabelControl(store);
        label.text = "Create Server";
        label.font_size = 40;
        label.outer_anchor = Vec2(0.5f, 1);
        label.inner_anchor = Vec2(0.5f, 1);
        add_control(label);

        int padding = 50;

        name_text = new TextInputView(store, "Player name");
        name_text.position = Vec2(0, 0);
        add_control(name_text);

        create_button = new GameMenuButton(store, "CreateServer");
        create_button.outer_anchor = Vec2(0.5f, 0);
        create_button.inner_anchor = Vec2(1, 0);
        create_button.position = Vec2(-padding, padding);
        create_button.clicked.connect(create_clicked);
        create_button.enabled = false;
        add_control(create_button);

        back_button = new GameMenuButton(store, "Back");
        back_button.outer_anchor = Vec2(0.5f, 0);
        back_button.inner_anchor = Vec2(0, 0);
        back_button.position = Vec2(padding, padding);
        back_button.clicked.connect(back_clicked);
        add_control(back_button);

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
