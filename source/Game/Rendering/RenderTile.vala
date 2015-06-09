public class RenderTile
{
    private Render3DObject tile;

    public RenderTile(IResourceStore store)
    {
        tile = store.load_3D_object("./Data/models/box");
    }

    public void render(RenderState state)
    {
        state.add_3D_object(tile);
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
}
