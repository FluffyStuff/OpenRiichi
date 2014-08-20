using SDL;
using GL;

#if LINUX
public class Environment
#else
public static class Environment
#endif
{
    private static Rand rand;
    private static bool initialized = false;
    public static Window window;

    public static bool init()
    {
        if (initialized)
            return true;

        rand = new Rand();

        if (SDL.init(SDL.InitFlag.EVERYTHING) < 0)
        	return false;
        else
        {
            window = new Window("Riichi Mahjong", Window.POS_CENTERED, Window.POS_CENTERED, ORIGINAL_WINDOW_WIDTH, ORIGINAL_WINDOW_HEIGHT, WindowFlags.RESIZABLE | WindowFlags.OPENGL);
            SDL.GL.set_attribute(GLattr.CONTEXT_MAJOR_VERSION, 3);
            SDL.GL.set_attribute(GLattr.CONTEXT_MINOR_VERSION, 1);

            if (window == null)
            {
                SDL.quit();
            	return false;
            }
            else
            {
                SDL.GL.set_swapinterval(1);

                #if __APPLE__
                CGSetLocalEventsSuppressionInterval(0); // Herp derp, fix the choppy cursor bug
                #endif

                Surface icon = SDLImage.load("textures/Icon.png");
                window.set_icon(icon);

                if (!Sound.init())
                {
                    window.destroy();
                    SDL.quit();
                    return false;
                }

                TextInput.start();

                window.show();

                initialized = true;
                return true;
            }
        }
    }

    public static void exit()
    {
        if (initialized)
        {
            Sound.quit();
            window.destroy();
            TextInput.stop();
            SDL.quit();
        }
    }

    public static bool threading { get { return GLib.Thread.supported(); } }
    public static Rand random { get { return rand; } }
    public const int ORIGINAL_WINDOW_WIDTH = 1280;
    public const int ORIGINAL_WINDOW_HEIGHT = 720;
}
