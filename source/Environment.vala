using SDL;
using GL;

public class Environment : Object
{
    private bool initialized = false;

    public bool init(int multisampling)
    {
        if (initialized)
            return true;

        if (SDL.init(SDL.InitFlag.EVERYTHING) < 0)
        	return false;

        if (SDLMixer.open(44100, 0x8010, 2, 1024) > 0)
        {
            print("Environment: Could not initialize SDLMixer!\n");
            return false;
        }

        if (multisampling > 0)
        {
            int s = (int)Math.pow(2, multisampling);
            SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLEBUFFERS, 1);
            SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLESAMPLES, s);
        }

        bugfix();

        initialized = true;
        return true;
    }

    public Window? createWindow(string name, int width, int height)
    {
        if (!initialized)
            return null;
        return new Window(name, Window.POS_CENTERED, Window.POS_CENTERED, width, height, WindowFlags.RESIZABLE | WindowFlags.OPENGL);
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
