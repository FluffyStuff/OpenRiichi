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
    private uint handle_texture_ID = 1;
    private uint handle_3D_object_ID = 1;
    private ArrayList<Resource3DObject> to_load_3D_objects = new ArrayList<Resource3DObject>();
    private ArrayList<ResourceTexture> to_load_textures = new ArrayList<ResourceTexture>();
    private ArrayList<IObject3DResourceHandle> handles_3D_objects = new ArrayList<IObject3DResourceHandle>();
    private ArrayList<ITextureResourceHandle> handles_textures = new ArrayList<ITextureResourceHandle>();

    protected IWindowTarget window;
    protected IResourceStore store;

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

    public Mat4 get_projection_matrix(float view_angle, float aspect_ratio, float z_near, float z_far)
    {
        float vtan = (float)Math.tan(view_angle / 2);
        Vec4 v1 = {1 / vtan,                   0,                                     0,  0};
        Vec4 v2 = {       0, aspect_ratio / vtan,                                     0,  0};
        Vec4 v3 = {       0,                   0,   (z_far + z_near) / (z_far - z_near), -1};
        Vec4 v4 = {       0,                   0, 2 * z_far * z_near / (z_far - z_near),  0};

        return new Mat4.with_vecs(v1, v2, v3, v4);
    }

    /*public Mat4 get_view_matrix(Camera camera)
    {
        Mat4 x = Calculations.rotation_matrix({1, 0, 0}, pi * camera.rotation.x);
        Mat4 y = Calculations.rotation_matrix({0, 1, 0}, pi * camera.rotation.y);
        Mat4 z = Calculations.rotation_matrix({0, 0, 1}, pi * camera.rotation.z);

        Mat4 pos = Calculations.translate(camera.position);
        Mat4 m = z.mul_mat(y).mul_mat(x);

        return m.mul_mat(pos);
    }*/

    public abstract void render(RenderState state);

    protected abstract bool init();
    protected abstract IObject3DResourceHandle do_load_3D_object(Resource3DObject obj);
    protected abstract ITextureResourceHandle do_load_texture(ResourceTexture texture);

    public IResourceStore resource_store { get { return store; } }
}
