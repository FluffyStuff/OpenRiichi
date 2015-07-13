using Gee;

public interface IResourceStore : Object
{
    public abstract RenderObject3D? load_object_3D(string name);
    public abstract RenderModel? load_model(string name, bool center);
    public abstract RenderTexture? load_texture(string name);

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
    public RenderTexture(uint handle, int width, int height)
    {
        this.handle = handle;
        this.width = width;
        this.height = height;
    }

    public uint handle { get; private set; }
    public int width { get; private set; }
    public int height { get; private set; }
}
