using SDL;
using GL;

public class MainWindow : RenderWindow
{
    private GameView gameView;

    public MainWindow(IWindowTarget window, IRenderTarget renderer)
    {
        base(window, renderer);

        gameView = new GameView();
        main_view.add_child(gameView);
        back_color = Color() { r = 0, g = 0.01f, b = 0.02f };
    }

    protected override void do_process(double dt)
    {
        Event e;

        while (Event.poll(out e) != 0)
        {
            if (e.type == EventType.QUIT)
                finish();
            else if (e.type == EventType.KEYDOWN)
                key(e.key.keysym.sym);
            else if (e.type == EventType.MOUSEMOTION)
            {
                int x = 0, y = 0;
                Cursor.get_relative_state(ref x, ref y);
                main_view.mouse_move(x, y);
            }
            else if (e.type == EventType.MOUSEBUTTONDOWN || e.type == EventType.MOUSEBUTTONUP)
                ;
            else if (e.type == EventType.MOUSEWHEEL)
                ;
        }

        main_view.process(dt);
    }

    private void key(char key)
    {
        switch (key)
        {
            case 27 :
            case 'q':
                finish();
                break;
            case 'f':
                fullscreen = !fullscreen;
                break;
            default:
                main_view.key_press(key);
                break;
        }
    }
}
