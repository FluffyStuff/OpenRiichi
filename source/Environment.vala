using SDL;
using GL;

public class Environment
{
    private bool initialized = false;

    public bool init()
    {
        if (initialized)
            return true;

        if (SDL.init(SDL.InitFlag.EVERYTHING) < 0)
        	return false;
        SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLEBUFFERS, 1);
        SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLESAMPLES, 16);

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
            //TextInput.stop();
            SDL.quit();
            initialized = false;
        }
    }
}
