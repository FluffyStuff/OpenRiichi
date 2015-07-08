private static Environment environment;

class MessageTest : ServerMessage
{
    private int herp;

    public MessageTest(int inty, string stringy, bool booly)
    {
        this.inty = inty;
        this.stringy = stringy;
        this.booly = booly;
    }

    public int inty { get; protected set; }
    public string stringy { get; protected set; }
    public bool booly { get; protected set; }
}

public static int main(string[] args)
{
    /*MessageTest derp = new MessageTest(123, "456", true);

    uint8[] data = derp.serialize();

    MessageTest derp2 = (MessageTest)SerializableMessage.deserialize(data);
    print("Result: %d\n", derp2.inty);
    print("Result: %s\n", derp2.stringy);
    print("Result: %s\n", derp2.booly.to_string());

    return 0;*/

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
