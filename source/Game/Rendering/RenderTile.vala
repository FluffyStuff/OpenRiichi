public class RenderTile
{
    // TODO: Use multi texturing

    private bool animation_set_time = false;
    private float animation_time = 0;
    private Vec3 animation_start_position;
    private Vec3 animation_end_position;
    private Vec3 animation_start_rotation;
    private Vec3 animation_end_rotation;
    private float animation_start_time = 0;
    private float animation_end_time = 0;

    public RenderTile(IResourceStore store, Tile tile, float scale)
    {
        tile_type = tile;

        RenderModel model = store.load_model("tile", true);
        RenderTexture texture = store.load_texture("Tiles/" + get_tile_type_name(tile_type.tile_type));

        this.tile = new RenderObject3D(model, texture);

        this.tile.scale = { scale, scale, scale };
    }

    public void assign_type(Tile type, IResourceStore store)
    {
        tile_type.tile_type = type.tile_type;
        tile_type.dora = type.dora;
        tile.texture = store.load_texture("Tiles/" + get_tile_type_name(tile_type.tile_type));
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
        Vec3 rot = Vec3.lerp(animation_start_rotation, animation_end_rotation, lerp);

        tile.position = pos;
        tile.rotation = rot;
    }

    public void set_absolute_location(Vec3 position, Vec3 rotation/*, float animation_time*/)
    {
        tile.position = position;
        tile.rotation = rotation;

        animation_set_time = false;
        animation_time = 0;
        animation_start_position = position;
        animation_end_position = position;
        animation_start_rotation = rotation;
        animation_end_rotation = rotation;
        animation_start_time = 0;
        animation_end_time = 0;
    }

    public void animate_towards(Vec3 position, Vec3 rotation)
    {
        animate_towards_with_time(position, rotation, 0.15f);
    }

    public void animate_towards_with_time(Vec3 position, Vec3 rotation, float time)
    {
        animation_set_time = true;
        animation_time = time;
        animation_start_position = tile.position;
        animation_end_position = position;
        animation_start_rotation = Calculations.rotation_mod(tile.rotation);
        animation_end_rotation = Calculations.rotation_ease(rotation, animation_start_rotation);
    }

    public void render(RenderScene3D scene)
    {
        scene.add_object(tile);
    }

    public void set_hovered(bool hovered)
    {
        float strength = 0.4f;
        if (hovered)
            tile.diffuse_color = Vec3()
            {
                x = strength * 1.5f,
                y = strength * 1.5f,
                z = strength
            };
        else
        {
            if (tile_type.dora)
                tile.diffuse_color = {0.2f, 0.2f, -0.4f};
            else
                tile.diffuse_color = {};
        }
    }

    public Vec3 position
    {
        get { return animation_end_position; }
    }

    public Vec3 rotation
    {
        get { return animation_end_rotation; }
    }

    public RenderObject3D tile { get; private set; }
    public Tile tile_type { get; private set; }
}
