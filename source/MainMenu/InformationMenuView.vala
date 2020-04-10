using Engine;
using Gee;

class InformationMenuView : MenuSubView
{
    public InformationMenuView(string text)
    {
        this.text = text;
    }

    protected override void load()
    {
        LabelControl message_label = new LabelControl();
        add_child(message_label);
        message_label.text = text;
        message_label.font_size = 50;
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        MenuTextButton ok_button = new MenuTextButton("MenuButton", "OK");
        ok_button.clicked.connect(do_back);
        buttons.add(ok_button);

        return buttons;
    }

    public string text { get; private set; }
}
