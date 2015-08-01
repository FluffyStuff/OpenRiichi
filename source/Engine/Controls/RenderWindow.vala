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
        store = renderer.resource_store;
        main_view = new MainView(this);
    }

    int frms = 100;
    int counter = 0;
    double lst_time = 0;
    GLib.Timer timr = new GLib.Timer();
    public void show()
    {
        running = true;
        timer = new GLib.Timer();

        while (running)
        {
            process(get_delta());
            renderer.set_state(render());
            window.pump_events();
            //GLib.Thread.usleep(1000);

            if ((counter++ % frms) == 0)
            {
                double time = timr.elapsed();
                double diff = (time - lst_time) / frms;

                //print("(F) Average frame time over %d frames: %fms (%ffps)\n", frms, diff * 1000, 1 / diff);

                lst_time = time;
            }
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

    private void process(DeltaArgs delta)
    {
        process_events();
        do_process(delta);
        main_view.process(delta);
    }

    // TODO: Make this non-SDL specific
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
            }
            else if (e.type == EventType.MOUSEBUTTONDOWN || e.type == EventType.MOUSEBUTTONUP)
            {
                MouseButtonEvent ev = e.button;

                MouseEventArgs.Button button = 0;
                bool unknown = false;

                switch (ev.button)
                {
                case 1:
                    button = MouseEventArgs.Button.LEFT;
                    break;
                case 2:
                    button = MouseEventArgs.Button.CENTER;
                    break;
                case 3:
                    button = MouseEventArgs.Button.RIGHT;
                    break;
                default:
                    unknown = true;
                    break;
                }

                if (unknown)
                    break;

                int ax = 0, ay = 0;
                Cursor.get_state(ref ax, ref ay);
                MouseEventArgs mouse = new MouseEventArgs(button, ev.state == 1, ax, height - ay);
                main_view.mouse_event(mouse);
            }
            else if (e.type == EventType.MOUSEWHEEL)
                ;
        }

        mouse_move_event();
    }

    private void mouse_move_event()
    {
        int rx = 0, ry = 0, ax = 0, ay = 0;
        Cursor.get_relative_state(ref rx, ref ry);
        Cursor.get_state(ref ax, ref ay);

        MouseMoveArgs mouse = new MouseMoveArgs(ax, height-ay, rx, -ry);
        main_view.mouse_move(mouse);

        set_cursor_type(mouse.cursor_type);
    }

    public void set_cursor_type(CursorType type)
    {
        window.set_cursor_type(type);
    }

    public void set_cursor_hidden(bool hidden)
    {
        window.set_cursor_hidden(hidden);
    }

    public void set_cursor_position(int x, int y)
    {
        window.set_cursor_position(x, y);
    }

    protected virtual void do_process(DeltaArgs delta) {}

    protected virtual bool key_press(KeyArgs key)
    {
        return false;
    }

    public IRenderTarget renderer { get; private set; }
    public IResourceStore store { get; private set; }
    public View main_view { get; private set; }
    public bool fullscreen { get { return window.fullscreen; } set { window.fullscreen = value; } }
    public Color back_color { get; set; }
    public int width { get { return window.width; } }
    public int height { get { return window.height; } }
}
