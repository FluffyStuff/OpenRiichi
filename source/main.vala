using Engine;

private static bool debug =
#if DEBUG
    true
#else
    false
#endif
;

private static bool multithread_rendering = false;

private static string? arg_search_dir = null;

private static void parse_args(string[] args)
{
    for (int i = 1; i < args.length; i++)
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
        else if (arg == "-search-directory")
        {
            i++;

            if (i < args.length)
                arg_search_dir = args[i];
        }
    }
}

private static void show_error(string message)
{
    Environment.log(LogType.ERROR, "Main", message);
    show_error_message_box("OpenRiichi (" + Environment.version_info.to_string() + ") startup error", message + "\n" + "Look at logs for more details");
}

public static int main(string[] args)
{
    string? executable_dir = args.length > 0 ? GLib.Path.get_dirname(args[0]) : null;
    string? built_search_dir = Build.SEARCH_DIR;

    parse_args(args);

    if (!Environment.init(debug))
    {
        show_error("Could not init environment");
        return -1;
    }

    FileLoader.init();
    FileLoader.add_search_path(executable_dir);
    FileLoader.add_search_path(built_search_dir);
    FileLoader.add_search_path(arg_search_dir);

    while (true)
    {
        Options options = new Options.from_disk();
        int multisamples = options.anti_aliasing == OnOffEnum.ON ? 2 : 0;
        Size2i window_size = Size2i(options.window_width, options.window_height);
        Vec2i window_position = Vec2i(options.window_x, options.window_y);
        string window_name = "OpenRiichi";

        SDLGLEngine engine = new SDLGLEngine(multithread_rendering, Environment.version_info.to_string(), debug);
        if (!engine.init(window_name, window_size, window_position, options.screen_type, multisamples))
        {
            show_error("Could not init engine");
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