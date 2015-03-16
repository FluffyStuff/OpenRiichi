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

    public OpenGLResourceStore(OpenGLRenderer renderer)
    {
        this.renderer = renderer;
    }

    public override Render3DObject? load_3D_object(string name)
    {
        int width, height;
        uchar *image = SOIL.load_image(name + ".png", out width, out height, null, SOIL.LoadFlags.RGB);

        ResourceTexture texture = new ResourceTexture((char*)image, width, height);
        uint texture_handle = renderer.load_texture(texture);

        string[] lines = FileLoader.load(name + ".obj");
        ModelData data = ObjParser.parse(lines);

        Resource3DObject obj = new Resource3DObject(data.create_points());
        uint obj_handle = renderer.load_3D_object(obj);

        RenderTexture tex = new RenderTexture(texture_handle);
        Render3DObject obj_3d = new Render3DObject(tex, obj_handle);

        return obj_3d;
    }
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

public class Render3DObject
{
    public Render3DObject(RenderTexture? texture, uint handle)
    {
        this.texture = texture;
        this.handle = handle;
        rotation = { };
        position = { };
        scale = Vec3() { x = 1, y = 1, z = 1 };
        alpha = 1;
        light_multiplier = 1;
    }

    public RenderTexture texture { get; private set; }
    public uint handle { get; private set; }
    public Vec3 rotation { get; set; }
    public Vec3 position { get; set; }
    public Vec3 scale { get; set; }
    public float alpha { get; set; }
    public float light_multiplier { get; set; }
}

public class LightSource
{
    public LightSource()
    {

    }

    public Vec3 position { get; set; }
}

public struct Vec3
{
    float x;
    float y;
    float z;
}
