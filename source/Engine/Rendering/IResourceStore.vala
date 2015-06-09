using Gee;

public interface IResourceStore : Object
{
    public abstract Render3DObject? load_3D_object(string name);
}

public abstract class ResourceStore : IResourceStore, Object
{
    public abstract Render3DObject? load_3D_object(string name);
}

public class OpenGLResourceStore : ResourceStore
{
    private unowned OpenGLRenderer renderer;
    private ArrayList<OpenGLResourceCacheObject> cache = new ArrayList<OpenGLResourceCacheObject>();

    public OpenGLResourceStore(OpenGLRenderer renderer)
    {
        this.renderer = renderer;
    }

    public override Render3DObject? load_3D_object(string name)
    {
        OpenGLResourceCacheObject? cache = get_cache_object(name);
        if (cache != null)
            return new Render3DObject(cache.texture, cache.handle, cache.median, cache.size);

        int width, height;
        uchar *image = SOIL.load_image(name + ".png", out width, out height, null, SOIL.LoadFlags.RGB);

        ResourceTexture texture = new ResourceTexture((char*)image, width, height);
        uint texture_handle = renderer.load_texture(texture);

        string[] lines = FileLoader.load(name + ".obj");
        ModelData data = ObjParser.parse(lines);

        Resource3DObject obj = new Resource3DObject(data.points);
        uint obj_handle = renderer.load_3D_object(obj);

        RenderTexture tex = new RenderTexture(texture_handle);
        Render3DObject obj_3d = new Render3DObject(tex, obj_handle, data.median, data.size);

        cache_object(name, obj_handle, tex, data.median, data.size);

        return obj_3d;
    }

    private void cache_object(string name, uint handle, RenderTexture texture, Vec3 median, Vec3 size)
    {
        cache.add(new OpenGLResourceCacheObject(name, handle, texture, median, size));
    }

    private OpenGLResourceCacheObject? get_cache_object(string name)
    {
        foreach (OpenGLResourceCacheObject obj in cache)
            if (obj.name == name)
                return obj;
        return null;
    }
}

private class OpenGLResourceCacheObject
{
    public OpenGLResourceCacheObject(string name, uint handle, RenderTexture texture, Vec3 median, Vec3 size)
    {
        this.name = name;
        this.handle = handle;
        this.texture = texture;
        this.median = median;
        this.size = size;
    }

    public string name { get; private set; }
    public uint handle { get; private set; }
    public RenderTexture texture { get; private set; }
    public Vec3 median { get; private set; }
    public Vec3 size { get; private set; }
}

public class ResourceTexture
{
    public ResourceTexture(char *data, int width, int height)
    {
        this.data = data;
        this.width = width;
        this.height = height;
    }

    public char *data { get; private set; }
    public int width { get; private set; }
    public int height { get; private set; }
}

public class Resource3DObject
{
    public Resource3DObject(ModelPoint[] points)
    {
        this.points = points;
    }

    public ModelPoint[] points { get; private set; }
}

public class RenderTexture
{
    public RenderTexture(uint handle)
    {
        this.handle = handle;
    }

    public uint handle { get; private set; }
}
