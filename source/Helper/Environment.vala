using SDL;
using GL;

#if LINUX
public class Environment
#else
public static class Environment
#endif
{
    public static Window window;
    private static Rand rand;
    private static bool initialized = false;

    private static Cursor? default_cursor;
    private static Cursor? hover_cursor;

    public static bool init()
    {
        if (initialized)
            return true;

        if (SDL.init(SDL.InitFlag.EVERYTHING) < 0)
        	return false;
        SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLEBUFFERS, 1);
        SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLESAMPLES, 16);

        if (!Sound.init())
        {
            SDL.quit();
            return false;
        }

        /*if (SDLNet.init() < 0)
        {
            Sound.quit();
            SDL.quit();
            return false;
        }*/

        window = new Window("Riichi Mahjong", Window.POS_CENTERED, Window.POS_CENTERED, ORIGINAL_WINDOW_WIDTH, ORIGINAL_WINDOW_HEIGHT, WindowFlags.RESIZABLE | WindowFlags.OPENGL);

        if (window == null)
        {
            SDL.quit();
            Sound.quit();
            //SDLNet.quit();
            return false;
        }

        /*window.set_icon(SDLImage.load("textures/Icon.png"));
        window.set_size(ORIGINAL_WINDOW_WIDTH, ORIGINAL_WINDOW_HEIGHT);
        window.show();

        TextInput.start();
        hover_cursor = new Cursor.from_system(SystemCursor.HAND);
        default_cursor = new Cursor.from_system(SystemCursor.ARROW);
        rand = new Rand();
        Networking.init();*/

        #if __APPLE__
        CGSetLocalEventsSuppressionInterval(0); // Herp derp, fix the choppy cursor bug
        #endif

        initialized = true;
        return true;
    }

    public static void exit()
    {
        if (initialized)
        {
            //SDL.GL.delete_context(context);
            Sound.quit();
            //SDLNet.quit();
            window.destroy();
            TextInput.stop();
            default_cursor = null;
            hover_cursor = null;
            SDL.quit();
            Texture.clear_cache();
        }
    }

    public static void set_cursor(CursorType type)
    {
        switch (type)
        {
        case CursorType.HOVER:
            Cursor.set(hover_cursor);
            break;
        case CursorType.DEFAULT:
            Cursor.set(default_cursor);
            break;
        }
    }

    public static Rand random { get { return rand; } }
    public const int ORIGINAL_WINDOW_WIDTH = 1280;
    public const int ORIGINAL_WINDOW_HEIGHT = 720;

    public enum CursorType
    {
        DEFAULT,
        HOVER
    }
}
