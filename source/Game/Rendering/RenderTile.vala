using Engine;
using Gee;

public class RenderTile : WorldObjectTransformable
{
    private bool _hovered = false;
    private bool _indicated = false;
    private float _scale;

    private Color _front_color = Color.white();
    private Color _back_color = Color.black();

    public RenderTile()
    {
        tile_type = new Tile(0, TileType.BLANK, false);
        _scale = 1;

        selectable = true;
    }

    protected override void added()
    {
        reload();
    }

    public void reload()
    {
        RenderGeometry3D tile = store.load_geometry_3D("tile_" + quality_enum_to_string(model_quality), false);
        set_object(tile);

        transform.scale = Vec3(scale, scale, scale);
        front = ((RenderObject3D)tile.geometry[0]);
        back  = ((RenderObject3D)tile.geometry[1]);
        obb = Vec3(front.model.size.x, front.model.size.y + back.model.size.y, front.model.size.z);

        load_material();
    }

    private void load_material()
    {
        Color ambient = Color(0.1f, 0.1f, 0.1f, 1);

        MaterialSpecification spec = front.material.spec;
        spec.ambient_color = UniformType.STATIC;
        spec.diffuse_color = UniformType.DYNAMIC;
        spec.target_color = UniformType.DYNAMIC;
        spec.alpha = UniformType.DYNAMIC;
        spec.static_ambient_color = ambient;
        front.material = store.load_material(spec);
        front.material.textures[0] = get_texture();

        spec = back.material.spec;
        spec.textures = 0;
        spec.ambient_color = UniformType.STATIC;
        spec.diffuse_color = UniformType.DYNAMIC;
        spec.target_color = UniformType.DYNAMIC;
        spec.alpha = UniformType.DYNAMIC;
        spec.static_ambient_color = ambient;
        back.material = store.load_material(spec);

        set_diffuse_color();
    }

    private RenderTexture get_texture()
    {
        string tex = tile_texture_enum_to_string(texture_type);
        string name = "Tiles/" + tex + "/" + TILE_TYPE_TO_STRING(tile_type.tile_type);

        if (tile_type.dora)
        {
            RenderTexture? texture = store.load_texture(name + "-Dora");
            if (texture != null)
                return texture;
        }

        return store.load_texture(name);
    }

    public void set_absolute_location(Vec3 position, Quat rotation)
    {
        cancel_buffered_animations();
        transform.rotation = rotation;
        transform.position = position;
    }

    public void animate_towards(Vec3 position, Quat rotation, AnimationTime time)
    {
        WorldObjectAnimation animation = new WorldObjectAnimation(time);
        Path3D path = new LinearPath3D(position);
        animation.do_absolute_position(path);
        PathQuat rot = new LinearPathQuat(rotation);
        animation.do_absolute_rotation(rot);

        animation.curve = new SmoothApproachCurve();
        
        cancel_buffered_animations();
        animate(animation, true);
    }

    private void set_diffuse_color()
    {
        float target = hovered || indicated ? 0.5f : 0;
        Color col = Color(hovered ? 1 : 0, 1, 0, 1);

        front.material.target_color = col;
        back.material.target_color = col;
        front.material.target_color_strength = target;
        back.material.target_color_strength = target;

        front.material.diffuse_color = front_color;
        back.material.diffuse_color = back_color;
    }

    public Color front_color
    {
        get { return _front_color; }
        set
        {
            _front_color = value;
            set_diffuse_color();
        }
    }

    public Color back_color
    {
        get { return _back_color; }
        set
        {
            _back_color = value;
            set_diffuse_color();
        }
    }

    public float alpha
    {
        get { return front.material.alpha; }
        set
        {
            front.material.alpha = value;
            back.material.alpha = value;
        }
    }

    private RenderObject3D front { get; private set; }
    private RenderObject3D back { get; private set; }
    public Tile tile_type { get; set; }
    public QualityEnum model_quality { get; set; }
    public TileTextureEnum texture_type { get; set; }

    public new float scale
    {
        get { return _scale; }
        set
        {
            _scale = value;
            transform.scale = Vec3(value, value, value);
        }
    }

    public bool hovered
    {
        get { return _hovered; }
        set
        {
            if (_hovered == value)
                return;
            _hovered = value;
            set_diffuse_color();
        }
    }

    public bool indicated
    {
        get { return _indicated; }
        set
        {
            if (_indicated == value)
                return;
            _indicated = value;
            set_diffuse_color();
        }
    }

    public static ArrayList<RenderTile> sort_tiles(ArrayList<RenderTile> list)
    {
        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        tiles.add_all(list);

        tiles.sort
        (
            (t1, t2) =>
            {
                int a = (int)t1.tile_type.tile_type;
                int b = (int)t2.tile_type.tile_type;
                return (int) (a > b) - (int) (a < b);
            }
        );

        return tiles;
    }
}
