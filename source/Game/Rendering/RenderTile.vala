public class RenderTile
{
    // TODO: Use multi texturing

    public RenderTile(IResourceStore store, Tile tile)
    {
        tile_type = tile;

        RenderModel model = store.load_model("tile", true);
        RenderTexture texture = store.load_texture("Tiles/" + get_tile_type_name(tile_type.tile_type));

        this.tile = new RenderObject3D(model, texture);
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

        if (type == TileType.BLANK)
            return "Blank";
        else if (t >= (int)TileType.MAN1 && t <= (int)TileType.MAN9)
            return "Man" + (t - (int)TileType.MAN1 + 1).to_string();
        else if (t >= (int)TileType.PIN1 && t <= (int)TileType.PIN9)
            return "Pin" + (t - (int)TileType.PIN1 + 1).to_string();
        else if (t >= (int)TileType.SOU1 && t <= (int)TileType.SOU9)
            return "Sou" + (t - (int)TileType.SOU1 + 1).to_string();
        else if (type == TileType.KITA)
            return "Kita";
        else if (type == TileType.HIGASHI)
            return "Higashi";
        else if (type == TileType.MINAMI)
            return "Minami";
        else if (type == TileType.NISHI)
            return "Nishi";
        else if (type == TileType.HAKU)
            return "Haku";
        else if (type == TileType.HATSU)
            return "Hatsu";
        else if (type == TileType.CHUN)
            return "Chun";

        return "Blank";
    }

    public void render(RenderScene3D scene)
    {
        scene.add_object(tile);
    }

    public void set_hovered(bool hovered)
    {
        if (hovered)
            tile.diffuse_color = Vec3()
            {
                x = 1.5f,
                y = 1.5f,
                z = 1.0f
            };
        else
            tile.diffuse_color = {};
    }

    public Vec3 position
    {
        get { return tile.position; }
        set { tile.position = value; }
    }

    public Vec3 rotation
    {
        get { return tile.rotation; }
        set { tile.rotation = value; }
    }

    public Vec3 object_size { get { return tile.model.size; } }
    public RenderObject3D tile { get; private set; }
    public Tile tile_type { get; private set; }
}
