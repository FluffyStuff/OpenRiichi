public class RenderObject2D
{
    public RenderObject2D(RenderTexture? texture)
    {
        this.texture = texture;
        rotation = 0;
        position = { };
        scale = Vec2() { x = 1, y = 1 };
        alpha = 1;
    }

    public RenderObject2D copy()
    {
        RenderObject2D obj = new RenderObject2D(texture);
        obj.rotation = rotation;
        obj.position = position;
        obj.scale = scale;
        obj.alpha = alpha;
        obj.diffuse_color = diffuse_color;

        return obj;
    }

    public RenderTexture? texture { get; set; }
    public float rotation { get; set; }
    public Vec2 position { get; set; }
    public Vec2 scale { get; set; }
    public float alpha { get; set; }
    public Vec3 diffuse_color { get; set; }
}
