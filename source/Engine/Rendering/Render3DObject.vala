public class Render3DObject
{
    public Render3DObject(RenderTexture? texture, uint handle, Vec3 median, Vec3 size)
    {
        this.texture = texture;
        this.handle = handle;
        object_median = median;
        object_size = size;
        rotation = { };
        position = { };
        scale = Vec3() { x = 1, y = 1, z = 1 };
        alpha = 1;
        light_multiplier = 1;
    }

    public RenderTexture texture { get; private set; }
    public uint handle { get; private set; }
    public Vec3 object_median { get; private set; }
    public Vec3 object_size { get; private set; }
    public Vec3 rotation { get; set; }
    public Vec3 position { get; set; }
    public Vec3 scale { get; set; }
    public float alpha { get; set; }
    public float light_multiplier { get; set; }
    public Vec3 diffuse_color { get; set; }
}
