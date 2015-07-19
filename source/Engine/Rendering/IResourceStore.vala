using Gee;

public abstract class IResourceStore : Object
{
    public RenderObject3D? load_object_3D(string name)
    {
        RenderModel? model = load_model(name, false);
        RenderTexture? texture = load_texture(name);
        RenderObject3D obj = new RenderObject3D(model, texture);
        return obj;
    }

    public RenderModel? load_model(string name, bool center)
    {
        return load_model_dir(MODEL_DIR, name, center);

    }

    public RenderTexture? load_texture(string name)
    {
        return load_texture_dir(TEXTURE_DIR, name);
    }

    public abstract RenderModel? load_model_dir(string dir, string name, bool center);
    public abstract RenderTexture? load_texture_dir(string dir, string name);

    private const string DATA_DIR = "./Data/";
    protected const string MODEL_DIR = DATA_DIR + "Models/";
    protected const string TEXTURE_DIR = DATA_DIR + "Textures/";
}

public class ResourceModel
{
    public ResourceModel(ModelPoint[] points)
    {
        this.points = points;
    }

    public ModelPoint[] points { get; private set; }
}

public class ResourceTexture
{
    public ResourceTexture(char *data, int width, int height)
    {
        this.data = data;
        this.width = width;
        this.height = height;
    }

    ~ResourceTexture()
    {
        delete data;
    }

    public char *data { get; private set; }
    public int width { get; private set; }
    public int height { get; private set; }
}

public class RenderModel : Object
{
    public RenderModel(uint handle, Vec3 center, Vec3 size)
    {
        this.handle = handle;
        //this.center = center;
        this.size = size;
    }

    public uint handle { get; private set; }
    //public Vec3 center { get; private set; }
    public Vec3 size { get; private set; }
}

public class RenderTexture : Object
{
    public RenderTexture(uint handle, Vec2 size)
    {
        this.handle = handle;
        this.size = size;
    }

    public uint handle { get; private set; }
    public Vec2 size { get; private set; }
}
