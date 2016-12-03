using Gee;

public class ScoringHandView : View3D
{
    private Scoring score;

    private ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
    private Camera camera = new Camera();
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();
    private float width = 1;

    public ScoringHandView(Scoring score)
    {
        base();

        this.score = score;
        resize_style = ResizeStyle.ABSOLUTE;
    }

    public override void added()
    {
        Options options = new Options.from_disk();

        string extension = Options.quality_enum_to_string(options.model_quality);
        string texture_type = options.tile_textures;
        float tile_scale = 0.75f;

        RenderGeometry3D model = store.load_geometry_3D("tile_" + extension, false);
        Vec3 tile_size = ((RenderBody3D)model.geometry[0]).model.size;
        tile_size = Vec3(tile_size.x, tile_size.y + ((RenderBody3D)model.geometry[1]).model.size.y, tile_size.z).mul_scalar(tile_scale);

        width = (score.player.hand.size + 2) * tile_size.x;

        ArrayList<RenderCalls.RenderCall> calls = new ArrayList<RenderCalls.RenderCall>();

        for (int i = 0; i < score.player.calls.size; i++)
        {
            RoundStateCall call = score.player.calls[score.player.calls.size - i - 1];
            RenderCalls.RenderCall c = create_call(call, score.player.index, store, extension, texture_type, tile_scale, tile_size);

            calls.add(c);
            width += c.width + tile_size.x;
        }

        float p = -width / 2;
        for (int i = 0; i < score.player.hand.size; i++)
        {
            Tile t = score.player.hand[i];
            RenderTile tile = new RenderTile(store, extension, texture_type, t, tile_scale);

            bool added = false;
            for (int j = 0; j < tiles.size; j++)
            {
                if (t.tile_type <= tiles[j].tile_type.tile_type)
                {
                    tiles.insert(j, tile);
                    added = true;
                    break;
                }
            }

            if (!added)
                tiles.add(tile);
        }

        for (int i = 0; i < tiles.size; i++)
        {
            tiles[i].set_absolute_location(Vec3(p + tile_size.x * 0.5f, 0, 0), new Quat.from_euler(0, 1, 0));
            p += tile_size.x;
        }

        RenderTile tile = new RenderTile(store, extension, texture_type, score.round.win_tile, tile_scale);
        tile.set_absolute_location(Vec3(p + tile_size.x * 1.5f, 0, 0), new Quat.from_euler(0, 1, 0));
        p += tile_size.x * 2;
        tiles.add(tile);

        foreach (RenderCalls.RenderCall call in calls)
        {
            p += call.width + tile_size.x;
            foreach (RenderTile t in call.tiles)
                tiles.add(t);
            position_call(call, tile_size, p - tile_size.x * 0.5f);
        }

        foreach (RenderTile t in tiles)
        {
            t.front_color = options.tile_fore_color;
            t.back_color = options.tile_back_color;
        }

        float len = 15;
        camera.focal_length = 0.03f;

        Vec3 pos = Vec3(0, len, len / 5);
        camera.position = pos;
        camera.pitch = -0.435f;
        camera.roll = 0;

        light1.color = Color.white();
        light1.position = Vec3(len, len * 2, -len);
        light1.intensity = 15;
        light2.color = Color.white();
        light2.position = Vec3(-len, len * 2, -len);
        light2.intensity = 15;
    }

    private RenderCalls.RenderCall create_call(RoundStateCall call, int player_index, ResourceStore store, string extension, string texture_type, float tile_scale, Vec3 tile_size)
    {
        ArrayList<RenderTile> tiles = new ArrayList<RenderTile>();
        RenderTile? call_tile = null;

        foreach (Tile t in call.tiles)
        {
            RenderTile tl = new RenderTile(store, extension, texture_type, t, tile_scale);

            if (call.call_type == RoundStateCall.CallType.CHII && call.call_tile != null && t.ID == call.call_tile.ID)
                call_tile = tl;
            else
                tiles.add(tl);
        }

        RenderCalls.RenderCall? c = null;
        RenderCalls.Alignment align = (RenderCalls.Alignment)((call.discarder_index - player_index + 4) % 4);

        if (call.call_type == RoundStateCall.CallType.CHII)
            c = new RenderCalls.RenderCallChii(call_tile, tiles, tile_size);
        else if (call.call_type == RoundStateCall.CallType.PON)
            c = new RenderCalls.RenderCallPon(tiles, tile_size, align);
        else if (call.call_type == RoundStateCall.CallType.OPEN_KAN)
            c = new RenderCalls.RenderCallOpenKan(tiles, tile_size, align);
        else if (call.call_type == RoundStateCall.CallType.CLOSED_KAN)
            c = new RenderCalls.RenderCallClosedKan(tiles, tile_size);
        else if (call.call_type == RoundStateCall.CallType.LATE_KAN)
            c = new RenderCalls.RenderCallLateKan(tiles, tile_size, align);

        return c;
    }

    private void position_call(RenderCalls.RenderCall call, Vec3 tile_size, float p)
    {
        Vec3 x_dir = Vec3(1, 0, 0);
        Vec3 z_dir = Vec3(0, 0, 1);
        Vec3 position = Vec3(p, -tile_size.y / 2, 0);
        call.arrange(position, x_dir, z_dir, 1);

        foreach (RenderTile t in call.tiles)
            t.set_absolute_location(t.position, t.rotation); // Force new position without animation
    }

    public override void do_render_3D(RenderState state)
    {
        RenderScene3D scene = new RenderScene3D(state.screen_size, 1.81f * width, rect);

        scene.set_camera(camera);
        scene.add_light_source(light1);
        scene.add_light_source(light2);

        for (int i = 0; i < tiles.size; i++)
            tiles[i].render(scene);

        state.add_scene(scene);
    }
}
