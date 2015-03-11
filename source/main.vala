public static int main(string[] args)
{
    if (!Environment.init())
        return -1;

    SDLWindowTarget sdlWindow = new SDLWindowTarget(Environment.window);
    OpenGLRenderer renderer = new OpenGLRenderer(sdlWindow);
    MainWindow window = new MainWindow(sdlWindow, renderer);

    if (!renderer.start())
        return -1;

    window.show();

    return 0;
}
