using Engine;
using Gee;

class SingleplayerMenuView : MenuSubView
{
    private GameController controller; // Fix include bug in vala

    public SingleplayerMenuView()
    {
        controller = null; // Ignore warning
    }

    public signal GameController menu_game_start(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index);

    private void create_game_clicked()
    {
        CreateServerView view = new CreateServerView();
        view.finish.connect(create_game);
        load_sub_view(view);
    }

    private void load_log_clicked()
    {
        SelectGameLogMenuView view = new SelectGameLogMenuView();
        view.finish.connect(load_log);
        load_sub_view(view);
    }

    protected override ArrayList<MenuTextButton>? get_main_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        MenuTextButton create_button = new MenuTextButton("MenuButtonBig", "Create Game");
        create_button.clicked.connect(create_game_clicked);
        buttons.add(create_button);

        MenuTextButton log_button = new MenuTextButton("MenuButtonBig", "Load Log");
        log_button.clicked.connect(load_log_clicked);
        buttons.add(log_button);

        return buttons;
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

        return buttons;
    }

    private void create_game(MenuSubView view)
    {
        CreateServerView v = (CreateServerView)view;
        ServerMenuView s = new ServerMenuView.create_server(v.player_name, false);
        s.start.connect(game_start);
        load_sub_view(s);
    }

    private void load_log(MenuSubView view)
    {
        SelectGameLogMenuView v = (SelectGameLogMenuView)view;
        ServerMenuView s = new ServerMenuView.use_log(v.log);
        s.start.connect(game_start);
        load_sub_view(s);
    }

    private void game_start(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index)
    {
        menu_game_start(info, settings, connection, player_index);
    }

    protected override string get_name() { return "Singleplayer"; }
}
