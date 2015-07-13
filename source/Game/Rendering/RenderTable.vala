public class RenderTable
{
    private RenderObject3D table;
    private RenderObject3D field;

    public RenderTable(IResourceStore store)
    {
        table = store.load_object_3D("table");
        field = store.load_object_3D("field");

        table.position = Vec3() { y = -0.163f };
        table.scale = Vec3() { x = 10, y = 10, z = 10 };
        field.position = Vec3() { y = 12.4f };
        field.scale = Vec3() { x = 9.6f, y = 1, z = 9.6f };

        center = Vec3() { y = field.position.y };
        player_offset = field.scale.z;
        wall_offset = player_offset / 2.5f;
    }

    public void render(RenderScene3D scene)
    {
        scene.add_object(table);
        scene.add_object(field);
    }

    public Vec3 center { get; private set; }
    public float player_offset { get; private set; }
    public float wall_offset { get; private set; }
}
