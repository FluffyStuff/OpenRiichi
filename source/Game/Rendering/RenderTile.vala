public class RenderTile
{
    // TODO: Use multi texturing

    private string extension;
    private string texture_type;
    private bool _hovered = false;
    private bool _indicated = false;
    private float scale;

    private bool animation_set_time = false;
    private float animation_time = 0;
    private Vec3 animation_start_position;
    private Vec3 animation_end_position;
    private Quat animation_start_rotation;
    private Quat animation_end_rotation;
    private float animation_start_time = 0;
    private float animation_end_time = 0;

    private Color _front_color = Color.white();
    private Color _back_color = Color.black();

    public RenderTile(ResourceStore store, string extension, string texture_type, Tile tile, float scale)
    {
        this.extension = extension;
        this.texture_type = texture_type;
        tile_type = tile;
        this.scale = scale;

        reload(store, extension, texture_type);
    }

    public void assign_type(Tile type, ResourceStore store)
    {
        tile_type.tile_type = type.tile_type;
        tile_type.dora = type.dora;

        foreach (Transformable3D o in this.tile.geometry)
        {
            RenderBody3D obj = (RenderBody3D)o;
            if (obj.model.name == "Top")
            {
                obj.texture = get_texture(store, tile_type.tile_type, tile_type.dora, texture_type);
                break;
            }
        }
    }

    public void reload(ResourceStore store, string extension, string texture_type)
    {
        this.texture_type = texture_type;
        this.tile = store.load_geometry_3D("tile_" + extension, false);
        this.tile.scale = Vec3(scale, scale, scale);
        front = ((RenderBody3D)tile.geometry[0]);
        back  = ((RenderBody3D)tile.geometry[1]);
        model_size = Vec3(front.model.size.x, front.model.size.y + back.model.size.y, front.model.size.z);

        assign_type(tile_type, store);
        set_diffuse_color();
    }

    private static RenderTexture get_texture(ResourceStore store, TileType tile_type, bool dora, string texture_type)
    {
        string name = "Tiles/" + texture_type + "/" + get_tile_type_name(tile_type);

        if (dora)
        {
            RenderTexture? texture = store.load_texture(name + "-Dora");
            if (texture != null)
                return texture;
        }

        return store.load_texture(name);
    }

    private static string get_tile_type_name(TileType type)
    {
        int t = (int)type;

        if (t >= (int)TileType.MAN1 && t <= (int)TileType.MAN9)
            return "Man" + (t - (int)TileType.MAN1 + 1).to_string();
        else if (t >= (int)TileType.PIN1 && t <= (int)TileType.PIN9)
            return "Pin" + (t - (int)TileType.PIN1 + 1).to_string();
        else if (t >= (int)TileType.SOU1 && t <= (int)TileType.SOU9)
            return "Sou" + (t - (int)TileType.SOU1 + 1).to_string();
        else if (type == TileType.TON)
            return "Ton";
        else if (type == TileType.NAN)
            return "Nan";
        else if (type == TileType.SHAA)
            return "Shaa";
        else if (type == TileType.PEI)
            return "Pei";
        else if (type == TileType.HAKU)
            return "Haku";
        else if (type == TileType.HATSU)
            return "Hatsu";
        else if (type == TileType.CHUN)
            return "Chun";

        return "Blank";
    }

    public void process(DeltaArgs args)
    {
        if (animation_set_time)
        {
            animation_start_time = args.time;
            animation_end_time = args.time + animation_time;
            animation_set_time = false;
        }

        if (args.time >= animation_end_time)
        {
            tile.position = animation_end_position;
            tile.rotation = animation_end_rotation;
            return;
        }

        float duration = animation_end_time - animation_start_time;
        float current = args.time - animation_start_time;
        float lerp = current / duration;

        Vec3 pos = Vec3.lerp(animation_start_position, animation_end_position, lerp);
        Quat rot = Quat.slerp(animation_start_rotation, animation_end_rotation, lerp);

        tile.position = pos;
        tile.rotation = rot;
    }

    public void set_absolute_location(Vec3 position, Quat rotation)
    {
        tile.rotation = rotation;
        tile.position = position;

        animation_set_time = false;
        animation_time = 0;
        animation_start_position = position;
        animation_end_position = position;
        animation_start_rotation = tile.rotation;
        animation_end_rotation = tile.rotation;
        animation_start_time = 0;
        animation_end_time = 0;
    }

    public void animate_towards(Vec3 position, Quat rotation)
    {
        animate_towards_with_time(position, rotation, 0.15f);
    }

    public void animate_towards_with_time(Vec3 position, Quat rotation, float time)
    {
        animation_set_time = true;
        animation_time = time;
        animation_start_position = tile.position;
        animation_end_position = position;
        animation_start_rotation = tile.rotation;
        animation_end_rotation = rotation;
    }

    public void render(RenderScene3D scene)
    {
        scene.add_object(tile);
    }

    public Vec3 position
    {
        get { return animation_end_position; }
    }

    public Quat rotation
    {
        get { return animation_end_rotation; }
    }

    private void set_diffuse_color()
    {
        front.material.diffuse_color = front_color;
        back.material.diffuse_color = back_color;
        back.material.diffuse_material_strength = 0;

        Color amb = indicated ? Color(-1.0f, 1.0f, -1.0f, 0.3f) : Color.none();

        if (hovered)
            amb = Color(0.3f, 0.3f, 0.2f, 0.5f);
        /*
        float strength = 0.4f;
        //front.material.ambient_color = Color(strength * 1.5f, strength * 1.5f, strength, 0);
        //back.material.ambient_color = Color(strength * 1.5f, strength * 1.5f, strength, 0);

        if (hovered)
        {
            amb = ;
            //front.material.ambient_color = Color(strength * 1.5f, strength * 1.5f, strength, 1);
            //back.material.ambient_color = Color(strength * 1.5f, strength * 1.5f, strength, 1);
            //front.material.ambient_color = Color(.a = 1.0f;
            //back.material.ambient_color.a = 1.0f;* /
        }
        else
        {
            amb = Color.none();
            //front.material.ambient_color = front_color;
            //back.material.ambient_color = back_color;
            //front.material.diffuse_color = front_color;
            //back.material.diffuse_color = back_color;
        }*/

        front.material.ambient_color = Color
        (
            front_color.r + amb.r,
            front_color.g + amb.g,
            front_color.b + amb.b,
            front.material.ambient_material_strength / 2 + amb.a
        );

        back.material.ambient_color = Color
        (
            back_color.r + amb.r,
            back_color.g + amb.g,
            back_color.b + amb.b,
            back.material.ambient_material_strength / 2 + amb.a
        );
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

    public Vec3 model_size { get; private set; }
    public RenderGeometry3D tile { get; private set; }
    private RenderBody3D front { get; private set; }
    private RenderBody3D back { get; private set; }
    public Tile tile_type { get; private set; }

    public bool hovered
    {
        get { return _hovered; }
        set
        {
            _hovered = value;
            set_diffuse_color();
        }
    }

    public bool indicated
    {
        get { return _indicated; }
        set
        {
            _indicated = value;
            set_diffuse_color();
        }
    }
}
