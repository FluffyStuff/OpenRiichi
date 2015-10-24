public abstract class RenderObject2D : Object
{
    public abstract RenderObject2D copy();

    public float rotation { get; set; }
    public Vec2 position { get; set; }
    public Size2 scale { get; set; }
    public Color diffuse_color { get; set; }
}

public class RenderImage2D : RenderObject2D
{
    public RenderImage2D(RenderTexture? texture)
    {
        this.texture = texture;
        rotation = 0;
        position = Vec2.empty();
        scale = Size2(1, 1);
    }

    public override RenderObject2D copy()
    {
        RenderImage2D img = new RenderImage2D(texture);
        img.rotation = rotation;
        img.position = position;
        img.scale = scale;
        img.diffuse_color = diffuse_color;

        return img;
    }

    public RenderTexture? texture { get; set; }
}

public class RenderLabel2D : RenderObject2D
{
    private LabelResourceReference reference;
    private string _font_type;
    private float _font_size;
    private string _text;

    ~RenderLabel2D()
    {
        reference.delete();
    }

    public RenderLabel2D(uint handle, LabelResourceReference reference)
    {
        this.handle = handle;
        this.reference = reference;

        rotation = 0;
        position = Vec2.empty();
        scale = Size2(1, 1);

        _font_type = "Sans Bold";
        _font_size = 40;
        _text = "";

        diffuse_color = Color.white();
    }

    public override RenderObject2D copy()
    {
        RenderLabel2D img = new RenderLabel2D(handle, reference);
        img.info = info;
        img.font_type = font_type;
        img.font_size = font_size;
        img.text = text;
        img.rotation = rotation;
        img.position = position;
        img.scale = scale;
        img.diffuse_color = diffuse_color;

        return img;
    }

    private void update()
    {
        info = reference.update(font_type, font_size, text);
    }

    public uint handle { get; private set; }
    public LabelInfo? info { get; private set; }

    public string font_type
    {
        get { return _font_type; }
        set
        {
            if (_font_type == value)
                return;

            _font_type = value;
            update();
        }
    }

    public float font_size
    {
        get { return _font_size; }
        set
        {
            if (_font_size == value)
                return;

            _font_size = value;
            update();
        }
    }

    public string text
    {
        get { return _text; }
        set
        {
            if (_text == value)
                return;

            _text = value;
            update();
        }
    }
}

public class RenderRectangle2D : RenderObject2D
{
    public RenderRectangle2D()
    {
        rotation = 0;
        position = Vec2.empty();
        scale = Size2(1, 1);
        diffuse_color = Color.black();
    }

    public override RenderObject2D copy()
    {
        RenderRectangle2D rect = new RenderRectangle2D();
        rect.rotation = rotation;
        rect.position = position;
        rect.scale = scale;
        rect.diffuse_color = diffuse_color;

        return rect;
    }
}
