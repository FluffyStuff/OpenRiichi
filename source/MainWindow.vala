using SDL;
using GL;
using GameServer;

public class MainWindow : RenderWindow
{
    private MainMenuView menu = new MainMenuView();
    private GameController? game_controller = null;
    private bool game_running = false;

    public MainWindow(IWindowTarget window, IRenderTarget renderer)
    {
        base(window, renderer);
        back_color = Color() { r = 0, g = 0.01f, b = 0.02f };

        menu.game_start.connect(game_start);
        menu.quit.connect(quit);
        main_view.add_child(menu);
    }

    private void game_start(GameStartState state)
    {
        main_view.remove_child(menu);
        game_controller = new GameController(main_view, state);
        game_running = true;
    }

    private void quit()
    {
        finish();
    }

    protected override void do_process(DeltaArgs delta)
    {
        if (game_running && game_controller != null)
            game_controller.process();
    }

    protected override bool key_press(KeyArgs key)
    {
        switch (key.key)
        {
            case 27 :
            case 'q':
                finish();
                break;
            case 'f':
                fullscreen = !fullscreen;
                break;
            default:
                return false;
        }

        return true;
    }
}
