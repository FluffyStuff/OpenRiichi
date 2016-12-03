public class RenderTable
{
    private Vec3 tile_size;
    private float field_rotation;
    private Wind round_wind;
    private RoundScoreState score;

    private RenderGeometry3D table;
    private RenderGeometry3D? field;

    private RenderGeometry3D center_piece;

    private RenderLabel3D round_wind_label;
    private RenderTablePlayerNameField[] names;

    public RenderTable(ResourceStore store, string extension, Vec3 tile_size, Wind round_wind, float field_rotation, RoundScoreState score)
    {
        this.tile_size = tile_size;
        this.field_rotation = field_rotation;
        this.round_wind = round_wind;
        this.score = score;

        reload(store, extension);
    }

    public void render(RenderScene3D scene)
    {
        scene.add_object(table);
        scene.add_object(field);
        scene.add_object(center_piece);
        scene.add_object(round_wind_label);

        foreach (RenderTablePlayerNameField name in names)
            name.render(scene);
    }

    public void reload(ResourceStore store, string extension)
    {
        table = store.load_geometry_3D("table_" + extension, true);
        center_piece = store.load_geometry_3D("table_center", true);

        float scale = tile_size.x * 2.9f;
        center_piece.scale = Vec3(scale, scale, scale);

        string dir = Environment.get_user_dir() + "Custom/";

        RenderTexture? texture = store.load_texture_dir(dir, "field");

        if (texture != null)
            field = store.load_geometry_3D_dir(dir, "field", false);
        else
            texture = store.load_texture("field_" + extension);

        if (field == null)
            field = store.load_geometry_3D("field", false);

        ((RenderBody3D)field.geometry[0]).texture = texture;

        table.position = Vec3(0, -0.163f, 0);
        table.scale = Vec3(10, 10, 10);
        field.position = Vec3(0, 0, 0);
        field.scale = Vec3(9.6f, 1, 9.6f);
        field.rotation = new Quat.from_euler_vec(Vec3(0, field_rotation, 0));

        center = Vec3(0, field.position.y, 0);
        player_offset = field.scale.z - 0.3f - (tile_size.x / 2 + tile_size.z);

        names = new RenderTablePlayerNameField[score.players.length];

        Vec3 center_size = ((RenderBody3D)center_piece.geometry[0]).model.size.mul_scalar(scale);
        center_size = Vec3(center_size.x, center_size.y * 1.1f, center_size.z);

        for (int i = 0; i < names.length; i++)
            names[i] = new RenderTablePlayerNameField(store, center_size, scale, -(float)i / 2, score.players[i].name, score.players[i].wind, score.players[i].points);

        round_wind_label = store.create_label_3D();
        round_wind_label.bold = true;
        round_wind_label.rotation = new Quat.from_euler_vec(Vec3(0, field_rotation, 0));
        round_wind_label.text = WIND_TO_STRING(round_wind);
        round_wind_label.color = Color.blue();
        round_wind_label.size = scale * 2;
        round_wind_label.font_size = 100;
        round_wind_label.position = Vec3(0, center_size.y, 0);
    }

    public Vec3 center { get; private set; }
    public float player_offset { get; private set; }
    //public float wall_offset { get; private set; }
}

private class RenderTablePlayerNameField
{
    private RenderLabel3D wind_label;
    private RenderLabel3D name_label;
    private RenderLabel3D score_label;

    public RenderTablePlayerNameField(ResourceStore store, Vec3 center_size, float scale, float rotation, string name, Wind wind, int score)
    {
        float dist = 0.5f;
        scale *= 0.8f;

        wind_label = store.create_label_3D();
        wind_label.bold = true;
        wind_label.rotation = new Quat.from_euler_vec(Vec3(0, rotation, 0));
        wind_label.text = WIND_TO_STRING(wind);
        wind_label.color = Color.blue();
        wind_label.size = scale;

        float offset = -center_size.x / 2 * dist + wind_label.end_size.z / 2 + wind_label.end_size.x / 2;
        Vec3 pos = Calculations.rotate_y(Vec3.empty(), -rotation, Vec3(offset, center_size.y, center_size.z / 2 * dist));
        wind_label.position = pos;

        name_label = store.create_label_3D();
        name_label.bold = true;
        name_label.rotation = new Quat.from_euler_vec(Vec3(0, rotation, 0));
        name_label.text = name;
        name_label.size = wind_label.size * 0.6f;
        name_label.font_size = wind_label.font_size * 0.6f;
        name_label.color = wind_label.color;

        pos = Calculations.rotate_y(Vec3.empty(), -rotation, Vec3(offset + wind_label.end_size.x / 2 + name_label.end_size.x / 2, center_size.y, center_size.z / 2 * dist));
        name_label.position = pos;

        score_label = store.create_label_3D();
        score_label.bold = true;
        score_label.rotation = new Quat.from_euler_vec(Vec3(0, rotation, 0));
        score_label.text = score.to_string();
        score_label.size = wind_label.size * 0.6f;
        name_label.font_size = wind_label.font_size * 0.6f;

        pos = Calculations.rotate_y(Vec3.empty(), -rotation, Vec3(offset + wind_label.end_size.x / 2 + score_label.end_size.x / 2, center_size.y, center_size.z / 2 * dist + name_label.end_size.z / 2 + score_label.end_size.z / 2));
        score_label.position = pos;
    }

    public void render(RenderScene3D scene)
    {
        scene.add_object(wind_label);
        scene.add_object(name_label);
        scene.add_object(score_label);
    }
}
