using Gee;

public interface IRenderTarget : Object
{
    public abstract void set_state(RenderState state);
    public abstract bool start();
    public abstract void stop();

    public abstract uint load_3D_object(Resource3DObject object);
    public abstract uint load_texture(ResourceTexture texture);
    public abstract IResourceStore resource_store { get; }
}

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
    private uint handle_texture_ID = 1;
    private uint handle_3D_object_ID = 1;
    private ArrayList<Resource3DObject> to_load_3D_objects = new ArrayList<Resource3DObject>();
    private ArrayList<ResourceTexture> to_load_textures = new ArrayList<ResourceTexture>();
    private ArrayList<IObject3DResourceHandle> handles_3D_objects = new ArrayList<IObject3DResourceHandle>();
    private ArrayList<ITextureResourceHandle> handles_textures = new ArrayList<ITextureResourceHandle>();

    protected IWindowTarget window;
    protected OpenGLResourceStore store;

    public RenderTarget(IWindowTarget window)
    {
        this.window = window;
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

    public uint load_3D_object(Resource3DObject obj)
    {
        uint ret = 0;
        resource_mutex.lock();
        to_load_3D_objects.add(obj);
        ret = handle_3D_object_ID++;
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

    protected IObject3DResourceHandle? get_3D_object(uint handle)
    {
        resource_mutex.lock();
        IObject3DResourceHandle ret = (handle > handles_3D_objects.size) ? null : handles_3D_objects[(int)handle - 1];
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

    [Profile]
    private void render_thread()
    {
        init_status = init();
        init_mutex.lock();
        initialized = true;
        init_mutex.unlock();

        if (!init_status)
            return;

        running = true;

        while (running)
        {
            state_mutex.lock();
            current_state = buffer_state;
            state_mutex.unlock();

            load_resources();

            if (current_state == null)
            {
                Thread.usleep(1000);
                continue;
            }

            render(current_state);

            GLib.Thread.usleep(5000);
        }
    }

    private void load_resources()
    {
        resource_mutex.lock();
        while (to_load_3D_objects.size != 0)
        {
            Resource3DObject obj = to_load_3D_objects.remove_at(0);
            resource_mutex.unlock();
            handles_3D_objects.add(do_load_3D_object(obj));
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

    public abstract void render(RenderState state);

    protected abstract bool init();
    protected abstract IObject3DResourceHandle do_load_3D_object(Resource3DObject obj);
    protected abstract ITextureResourceHandle do_load_texture(ResourceTexture texture);

    public IResourceStore resource_store { get { return store; } }
}
