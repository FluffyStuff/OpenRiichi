using SDL;
using GL;

public class MainWindow : RenderWindow
{
    //private uint color_id;

    //private bool restart = false;
    //private int focal_length = 2;
    //private ServerController server;

    private MainMenu menu;

    public MainWindow(IWindowTarget window, IRenderTarget renderer)
    {
        base(window, renderer);

        menu = new MainMenu();
        menu.menu_action.connect(menu_action);

        main_view.add_child(menu);
    }

    ~MainWindow()
    {
        menu.menu_action.disconnect(menu_action);
        //net.game_start.disconnect(net_game_start);
    }

    private void menu_action(MainMenu m)
    {
        switch (m.action)
        {
        case MainMenu.MenuAction.SINGLE_PLAYER:
            /*server = new ServerController();
            ClientConnection connection = new ClientMemoryConnection(server);
            clientGame = new ClientGame(connection);
            view = new Mahjong(window);*/
            break;
        case MainMenu.MenuAction.HOST_MULTI_PLAYER:
            /*server = new ServerController();
            ClientConnection connection = new ClientMemoryConnection(server);
            clientGame = new ClientGame(connection);
            server.listen(1337); // TOOD: Port from where?*/
            break;
        case MainMenu.MenuAction.JOIN_MULTI_PLAYER:
            /*ClientConnection connection = ClientNetworkConnection.connect("127.0.0.1", 1337);
            if (!connection == null) return;
            clientGame = new ClientGame(connection);*/
            break;
        case MainMenu.MenuAction.EXIT:
            finish();
            break;
        }
    }

    /*private void net_game_start(GameStartMessage message)
    {
        //net_start = message;
    }*/

    protected override void do_process(double dt)
    {
        Event e;

        //while (!exit)
        {
            /*if (net_start != null)// TODO: code plz, stahp, be a little more graceful...
            {
                view = new Mahjong.seed(window, net_start.tile_seed, net_start.wall_split, net_start.seat, net.players);
                net_start = null;
            }*/

            while (Event.poll(out e) != 0)
            {
                if (e.type == EventType.QUIT)
                    finish();
                else if (e.type == EventType.KEYDOWN)
                    key(e.key.keysym.sym);
                else if (e.type == EventType.MOUSEMOTION)
                {
                    int x = 0, y = 0;
                    Cursor.get_state(ref x, ref y);
                    main_view.mouse_move(x, y);
                    //back_color = { (float)x / width, 0, (float)y / height, 0 };
                    //window.get_size(out width, out height);
                    //view.mouse_move(x, height - y, color_id);
                }
                else if (e.type == EventType.MOUSEBUTTONDOWN || e.type == EventType.MOUSEBUTTONUP)
                {
                    int x = 0, y = 0;
                    Cursor.get_state(ref x, ref y);
                    //window.get_size(out width, out height);
                    //view.mouse_click(x, height - y, e.button.button, e.type == EventType.MOUSEBUTTONUP, color_id);
                }
                else if (e.type == EventType.MOUSEWHEEL)
                    ;//view.mouse_wheel(e.wheel.y);
            }

            main_view.process(dt);

            //((OpenGLRenderer)renderer).render(new RenderState(800, 600));
        }
    }

    private void key(char key)
    {
        switch (key)
        {
            case 27 :
            case 'q':
                finish();
                break;
            case 'f':
                fullscreen = !fullscreen;
                break;
            /*case 'r':
                restart = true;
                exit = true;
                break;*/
            default:
                main_view.key_press(key);
                break;
        }
    }

    /*private uint get_color_id()
    {
        uchar color[3];
        int x = 0, y = 0, width, height;
        Cursor.get_state(ref x, ref y);
        window.get_size(out width, out height);
        glReadPixels((GLint)x, (GLint)(height - y), 1, 1, GL_RGB, GL_UNSIGNED_BYTE, (GLvoid[])color);
        return ((uint)color[0] << 16) + ((uint)color[1] << 8) + (uint)color[2];
    }*/
}

public abstract class RenderWindow
{
    private IWindowTarget window;
    public IRenderTarget renderer;
    private bool running;

    public RenderWindow(IWindowTarget window, IRenderTarget renderer)
    {
        this.window = window;
        this.renderer = renderer;
        main_view = new MainView(this);
    }

    public void show()
    {
        running = true;

        load_resources(renderer.resource_store);

        while (running)
        {
            process(get_delta());
            renderer.set_state(render());
            window.pump_events();
            GLib.Thread.usleep(1000);
        }
    }

    public void finish()
    {
        running = false;
    }

    private RenderState render()
    {
        RenderState state = new RenderState(window.width, window.height);
        state.back_color = back_color;
        main_view.render(state, renderer.resource_store);
        return state;
    }

    // Returns the delta time in seconds
    private double get_delta()
    {
        return 0.01;
    }

    private void load_resources(IResourceStore store)
    {
        main_view.load_resources(store);
    }

    private void process(double dt)
    {
        do_process(dt);
        main_view.process(dt);
    }

    protected abstract void do_process(double dt);

    public View main_view { get; private set; }
    public bool fullscreen { get { return window.fullscreen; } set { window.fullscreen = value; } }
    public Color back_color { get; set; }
    public int width { get { return window.width; } }
    public int height { get { return window.height; } }
}

public interface IWindowTarget : Object
{
    public abstract bool fullscreen { get; set; }
    public abstract int width { get; }
    public abstract int height { get; }
    public abstract void swap();
    public abstract void pump_events();
}

public class SDLWindowTarget : Object, IWindowTarget
{
    private bool is_fullscreen = false;
    private unowned Window window;

    public SDLWindowTarget(Window window)
    {
        this.window = window;
    }

    public void pump_events()
    {
        Event.pump();
    }

    public bool fullscreen
    {
        get { return is_fullscreen; }
        set { window.set_fullscreen((is_fullscreen = value) ? WindowFlags.FULLSCREEN_DESKTOP : 0); }
    }

    public int width
    {
        get
        {
            int width, height;
            window.get_size(out width, out height);
            return width;
        }
    }

    public int height
    {
        get
        {
            int width, height;
            window.get_size(out width, out height);
            return height;
        }
    }

    public void swap()
    {
        SDL.GL.swap_window(window);
    }

    public Window sdl_window { get { return window; } }
}

public class RenderState
{
    Gee.ArrayList<Render3DObject> objs = new Gee.ArrayList<Render3DObject>();

    public RenderState(int width, int height)
    {
        screen_width = width;
        screen_height = height;
    }

    public void add_3D_object(Render3DObject object)
    {
        objs.add(object);
    }

    public int screen_width { get; private set; }
    public int screen_height { get; private set; }
    public Gee.ArrayList<Render3DObject> objects { get { return objs; } }
    public Color back_color { get; set; }
    public Vec3 camera_position { get; set; }
    public Vec3 camera_rotation { get; set; }
}

public class MainView : View
{
    public MainView(RenderWindow window)
    {
        parent_window = window;
    }

    public override void do_render(RenderState state, IResourceStore store){}
    protected override void do_mouse_move(int x, int y){}
    protected override void do_load_resources(IResourceStore store){}
    protected override void do_process(double dt){}
    protected override void do_key_press(char key){}
}

public abstract class View
{
    private Gee.ArrayList<View> child_views = new Gee.ArrayList<View>();
    protected RenderWindow parent_window;
    private View parent;

    public void add_child(View child)
    {
        child_views.add(child);
        child.set_parent(this);
    }

    private void set_parent(View parent)
    {
        this.parent = parent;

        if (parent == null)
            parent_window = null;
        else
            parent_window = parent.parent_window;
    }

    public void process(double dt)
    {
        do_process(dt);

        foreach (View view in child_views)
            view.process(dt);
    }

    public void render(RenderState state, IResourceStore store)
    {
        do_render(state, store);

        foreach (View view in child_views)
            view.render(state, store);
    }

    public void mouse_move(int x, int y)
    {
        // TODO: Check handled
        do_mouse_move(x, y);

        foreach (View view in child_views)
            view.mouse_move(x, y);
    }

    public void key_press(char key)
    {
        // TODO: Check handled
        do_key_press(key);

        foreach (View view in child_views)
            view.key_press(key);
    }

    public void load_resources(IResourceStore store)
    {
        do_load_resources(store);

        foreach (View view in child_views)
            view.load_resources(store);
    }

    protected abstract void do_load_resources(IResourceStore store);
    protected abstract void do_render(RenderState state, IResourceStore store);
    protected abstract void do_process(double dt);
    protected abstract void do_mouse_move(int x, int y);
    protected abstract void do_key_press(char key);

    /*public abstract void render_selection();
    public abstract void render_interface();
    public abstract void render_interface_selection();*/

    //public abstract void mouse_move(int x, int y, uint color_id);
    //public abstract void mouse_click(int x, int y, int button, bool state, uint color_id);
    //public abstract void mouse_wheel(int amount);
}

public struct Color
{
    public float r;
    public float g;
    public float b;
    public float a;
}
