using SDL;

public abstract class RenderWindow
{
    private IWindowTarget window;
    private bool running;
    private GLib.Timer timer;
    private float last_time = 0;

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
            process(get_delta(), renderer.resource_store);
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
        main_view.render(state);
        return state;
    }

    // Returns the delta time in seconds
    private DeltaArgs get_delta()
    {
        float time = (float)timer.elapsed();
        float dt = time - last_time;
        last_time = time;

        return new DeltaArgs(time, dt);
    }

    private void load_resources(IResourceStore store)
    {
        main_view.load_resources(store);
    }

    private void process(DeltaArgs delta, IResourceStore store)
    {
        process_events();
        do_process(delta, store);
        main_view.process(delta, store);
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
                char k = e.key.keysym.sym;
                KeyArgs key = new KeyArgs(k);

                if (!key_press(key))
                    main_view.key_press(key);
            }
            else if (e.type == EventType.MOUSEMOTION)
            {
                int rx = 0, ry = 0, ax = 0, ay = 0;
                Cursor.get_relative_state(ref rx, ref ry);
                Cursor.get_state(ref ax, ref ay);

                MouseArgs mouse = new MouseArgs(ax, ay, rx, ry);
                main_view.mouse_move(mouse);
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

    protected virtual void do_process(DeltaArgs delta, IResourceStore store) {}

    protected virtual bool key_press(KeyArgs key)
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
