using SDL;

public abstract class RenderWindow
{
    private IWindowTarget window;
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
        process_events();
        do_process(dt);
        main_view.process(dt);
    }

    private void process_events()
    {
        Event e;

        while (Event.poll(out e) != 0)
        {
            if (e.type == EventType.QUIT)
                finish();
            else if (e.type == EventType.KEYDOWN)
            {
                char key = e.key.keysym.sym;
                if (!key_press(key))
                    main_view.key_press(key);
            }
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
    }

    public void set_cursor_hidden(bool hidden)
    {
        window.set_cursor_hidden(hidden);
    }

    public void set_cursor_position(int x, int y)
    {
        window.set_cursor_position(x, y);
    }

    protected virtual void do_process(double dt) {}

    protected virtual bool key_press(char key)
    {
        return false;
    }

    public IRenderTarget renderer { get; private set; }
    public View main_view { get; private set; }
    public bool fullscreen { get { return window.fullscreen; } set { window.fullscreen = value; } }
    public Color back_color { get; set; }
    public int width { get { return window.width; } }
    public int height { get { return window.height; } }
}
