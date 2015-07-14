using Gee;

public abstract class RenderTarget : Object, IRenderTarget
{
    private RenderState? current_state = null;
    private RenderState? buffer_state = null;
    private bool running = false;
    private Mutex state_mutex = new Mutex();

    private bool initialized = false;
    private bool init_status;
    private Mutex init_mutex = new Mutex();

    private Mutex resource_mutex = new Mutex();
    private uint handle_model_ID = 1;
    private uint handle_texture_ID = 1;
    private ArrayList<ResourceModel> to_load_models = new ArrayList<ResourceModel>();
    private ArrayList<ResourceTexture> to_load_textures = new ArrayList<ResourceTexture>();
    private ArrayList<IModelResourceHandle> handles_models = new ArrayList<IModelResourceHandle>();
    private ArrayList<ITextureResourceHandle> handles_textures = new ArrayList<ITextureResourceHandle>();

    private bool saved_v_sync = false;

    protected IWindowTarget window;
    protected IResourceStore store;

    public RenderTarget(IWindowTarget window)
    {
        this.window = window;
        v_sync = saved_v_sync;
    }

    public void set_state(RenderState state)
    {
        state_mutex.lock();
        buffer_state = state;
        state_mutex.unlock();
    }

    public bool start()
    {
        Threading.start0(render_thread);

        while (true)
        {
            init_mutex.lock();
            if (initialized)
            {
                init_mutex.unlock();
                break;
            }
            init_mutex.unlock();

            window.pump_events();
            Thread.usleep(10000);
        }

        return init_status;
    }

    public void stop()
    {
        running = false;
    }

    public uint load_model(ResourceModel obj)
    {
        uint ret = 0;
        resource_mutex.lock();
        to_load_models.add(obj);
        ret = handle_model_ID++;
        resource_mutex.unlock();

        return ret;
    }

    public uint load_texture(ResourceTexture texture)
    {
        uint ret = 0;
        resource_mutex.lock();
        to_load_textures.add(texture);
        ret = handle_texture_ID++;
        resource_mutex.unlock();

        return ret;
    }

    protected IModelResourceHandle? get_model(uint handle)
    {
        resource_mutex.lock();
        IModelResourceHandle ret = (handle > handles_models.size) ? null : handles_models[(int)handle - 1];
        resource_mutex.unlock();

        return ret;
    }

    protected ITextureResourceHandle? get_texture(uint handle)
    {
        resource_mutex.lock();
        ITextureResourceHandle? ret = (handle > handles_textures.size) ? null : handles_textures[(int)handle - 1];
        resource_mutex.unlock();

        return ret;
    }

    int counter = 0;
    double last_time = 0;
    int frms = 100;
    Timer timer = new Timer();
    private void render_thread()
    {
        init_status = init(window.width, window.height);
        init_mutex.lock();
        initialized = true;
        init_mutex.unlock();

        if (!init_status)
            return;

        running = true;

        while (running)
        {
            state_mutex.lock();
            if (current_state == buffer_state)
            {
                state_mutex.unlock();
                Thread.usleep(1000);
                continue;
            }

            current_state = buffer_state;
            state_mutex.unlock();

            load_resources();

            check_settings();

            render(current_state);

            if ((counter++ % frms) == 0)
            {
                double time = timer.elapsed();
                double diff = (time - last_time) / frms;

                print("(R) Average frame time over %d frames: %fms (%ffps)\n", frms, diff * 1000, 1 / diff);

                last_time = time;
            }

            // TODO: Fix fullscreen v-sync issues
            //Thread.usleep(5000);
        }
    }

    private void load_resources()
    {
        resource_mutex.lock();
        while (to_load_models.size != 0)
        {
            ResourceModel model = to_load_models.remove_at(0);
            resource_mutex.unlock();
            handles_models.add(do_load_model(model));
            resource_mutex.lock();
        }

        while (to_load_textures.size != 0)
        {
            ResourceTexture texture = to_load_textures.remove_at(0);
            resource_mutex.unlock();
            handles_textures.add(do_load_texture(texture));
            resource_mutex.lock();
        }
        resource_mutex.unlock();
    }

    private void check_settings()
    {
        bool new_v_sync = v_sync;

        if (new_v_sync != saved_v_sync)
        {
            saved_v_sync = new_v_sync;
            change_v_sync(saved_v_sync);
        }
    }

    public Mat4 get_projection_matrix(float view_angle, float aspect_ratio)
    {
        view_angle  *= 0.6f;
        float z_near = 0.5f * Math.fmaxf(aspect_ratio, 1);
        float z_far  =   30 * Math.fmaxf(aspect_ratio, 1);

        float vtan = (float)Math.tan(view_angle);
        Vec4 v1 = {1 / vtan, 0,                   0,                                    0};
        Vec4 v2 = {0,        aspect_ratio / vtan, 0,                                    0};
        Vec4 v3 = {0,        0,                   -(z_far + z_near) / (z_far - z_near), -2 * z_far * z_near / (z_far - z_near)};
        Vec4 v4 = {0,        0,                   -1,                                   0};

        return new Mat4.with_vecs(v1, v2, v3, v4);
    }

    public abstract void render(RenderState state);

    protected abstract bool init(int width, int height);
    protected abstract IModelResourceHandle do_load_model(ResourceModel model);
    protected abstract ITextureResourceHandle do_load_texture(ResourceTexture texture);
    protected abstract void change_v_sync(bool v_sync);

    public IResourceStore resource_store { get { return store; } }
    public bool v_sync { get; set; }
}
