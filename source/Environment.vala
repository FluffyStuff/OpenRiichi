using SDL;
using GL;

public class Environment : Object
{
    private static bool initialized = false;

    ~Environment()
    {
        exit();
    }

    public bool init()
    {
        if (initialized)
            return true;

        if (SDL.init(SDL.InitFlag.EVERYTHING) < 0)
        {
            print("Environment: Could not init SDL!\n");
            return false;
        }

        bugfix();

        initialized = true;
        return true;
    }

    public void set_multisampling(int multisampling)
    {
        int s = (int)Math.pow(2, multisampling);
        SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLEBUFFERS, 1);
        SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLESAMPLES, s);
    }

    public Window? createWindow(string name, int width, int height, bool fullscreen)
    {
        if (!initialized)
            return null;
        var flags = WindowFlags.RESIZABLE | WindowFlags.OPENGL;
        if (fullscreen)
            flags |= WindowFlags.FULLSCREEN_DESKTOP;
        return new Window(name, Window.POS_CENTERED, Window.POS_CENTERED, width, height, flags);
    }

    public GLContext? create_context(Window window)
    {
        GLContext? context = SDL.GL.create_context(window);
        if (context == null)
            return null;

        SDL.GL.set_attribute(GLattr.CONTEXT_MAJOR_VERSION, 2);
        SDL.GL.set_attribute(GLattr.CONTEXT_MINOR_VERSION, 1);
        SDL.GL.set_attribute(GLattr.CONTEXT_PROFILE_MASK, 1); // Core Profile
        GLEW.experimental = true;

        if (GLEW.init())
        {
            print("Environment: Could not init GLEW!\n");
            return null;
        }

        return context;
    }

    public void exit()
    {
        if (initialized)
        {
            SDL.quit();
            initialized = false;
        }
    }

    // TODO: Fix class reflection bug...
    private void bugfix()
    {
        typeof(Serializable).class_ref();
        typeof(SerializableList).class_ref();
        typeof(SerializableListItem).class_ref();
        typeof(ObjInt).class_ref();
        typeof(GamePlayer).class_ref();
        typeof(ServerMessage).class_ref();
        typeof(ServerMessageRoundStart).class_ref();
        typeof(ServerMessageAcceptJoin).class_ref();
        typeof(ServerMessageMenuSlotAssign).class_ref();
        typeof(ServerMessageMenuSlotClear).class_ref();
        typeof(ServerMessageDraw).class_ref();
        typeof(NullBot).class_ref();
        typeof(SimpleBot).class_ref();
    }
}
