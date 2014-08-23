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
    private static GLContext context;

    private static Cursor? default_cursor;
    private static Cursor? hover_cursor;

    public static bool init()
    {
        if (initialized)
            return true;

        if (SDL.init(SDL.InitFlag.EVERYTHING) < 0)
        	return false;

        if (!Sound.init())
        {
            SDL.quit();
            return false;
        }

        if (SDLNet.init() < 0)
        {
            Sound.quit();
            SDL.quit();
            return false;
        }

        window = new Window("Riichi Mahjong", Window.POS_CENTERED, Window.POS_CENTERED, ORIGINAL_WINDOW_WIDTH, ORIGINAL_WINDOW_HEIGHT, WindowFlags.RESIZABLE | WindowFlags.OPENGL);

        if (window == null)
        {
            SDL.quit();
            Sound.quit();
            SDLNet.quit();
            return false;
        }

        if ((context = SDL.GL.create_context(window)) == null)
        {
            window.destroy();
            SDL.quit();
            Sound.quit();
            SDLNet.quit();
            return false;
        }

        SDL.GL.set_attribute(GLattr.CONTEXT_MAJOR_VERSION, 3);
        SDL.GL.set_attribute(GLattr.CONTEXT_MINOR_VERSION, 1);
        SDL.GL.set_swapinterval(1);

        GLEW.init();

        glEnable(GL_CULL_FACE);
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);

        glEnable(GL_LINE_SMOOTH);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glShadeModel(GL_SMOOTH);

        glEnable(GL_LIGHT0);
        glEnable(GL_NORMALIZE);
        glEnable(GL_COLOR_MATERIAL);
        glEnable(GL_LIGHTING);

        glLightfv(GL_LIGHT0, GL_AMBIENT,  light_ambient);
        glLightfv(GL_LIGHT0, GL_DIFFUSE,  light_diffuse);
        glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
        glLightfv(GL_LIGHT0, GL_POSITION, light_position);

        glMaterialfv(GL_FRONT, GL_AMBIENT,   mat_ambient);
        glMaterialfv(GL_FRONT, GL_DIFFUSE,   mat_diffuse);
        glMaterialfv(GL_FRONT, GL_SPECULAR,  mat_specular);
        glMaterialfv(GL_FRONT, GL_SHININESS, high_shininess);

        window.set_icon(SDLImage.load("textures/Icon.png"));
        window.set_size(ORIGINAL_WINDOW_WIDTH, ORIGINAL_WINDOW_HEIGHT);
        window.show();

        TextInput.start();
        hover_cursor = new Cursor.from_system(SystemCursor.HAND);
        default_cursor = new Cursor.from_system(SystemCursor.ARROW);
        rand = new Rand();

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
            SDL.GL.delete_context(context);
            Sound.quit();
            SDLNet.quit();
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

    // Lighting
    private const GLfloat light_ambient[]  = { (GLfloat)0.0f, (GLfloat)0.0f, (GLfloat)0.0f, (GLfloat)1.0f };
    private const GLfloat light_diffuse[]  = { (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f };
    private const GLfloat light_specular[] = { (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f };
    private const GLfloat light_position[] = { (GLfloat)2.0f, (GLfloat)5.0f, (GLfloat)5.0f, (GLfloat)0.0f };

    private const GLfloat mat_ambient[]    = { (GLfloat)0.7f, (GLfloat)0.7f, (GLfloat)0.7f, (GLfloat)1.0f };
    private const GLfloat mat_diffuse[]    = { (GLfloat)0.8f, (GLfloat)0.8f, (GLfloat)0.8f, (GLfloat)1.0f };
    private const GLfloat mat_specular[]   = { (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f };
    private const GLfloat high_shininess[] = { (GLfloat)100.0f };
}
