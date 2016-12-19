private static bool debug =
#if DEBUG
    true
#else
    false
#endif
;

private static bool multithread_rendering = true;

private static void parse_args(string[] args)
{
    for (int i = 0; i < args.length; i++)
    {
        string arg = args[i];
        if (arg.length == 0 || arg[0] != '-')
            continue;
        arg = arg.substring(1);

        if (arg == "d" || arg == "-debug")
            debug = true;
        else if (arg == "-no-debug")
            debug = false;
        else if (arg == "-multithread-rendering")
            multithread_rendering = true;
        else if (arg == "-no-multithread-rendering")
            multithread_rendering = false;
    }
}

public static int main(string[] args)
{
    parse_args(args);

    Environment.init(debug);

    while (true)
    {
        Options options = new Options.from_disk();
        int multisamples = options.anti_aliasing == Options.OnOffEnum.ON ? 2 : 0;
        bool fullscreen = options.fullscreen == Options.OnOffEnum.ON;
        string window_name = "OpenRiichi";
        int window_width = 1280, window_height = 720;

        SDLGLEngine engine = new SDLGLEngine(multithread_rendering);
        if (!engine.init(window_name, window_width, window_height, multisamples, fullscreen))
        {
            Environment.log(LogType.ERROR, "Main", "Could not init engine");
            return -1;
        }

        MainWindow window = new MainWindow(engine.window, engine.renderer);

        window.show();
        engine.stop();

        if (!window.do_restart)
            break;
    }

    Environment.log(LogType.INFO, "Main", "Application stopped normally");

    return 0;
}
