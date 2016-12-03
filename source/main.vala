private static bool debug =
#if DEBUG
    true
#else
    false
#endif
;

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
    }
}

public static int main(string[] args)
{
    parse_args(args);

    Environment.init(debug);

    Engine engine = new Engine();
    if (!engine.init())
    {
        Environment.log(LogType.ERROR, "Main", "Could not init engine");
        return -1;
    }

    while (true)
    {
        Options options = new Options.from_disk();
        engine.set_multisampling(options.anti_aliasing == Options.OnOffEnum.ON ? 2 : 0);

        bool fullscreen = options.fullscreen == Options.OnOffEnum.ON;
        var wnd = engine.create_window("OpenRiichi", 1280, 720, fullscreen);
        if (wnd == null)
        {
            Environment.log(LogType.ERROR, "Main", "Could not create window");
            return -1;
        }

        var context = engine.create_context(wnd);
        if (context == null)
        {
            Environment.log(LogType.ERROR, "Main", "Could not create graphics context");
            return -1;
        }

        SDLWindowTarget sdlWindow = new SDLWindowTarget((owned)wnd, (owned)context, fullscreen);
        OpenGLRenderer renderer = new OpenGLRenderer(sdlWindow);
        MainWindow window = new MainWindow(sdlWindow, renderer);

        if (!renderer.start())
        {
            Environment.log(LogType.ERROR, "Main", "Could not start renderer");
            return -1;
        }

        window.show();

        if (!window.do_restart)
            break;
    }

    Environment.log(LogType.INFO, "Main", "Application stopped normally");

    return 0;
}
