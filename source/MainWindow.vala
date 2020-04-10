using Engine;
using GameServer;

public class MainWindow : RenderWindow
{
    private MainMenuControlView? menu;
    private View2D game_view;
    private GameController? game_controller = null;
    private GameEscapeMenuView? escape_menu;
    private bool game_running = false;
    private MusicPlayer music;

    public MainWindow(IWindowTarget window, RenderTarget renderer)
    {
        base(window, renderer);
        back_color = Color(0, 0.01f, 0.02f, 1);
    }

    protected override void shown()
    {
        set_icon("./Data/Icon.png");
        music = new MusicPlayer(store.audio_player);

        Options options = new Options.from_disk();
        load_options(options);

        create_main_menu();

        game_view = new View2D();
        main_view.add_child(game_view);
    }

    private void create_main_menu()
    {
        menu = new MainMenuControlView();
        menu.game_start.connect(game_start);
        menu.restart.connect(restart);
        menu.quit.connect(quit);
        main_view.add_child(menu);
    }

    private GameController game_start(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index)
    {
        menu.visible = false;
        game_controller = new GameController(game_view, info, settings, connection, player_index, new Options.from_disk());
        game_controller.finished.connect(game_finished);
        game_running = true;

        return game_controller;
    }

    private void game_finished()
    {
        game_running = false;
        game_controller = null;
        menu.visible = true;
        if (escape_menu != null)
        {
            main_view.remove_child(escape_menu);
            escape_menu = null;
        }
    }

    private void leave_game_pressed()
    {
        game_controller.finished();
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
            game_controller.process(delta);
    }

    protected override bool key_press(KeyArgs key)
    {
        if (key.scancode == ScanCode.F12)
        {
            if (key.down)
                fullscreen = !fullscreen;
            return true;
        }
        else if (key.scancode == ScanCode.ESCAPE)
        {
            if (game_running && key.down)
            {
                if (escape_menu == null)
                {
                    escape_menu = new GameEscapeMenuView();
                    escape_menu.apply_options.connect(apply_options);
                    escape_menu.close_menu.connect(close_menu);
                    escape_menu.leave_game.connect(leave_game_pressed);
                    main_view.add_child(escape_menu);
                }
                else
                {
                    main_view.remove_child(escape_menu);
                    escape_menu = null;
                }
            }

            return true;
        }

        return false;
    }

    private void close_menu()
    {
        main_view.remove_child(escape_menu);
        escape_menu = null;
    }

    private void apply_options(Options options)
    {
        load_options(options);
        game_controller.load_options(options);
    }

    private void load_options(Options options)
    {
        renderer.anisotropic_filtering = options.anisotropic_filtering == OnOffEnum.ON;
        renderer.v_sync = options.v_sync == OnOffEnum.ON;
        store.audio_player.muted = options.sounds == OnOffEnum.OFF;
        fullscreen = options.fullscreen == OnOffEnum.ON;

        if (options.music == OnOffEnum.ON)
            music.start();
        else
            music.stop();
    }

    public bool do_restart { get; private set; }
}
