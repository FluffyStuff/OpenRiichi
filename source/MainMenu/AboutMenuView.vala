using Engine;
using Gee;

private class AboutMenuView : MenuSubView
{
    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

            return buttons;
    }

    public override void load()
    {
        int padding = 20;

        LabelControl label = new LabelControl();
        add_child(label);
        label.font_size = 28;
        label.outer_anchor = Vec2(0.5f, 1);
        label.inner_anchor = Vec2(0.5f, 1);
        label.position = Vec2(0, -(top_offset + padding));

        string[] text =
        {
            "",
            "OpenRiichi " + Environment.version_info.to_string(),
            "https://github.com/FluffyStuff/OpenRiichi",
            "OpenRiichi is licensed under GPLv3. Visit the link above for the license.",
            ""
        };
        label.text = FileLoader.array_to_string(text);
    }
    
    public override string get_name() { return "About"; }
}