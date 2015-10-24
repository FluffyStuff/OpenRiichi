public class RenderObject3D
{
    public RenderObject3D(RenderModel? model, RenderTexture? texture)
    {
        this.model = model;
        this.texture = texture;
        rotation = Vec3.empty();
        position = Vec3.empty();
        scale = Vec3(1, 1, 1);
        light_multiplier = 1;
        diffuse_color = Color.black();
    }

    public RenderObject3D copy()
    {
        RenderObject3D obj = new RenderObject3D(model, texture);
        obj.rotation = rotation;
        obj.position = position;
        obj.scale = scale;
        obj.light_multiplier = light_multiplier;
        obj.diffuse_color = diffuse_color;

        return obj;
    }

    public RenderModel? model { get; set; }
    public RenderTexture? texture { get; set; }
    public Vec3 rotation { get; set; }
    public Vec3 position { get; set; }
    public Vec3 scale { get; set; }
    public float light_multiplier { get; set; }
    public Color diffuse_color { get; set; }
}
