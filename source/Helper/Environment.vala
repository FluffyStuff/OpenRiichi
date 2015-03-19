using SDL;
using GL;

#if LINUX
public class Environment
#else
public static class Environment
#endif
{
    public static Window window;
    private static bool initialized = false;

    public static bool init()
    {
        if (initialized)
            return true;

        if (SDL.init(SDL.InitFlag.EVERYTHING) < 0)
        	return false;
        SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLEBUFFERS, 1);
        SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLESAMPLES, 4);

        window = new Window("Demoscene", Window.POS_CENTERED, Window.POS_CENTERED, ORIGINAL_WINDOW_WIDTH, ORIGINAL_WINDOW_HEIGHT, WindowFlags.RESIZABLE | WindowFlags.OPENGL);

        if (window == null)
        {
            SDL.quit();
            return false;
        }

        initialized = true;
        return true;
    }

    public static void exit()
    {
        if (initialized)
        {
            window.destroy();
            TextInput.stop();
            SDL.quit();
        }
    }

    public const int ORIGINAL_WINDOW_WIDTH = 1280;
    public const int ORIGINAL_WINDOW_HEIGHT = 720;
}
