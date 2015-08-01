using Gee;

public class OpenGLResourceStore : IResourceStore
{
    private unowned OpenGLRenderer renderer;
    private ArrayList<ResourceCacheObject> cache = new ArrayList<ResourceCacheObject>();

    public OpenGLResourceStore(OpenGLRenderer renderer)
    {
        this.renderer = renderer;
    }

    public override RenderModel? load_model_dir(string dir, string name, bool centered)
    {
        ResourceCacheObject? cache = get_cache_object(name, CacheObjectType.MODEL);
        if (cache != null)
            return (RenderModel)cache.obj;

        string str = dir + name + ".obj";
        string[] lines = FileLoader.load(str);
        if (lines == null)
            return null;

        ModelData data = ObjParser.parse(lines);

        if (centered)
            data.center_points();
        ResourceModel mod = new ResourceModel(data.points);
        uint handle = renderer.load_model(mod);

        RenderModel model = new RenderModel(handle, data.center, data.size);
        cache_object(name, CacheObjectType.MODEL, model);

        return model;
    }

    public override RenderTexture? load_texture_dir(string dir, string name)
    {
        ResourceCacheObject? cache = get_cache_object(name, CacheObjectType.TEXTURE);
        if (cache != null)
            return (RenderTexture)cache.obj;

        string str = dir + name + ".png";
        if (!FileLoader.exists(str))
            return null;

        SoilImage img = SoilWrap.load_image(str);

        ResourceTexture tex = new ResourceTexture(img.data, img.width, img.height);
        uint handle = renderer.load_texture(tex);

        RenderTexture texture = new RenderTexture(handle, Vec2() { x = img.width, y = img.height});
        cache_object(name, CacheObjectType.TEXTURE, texture);

        return texture;
    }

    public override RenderLabel2D? create_label()
    {
        ResourceLabel resource = new ResourceLabel();
        uint handle = renderer.load_label(resource);
        RenderLabel2D label = new RenderLabel2D(handle);

        return label;
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

public class OpenGLModelResourceHandle : IModelResourceHandle, Object
{
    public OpenGLModelResourceHandle(uint handle, int triangle_count, uint array_handle)
    {
        this.handle = handle;
        this.triangle_count = triangle_count;
        this.array_handle = array_handle;
    }

    public uint handle { get; private set; }
    public int triangle_count { get; private set; }
    public uint array_handle { get; private set; }
}

public class OpenGLTextureResourceHandle : ITextureResourceHandle, Object
{
    public OpenGLTextureResourceHandle(uint handle)
    {
        this.handle = handle;
    }

    public uint handle { get; private set; }
}

public class OpenGLLabelResourceHandle : ILabelResourceHandle
{
    public OpenGLLabelResourceHandle()
    {
        created = false;
    }

    public uint handle { get; set; }
}
