using Gee;

public interface IResourceStore : Object
{
    public abstract Render3DObject? load_3D_object(string name);
    public abstract RenderModel? load_model(string name);
    public abstract RenderTexture? load_texture(string name);

    private const string DATA_DIR = "./Data/";
    protected const string MODEL_DIR = DATA_DIR + "Models/";
    protected const string TEXTURE_DIR = DATA_DIR + "Textures/";
}

public class OpenGLResourceStore : IResourceStore, Object
{
    private unowned OpenGLRenderer renderer;
    private ArrayList<ResourceCacheObject> cache = new ArrayList<ResourceCacheObject>();

    public OpenGLResourceStore(OpenGLRenderer renderer)
    {
        this.renderer = renderer;
    }

    public Render3DObject? load_3D_object(string name)
    {
        RenderModel? model = load_model(name);
        RenderTexture? texture = load_texture(name);
        Render3DObject obj = new Render3DObject(model, texture);
        return obj;
    }

    public RenderModel? load_model(string name)
    {
        ResourceCacheObject? cache = get_cache_object(name, CacheObjectType.MODEL);
        if (cache != null)
            return (RenderModel)cache.obj;

        string[] lines = FileLoader.load(MODEL_DIR + name + ".obj");
        ModelData data = ObjParser.parse(lines);

        ResourceModel mod = new ResourceModel(data.points);
        uint handle = renderer.load_model(mod);

        RenderModel model = new RenderModel(handle, data.center, data.size);
        cache_object(name, CacheObjectType.MODEL, model);

        return model;
    }

    public RenderTexture? load_texture(string name)
    {
        ResourceCacheObject? cache = get_cache_object(name, CacheObjectType.TEXTURE);
        if (cache != null)
            return (RenderTexture)cache.obj;

        SoilImage img = SoilWrap.load_image(TEXTURE_DIR + name + ".png");

        ResourceTexture tex = new ResourceTexture(img.data, img.width, img.height);
        uint handle = renderer.load_texture(tex);

        RenderTexture texture = new RenderTexture(handle, img.width, img.height);
        cache_object(name, CacheObjectType.TEXTURE, texture);

        return texture;
    }

    private void cache_object(string name, CacheObjectType type, Object obj)
    {
        cache.add(new ResourceCacheObject(name, type, obj));
    }

    private ResourceCacheObject? get_cache_object(string name, CacheObjectType type)
    {
        foreach (ResourceCacheObject obj in cache)
            if (obj.obj_type == type && obj.name == name)
                return obj;
        return null;
    }

    private enum CacheObjectType
    {
        MODEL,
        TEXTURE
    }

    private class ResourceCacheObject
    {
        public ResourceCacheObject(string name, CacheObjectType type, Object obj)
        {
            this.name = name;
            this.obj_type = type;
            this.obj = obj;
        }

        public string name { get; private set; }
        public CacheObjectType obj_type { get; private set; }
        public Object obj { get; private set; }
    }
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
        this.center = center;
        this.size = size;
    }

    public uint handle { get; private set; }
    public Vec3 center { get; private set; }
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
