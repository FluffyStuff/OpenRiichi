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

        if (multisampling > 0)
        {
            int s = (int)Math.pow(2, multisampling);
            SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLEBUFFERS, 1);
            SDL.GL.set_attribute(SDL.GLattr.MULTISAMPLESAMPLES, s);
        }

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
}
