public static int main(string[] args)
{
    Environment environment = new Environment();
    if (!environment.init())
        return -1;

    SDL.Window wnd = environment.createWindow("RiichiMahjong", 1280, 800);
    SDLWindowTarget sdlWindow = new SDLWindowTarget(wnd);
    OpenGLRenderer renderer = new OpenGLRenderer(sdlWindow);
    MainWindow window = new MainWindow(sdlWindow, renderer);

    if (!renderer.start())
        return -1;

    window.show();

    return 0;
}
