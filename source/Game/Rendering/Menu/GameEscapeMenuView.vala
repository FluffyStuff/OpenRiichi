using Engine;
using Gee;

public class GameEscapeMenuView : View2D
{
    private OptionsMenuView options_view;
    private MenuTextButton back_button;
    private MenuTextButton options_button;
    private MenuTextButton leave_button;
    private MenuTextButton confirm_yes_button;
    private MenuTextButton confirm_no_button;
    private LabelControl confirm_label;

    public signal void close_menu();
    public signal void apply_options(Options options);
    public signal void leave_game();

    protected override void added()
    {
        RectangleControl background = new RectangleControl();
        add_child(background);
        background.color = Color.with_alpha(0.7f);
        background.resize_style = ResizeStyle.RELATIVE;
        background.selectable = true;
        background.cursor_type = CursorType.NORMAL;

        back_button = new MenuTextButton("MenuButton", "Back");
        options_button = new MenuTextButton("MenuButton", "Options");
        leave_button = new MenuTextButton("MenuButton", "Leave Game");
        confirm_yes_button = new MenuTextButton("MenuButton", "Yes");
        confirm_no_button = new MenuTextButton("MenuButton", "No");
        confirm_label = new LabelControl();

        back_button.clicked.connect(press_back);
        options_button.clicked.connect(press_options);
        leave_button.clicked.connect(press_leave);

        confirm_yes_button.clicked.connect(press_yes);
        confirm_no_button.clicked.connect(press_no);

        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        buttons.add(back_button);
        buttons.add(options_button);
        buttons.add(leave_button);

        int padding = 30;

        for (int i = 0; i < buttons.size; i++)
        {
            MenuTextButton button = buttons[buttons.size - 1 - i];
            add_child(button);
            float height = button.size.height + padding;

            button.position = Vec2(0, (i - buttons.size / 2.0f + 0.5f) * height);
        }

        add_child(confirm_yes_button);
        confirm_yes_button.inner_anchor = Vec2(1, 1);
        confirm_yes_button.position = Vec2(-padding, 0);
        confirm_yes_button.visible = false;

        add_child(confirm_no_button);
        confirm_no_button.inner_anchor = Vec2(0, 1);
        confirm_no_button.position = Vec2(padding, 0);
        confirm_no_button.visible = false;

        add_child(confirm_label);
        confirm_label.position = Vec2(0, padding * 2);
        confirm_label.visible = false;
        confirm_label.font_size = 60;
        confirm_label.text = "Are you sure you want to leave the current game?";

        options_view = new OptionsMenuView();
        options_view.finish.connect(options_apply);
        options_view.back.connect(options_back);
        add_child(options_view);
        options_view.visible = false;
    }

    protected override void key_press(KeyArgs key)
    {
        key.handled = true;
    }

    private void press_back()
    {
        close_menu();
    }

    private void show_main()
    {
        back_button.visible = true;
        options_button.visible = true;
        leave_button.visible = true;
        confirm_yes_button.visible = false;
        confirm_no_button.visible = false;
        confirm_label.visible = false;
        options_view.visible = false;
    }

    private void press_options()
    {
        back_button.visible = false;
        options_button.visible = false;
        leave_button.visible = false;
        options_view.visible = true;
    }

    private void press_leave()
    {
        back_button.visible = false;
        options_button.visible = false;
        leave_button.visible = false;
        confirm_yes_button.visible = true;
        confirm_no_button.visible = true;
        confirm_label.visible = true;
    }

    private void press_yes()
    {
        leave_game();
    }

    private void press_no()
    {
        show_main();
    }

    private void options_back()
    {
        show_main();
    }

    private void options_apply()
    {
        apply_options(options_view.options);
        show_main();
    }
}
