public static int main(string[] args)
{
    Environment environment = new Environment();
    if (!environment.init())
        return -1;

    while (true)
    {
        Options options = new Options.from_disk();
        environment.set_multisampling(options.anti_aliasing == Options.OnOffEnum.ON ? 2 : 0);

        bool fullscreen = options.fullscreen == Options.OnOffEnum.ON;
        var wnd = environment.createWindow("RiichiMahjong", 1280, 720, fullscreen);
        if (wnd == null)
        {
            print("main: Could not create window!\n");
            return -1;
        }

        var context = environment.create_context(wnd);
        if (context == null)
        {
            print("main: Could not create graphics context!\n");
            return -1;
        }

        SDLWindowTarget sdlWindow = new SDLWindowTarget((owned)wnd, (owned)context, fullscreen);
        OpenGLRenderer renderer = new OpenGLRenderer(sdlWindow);
        MainWindow window = new MainWindow(sdlWindow, renderer);

        if (!renderer.start())
            return -1;

        window.show();

        if (!window.do_restart)
            break;
    }

    return 0;
}
