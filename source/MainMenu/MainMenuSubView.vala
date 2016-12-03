using Gee;

abstract class MainMenuSubView : View2D
{
    private const int padding = 30;

    private signal void _finish(MainMenuSubView view);
    private signal void _back(MainMenuSubView view);
    public signal void finish(MainMenuSubView view);
    public signal void back(MainMenuSubView view);

    protected virtual void load() {}
    protected virtual void load_finished() {}
    protected virtual string get_name() { return ""; }
    protected virtual void set_visibility(bool visible) {}
    protected virtual ArrayList<MenuTextButton>? get_main_buttons() { return null; }
    protected virtual ArrayList<MenuTextButton>? get_menu_buttons() { return null; }

    protected void do_finish() { _finish(this); finish(this); }
    protected void do_back() { _back(this); back(this); }

    private LabelControl? name_label;
    private SizingControl main_buttons_control = new SizingControl();
    private SizingControl menu_buttons_control = new SizingControl();
    private ArrayList<MenuTextButton>? main_buttons;
    private ArrayList<MenuTextButton>? menu_buttons;

    protected override void added()
    {
        string name = get_name();

        if (name != "")
        {
            name_label = new LabelControl();
            add_child(name_label);
            name_label.text = name;
            name_label.font_size = 40;
            name_label.outer_anchor = Vec2(0.5f, 1);
            name_label.inner_anchor = Vec2(0.5f, 1);
        }

        add_child(main_buttons_control);
        main_buttons_control.orientation = Orientation.VERTICAL;
        main_buttons_control.sizing_style = SizingStyle.AUTOSIZE;
        main_buttons_control.outer_anchor = Vec2(0.5f, 1);
        main_buttons_control.inner_anchor = Vec2(0.5f, 1);
        main_buttons_control.position = Vec2(0, -(top_offset + padding));
        main_buttons_control.padding = padding;

        add_child(menu_buttons_control);
        menu_buttons_control.orientation = Orientation.HORIZONTAL;
        menu_buttons_control.sizing_style = SizingStyle.AUTOSIZE;
        menu_buttons_control.outer_anchor = Vec2(0.5f, 0);
        menu_buttons_control.inner_anchor = Vec2(0.5f, 0);
        menu_buttons_control.position = Vec2(0, padding);
        menu_buttons_control.padding = padding;

        load();

        main_buttons = get_main_buttons();
        menu_buttons = get_menu_buttons();

        if (main_buttons != null)
            foreach (MenuTextButton button in main_buttons)
                main_buttons_control.add_control(button);

        if (menu_buttons != null)
            foreach (MenuTextButton button in menu_buttons)
                menu_buttons_control.add_control(button);

        load_finished();
    }

    public void load_sub_view(MainMenuSubView view)
    {
        view._finish.connect(sub_finished);
        view._back.connect(sub_finished);
        visibility_change(false);
        add_child(view);
    }

    private void sub_finished(MainMenuSubView view)
    {
        view._finish.disconnect(sub_finished);
        view._back.disconnect(sub_finished);
        remove_child(view);
        visibility_change(true);
    }

    private void visibility_change(bool visible)
    {
        if (name_label != null)
            name_label.visible = visible;
        if (main_buttons != null)
            foreach (MenuTextButton button in main_buttons)
                button.visible = visible;
        if (menu_buttons != null)
            foreach (MenuTextButton button in menu_buttons)
                button.visible = visible;

        set_visibility(visible);
    }

    public float top_offset { get { return name_label == null ? 0 : name_label.size.height; } }
    public float bottom_offset { get { return menu_buttons_control.size.height + menu_buttons_control.position.y; } }
}
