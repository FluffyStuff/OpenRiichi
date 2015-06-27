private static Environment environment;

public static int main(string[] args)
{
    environment = new Environment();
    if (!environment.init())
        return -1;

    //Threading.start0(start_game);
    start_game();

    return 0;
}

private static void start_game()
{
    SDL.Window wnd = environment.createWindow("RiichiMahjong", 1280, 800);
    SDLWindowTarget sdlWindow = new SDLWindowTarget(wnd);
    OpenGLRenderer renderer = new OpenGLRenderer(sdlWindow);
    MainWindow window = new MainWindow(sdlWindow, renderer);

    if (!renderer.start())
        return;

    window.show();

    renderer.stop();
}
