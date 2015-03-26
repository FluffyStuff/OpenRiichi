using SDL;
using GL;

public class MainWindow : RenderWindow
{
    private GameView gameView;

    public MainWindow(IWindowTarget window, IRenderTarget renderer)
    {
        base(window, renderer);

        gameView = new GameView();
        main_view.add_child(gameView);
    }

    protected override void do_process(double dt)
    {
        Event e;

        while (Event.poll(out e) != 0)
        {
            if (e.type == EventType.QUIT)
                finish();
            else if (e.type == EventType.KEYDOWN)
                key(e.key.keysym.sym);
            else if (e.type == EventType.MOUSEMOTION)
            {
                int x = 0, y = 0;
                Cursor.get_relative_state(ref x, ref y);
                main_view.mouse_move(x, y);
            }
            else if (e.type == EventType.MOUSEBUTTONDOWN || e.type == EventType.MOUSEBUTTONUP)
                ;
            else if (e.type == EventType.MOUSEWHEEL)
                ;
        }

        main_view.process(dt);
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
            default:
                main_view.key_press(key);
                break;
        }
    }
}

public abstract class RenderWindow
{
    private IWindowTarget window;
    public IRenderTarget renderer;
    private bool running;
    private GLib.Timer timer;
    private double last_time = 0;

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
        timer = new GLib.Timer();

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
        double time = timer.elapsed();
        double dt = time - last_time;
        last_time = time;

        return dt;
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

    public void set_cursor_hidden(bool hidden)
    {
        window.set_cursor_hidden(hidden);
    }

    public void set_cursor_position(int x, int y)
    {
        window.set_cursor_position(x, y);
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
    public abstract void set_cursor_hidden(bool hidden);
    public abstract void set_cursor_position(int x, int y);
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

    public void set_cursor_hidden(bool hidden)
    {
        //SDL.Cursor.show(hidden ? 0 : 1);
        SDL.Cursor.set_relative_mode(hidden);
    }

    public void set_cursor_position(int x, int y)
    {
        //window.set_cursor_position(x, y);
    }

    public Window sdl_window { get { return window; } }
}

public class RenderState
{
    Gee.ArrayList<Render3DObject> objs = new Gee.ArrayList<Render3DObject>();
    Gee.ArrayList<LightSource> _lights = new Gee.ArrayList<LightSource>();

    public RenderState(int width, int height)
    {
        screen_width = width;
        screen_height = height;
        focal_length = 1;
        perlin_strength = 0;
    }

    public void add_3D_object(Render3DObject object)
    {
        //TODO: create copy
        objs.add(object);
    }

    public void add_light_source(LightSource light)
    {
        _lights.add(light);
    }

    public bool blacking { get; set; }
    public bool vertical {get; set;}
    public float bloom { get; set; }
    public float perlin_strength { get; set; }
    public int screen_width { get; private set; }
    public int screen_height { get; private set; }
    public Gee.ArrayList<Render3DObject> objects { get { return objs; } }
    public Gee.ArrayList<LightSource> lights { get { return _lights; } }
    public Color back_color { get; set; }
    public Vec3 camera_position { get; set; }
    public Vec3 camera_rotation { get; set; }
    public float focal_length { get; set; }
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
}
