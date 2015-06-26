public class Render3DObject
{
    public Render3DObject(RenderModel? model, RenderTexture? texture)
    {
        this.model = model;
        this.texture = texture;
        rotation = { };
        position = { };
        scale = Vec3() { x = 1, y = 1, z = 1 };
        alpha = 1;
        light_multiplier = 1;
    }

    public RenderModel? model { get; set; }
    public RenderTexture? texture { get; set; }
    public Vec3 rotation { get; set; }
    public Vec3 position { get; set; }
    public Vec3 scale { get; set; }
    public float alpha { get; set; }
    public float light_multiplier { get; set; }
    public Vec3 diffuse_color { get; set; }
}
