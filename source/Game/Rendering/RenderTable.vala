public class RenderTable
{
    private Render3DObject table;
    private Render3DObject field;
    private Vec3 _center;
    private float _player_offset;

    public RenderTable(IResourceStore store)
    {
        table = store.load_3D_object("./Data/models/table");
        field = store.load_3D_object("./Data/models/field");

        table.position = Vec3() { y = -0.163f };
        table.scale = Vec3() { x = 10, y = 10, z = 10 };
        field.position = Vec3() { y = 12.4f };
        field.scale = Vec3() { x = 9.6f, y = 1, z = 9.6f };

        _center = Vec3() { y = field.position.y };
        _player_offset = 9.6f;
    }

    public void render(RenderState state, IResourceStore store)
    {
        state.add_3D_object(table);
        state.add_3D_object(field);
    }

    public Vec3 center { get { return _center; } }
    public float player_offset { get { return _player_offset; } }
}
