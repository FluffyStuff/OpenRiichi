public static int main(string[] args)
{
    Environment environment = new Environment();
    if (!environment.init())
        return -1;

    //Threading.start1(start_game, environment);
    SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLEBUFFERS, 1);
    SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLESAMPLES, 4);
    start_game(environment);

    return 0;
}

private static void start_game(Object env)
{
    Environment environment = (Environment)env;

    SDL.Window wnd = environment.createWindow("RiichiMahjong", 1280, 720);
    SDLWindowTarget sdlWindow = new SDLWindowTarget(wnd);
    OpenGLRenderer renderer = new OpenGLRenderer(sdlWindow);
    MainWindow window = new MainWindow(sdlWindow, renderer);

    if (!renderer.start())
        return;

    window.show();

    renderer.stop();
}
