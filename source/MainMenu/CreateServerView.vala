using Engine;
using Gee;

class CreateServerView : MenuSubView
{
    private MenuTextButton? create_button;
    private TextInputControl name_text;

    protected override void load()
    {
        name_text = new TextInputControl("Player name", Environment.MAX_NAME_LENGTH);
        name_text.text_changed.connect(name_changed);
        add_child(name_text);
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        create_button = new MenuTextButton("MenuButton", "Create");
        create_button.clicked.connect(do_finish);
        buttons.add(create_button);

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

        return buttons;
    }

    protected override void load_finished()
    {
        name_changed();
    }

    protected override void set_visibility(bool visible)
    {
        name_text.visible = visible;
    }

    private void name_changed()
    {
        if (create_button != null)
            create_button.enabled = Environment.is_valid_name(name_text.text);
    }

    public string player_name { get { return name_text.text; } }
    public override string get_name() { return "Create Server"; }
}
