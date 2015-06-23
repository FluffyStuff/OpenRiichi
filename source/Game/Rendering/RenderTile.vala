public class RenderTile
{
    public RenderTile(IResourceStore store)
    {
        tile = store.load_3D_object("./Data/models/box");
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

    public Vec3 object_size { get { return tile.object_size; } }
    public Render3DObject tile { get; private set; }
}
