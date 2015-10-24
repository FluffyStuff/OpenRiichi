public class RenderTable
{
    private RenderObject3D table;
    private RenderObject3D field;

    public RenderTable(IResourceStore store, Vec3 tile_size)
    {
        table = store.load_object_3D("table_low");

        string dir = FileLoader.get_user_dir() + "Custom/";

        RenderModel? model;
        RenderTexture? texture;

        model = store.load_model_dir(dir, "field", false);
        if (model == null)
            model = store.load_model("field", false);
        texture = store.load_texture_dir(dir, "field_low");
        if (texture == null)
            texture = store.load_texture("field_low");

        field = new RenderObject3D(model, texture);

        table.position = Vec3(0, -0.163f, 0);
        table.scale = Vec3(10, 10, 10);
        field.position = Vec3(0, 12.4f, 0);
        field.scale = Vec3(9.6f, 1, 9.6f);

        center = Vec3(0, field.position.y, 0);
        player_offset = field.scale.z - 1.0f - (tile_size.x + tile_size.z) / 2;
    }

    public void render(RenderScene3D scene)
    {
        scene.add_object(table);
        scene.add_object(field);
    }

    public Vec3 center { get; private set; }
    public float player_offset { get; private set; }
    //public float wall_offset { get; private set; }
}
