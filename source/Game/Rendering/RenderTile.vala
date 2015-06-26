public class RenderTile
{
    private static Rand rnd = new Rand();
    // TODO: Use multi texturing

    public RenderTile(IResourceStore store)
    {
        RenderModel model = store.load_model("tile");
        RenderTexture texture = store.load_texture("Tiles/" + get_random_name());

        tile = new Render3DObject(model, texture);
    }

    private string get_random_name()
    {
        int tile = rnd.int_range(0, 10);

        string[] tiles =
        {
            "Man",
            "Sou",
            "Pin",
            "Haku",
            "Hatsu",
            "Chun",
            "Kita",
            "Higashi",
            "Minami",
            "Nishi"
        };

        string ret = tiles[tile];
        if (tile <= 2)
            ret += rnd.int_range(1, 10).to_string();

        return ret;
    }

    public void render(RenderState state)
    {
        state.add_3D_object(tile);
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
    public Render3DObject tile { get; private set; }
}
