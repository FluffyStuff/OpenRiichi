public abstract class RenderObject2D : Object
{
    public abstract RenderObject2D copy();

    public float rotation { get; set; }
    public Vec2 position { get; set; }
    public Vec2 scale { get; set; }
    public float alpha { get; set; }
    public Vec3 diffuse_color { get; set; }
}

public class RenderImage2D : RenderObject2D
{
    public RenderImage2D(RenderTexture? texture)
    {
        this.texture = texture;
        rotation = 0;
        position = { };
        scale = Vec2() { x = 1, y = 1 };
        alpha = 1;
    }

    public override RenderObject2D copy()
    {
        RenderImage2D img = new RenderImage2D(texture);
        img.rotation = rotation;
        img.position = position;
        img.scale = scale;
        img.alpha = alpha;
        img.diffuse_color = diffuse_color;

        return img;
    }

    public RenderTexture? texture { get; set; }
}

public class RenderLabel2D : RenderObject2D
{
    public RenderLabel2D(uint handle)
    {
        this.handle = handle;
        rotation = 0;
        position = { };
        scale = Vec2() { x = 1, y = 1 };
        alpha = 1;

        font_type = "Sans Bold";
        font_size = 40;
        text = "";
    }

    public override RenderObject2D copy()
    {
        RenderLabel2D img = new RenderLabel2D(handle);
        img.info = info;
        img.font_type = font_type;
        img.font_size = font_size;
        img.text = text;
        img.rotation = rotation;
        img.position = position;
        img.scale = scale;
        img.alpha = alpha;
        img.diffuse_color = diffuse_color;

        return img;
    }

    public uint handle { get; private set; }
    public LabelInfo? info { get; set; }
    public string font_type { get; set; }
    public float font_size { get; set; }
    public string text { get; set; }
}

public class RenderRectangle2D : RenderObject2D
{
    public RenderRectangle2D()
    {
        rotation = 0;
        position = { };
        scale = Vec2() { x = 1, y = 1 };
        alpha = 1;
    }

    public override RenderObject2D copy()
    {
        RenderRectangle2D rect = new RenderRectangle2D();
        rect.rotation = rotation;
        rect.position = position;
        rect.scale = scale;
        rect.alpha = alpha;
        rect.diffuse_color = diffuse_color;

        return rect;
    }
}
