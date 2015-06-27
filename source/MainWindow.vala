using SDL;
using GL;

public class MainWindow : RenderWindow
{
    private GameController game_controller;

    public MainWindow(IWindowTarget window, IRenderTarget renderer)
    {
        base(window, renderer);

        game_controller = new GameController(main_view, new GameStartState());
        back_color = Color() { r = 0, g = 0.01f, b = 0.02f };
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
