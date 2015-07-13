using Gee;

public class OpenGLResourceStore : IResourceStore, Object
{
    private unowned OpenGLRenderer renderer;
    private ArrayList<ResourceCacheObject> cache = new ArrayList<ResourceCacheObject>();

    public OpenGLResourceStore(OpenGLRenderer renderer)
    {
        this.renderer = renderer;
    }

    public RenderObject3D? load_object_3D(string name)
    {
        RenderModel? model = load_model(name, false);
        RenderTexture? texture = load_texture(name);
        RenderObject3D obj = new RenderObject3D(model, texture);
        return obj;
    }

    public RenderModel? load_model(string name, bool centered)
    {
        ResourceCacheObject? cache = get_cache_object(name, CacheObjectType.MODEL);
        if (cache != null)
            return (RenderModel)cache.obj;

        string[] lines = FileLoader.load(MODEL_DIR + name + ".obj");
        ModelData data = ObjParser.parse(lines);

        if (centered)
            data.center_points();
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
