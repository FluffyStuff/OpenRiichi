using SDL;
using GL;
using GameServer;

public class MainWindow : RenderWindow
{
    private MainMenuView? menu;
    private GameController? game_controller = null;
    private bool game_running = false;
    private MusicPlayer music;

    public MainWindow(IWindowTarget window, IRenderTarget renderer)
    {
        base(window, renderer);
        back_color = Color(0, 0.01f, 0.02f, 1);
    }

    protected override void shown()
    {
        set_icon("./Data/Icon.png");

        Options options = new Options.from_disk();

        renderer.anisotropic_filtering = options.anisotropic_filtering == Options.OnOffEnum.ON;
        renderer.v_sync = options.v_sync == Options.OnOffEnum.ON;
        store.audio_player.muted = options.sounds == Options.OnOffEnum.OFF;

        create_main_menu();

        if (options.music == Options.OnOffEnum.ON)
        {
            music = new MusicPlayer(store.audio_player);
            music.start();
        }
    }

    private void create_main_menu()
    {
        menu = new MainMenuView();
        menu.game_start.connect(game_start);
        menu.restart.connect(restart);
        menu.quit.connect(quit);
        main_view.add_child(menu);
    }

    private void game_start(GameStartInfo info, IGameConnection connection, int player_index)
    {
        main_view.remove_child(menu);
        menu = null;
        game_controller = new GameController(main_view, info, connection, player_index, new Options.from_disk());
        game_controller.finished.connect(game_finished);
        game_running = true;
    }

    private void game_finished()
    {
        game_running = false;
        game_controller = null;
        create_main_menu();
    }

    private void restart()
    {
        do_restart = true;
        finish();
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
        if (key.scancode == ScanCode.F12)
        {
            fullscreen = !fullscreen;
            return true;
        }

        return false;
    }

    public bool do_restart { get; private set; }
}
