using Gee;

class RenderSceneManager
{
    private int player_ID;
    private Wind round_wind;
    private int dealer;
    private int wall_index;

    private float table_length;
    private Vec3 center;
    private Vec3 tile_size;
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();

    private RenderTable table;

    private bool end_animation = false;
    private bool end_animation_started = false;
    private float end_animation_start_time;

    private ArrayList<RenderPlayer> open_hands = new ArrayList<RenderPlayer>();
    private ArrayList<RenderPlayer> closed_hands = new ArrayList<RenderPlayer>();
    private bool flip_dora = false;

    public RenderSceneManager(int player_ID, Wind round_wind, int dealer, int wall_index)
    {
        this.player_ID = player_ID;
        this.round_wind = round_wind;
        this.dealer = dealer;
        this.wall_index = wall_index;

        players = new RenderPlayer[4];
        tiles = new RenderTile[136];
        camera = new Camera();
    }

    public void added(IResourceStore store)
    {
        float tile_scale = 1.6f;

        RenderModel tile = store.load_model("tile", true);
        tile_size = tile.size.mul_scalar(tile_scale);

        table = new RenderTable(store, tile_size);

        table_length = table.player_offset;
        center = table.center;
        float wall_offset = (tile_size.x * 19 + tile_size.z) / 2;

        for (int i = 0; i < tiles.length; i++)
            tiles[i] = new RenderTile(store, new Tile(i, TileType.BLANK, false), tile_scale);

        wall = new RenderWall(tiles, tile_size, center, wall_offset, dealer, wall_index);

        for (int i = 0; i < players.length; i++)
            players[i] = new RenderPlayer(store, center, i, table_length, wall_offset, tile_size, i == player_ID);

        if (player_ID != -1)
            observer = players[player_ID];
        else
            observer = players[0];


        float camera_height = center.y + table_length * 1.3f;
        float camera_dist = table_length * 1.0f;
        camera.pitch = -0.34f;
        camera.focal_length = 0.9f;

        Vec3 pos = { 0, camera_height, camera_dist};
        pos = Calculations.rotate_y({}, (float)observer.seat / 2, pos);
        camera.position = pos;
        camera.yaw = (float)observer.seat / 2;

        light1.color = Vec3() { x = 1, y = 1, z = 1 };
        light1.intensity = 20;
        light2.color = Vec3() { x = 1, y = 1, z = 1 };
        light2.intensity = 4;

        position_lights((float)observer.seat / 2);
    }

    public void process(DeltaArgs delta)
    {
        if (end_animation)
            process_end_animation(delta);

        for (int i = 0; i < tiles.length; i++)
            tiles[i].process(delta);

        for (int i = 0; i < players.length; i++)
            players[i].process(delta);
    }

    public void render(RenderState state)
    {
        RenderScene3D scene = new RenderScene3D(state.screen_width, state.screen_height);

        scene.set_camera(camera);
        scene.add_light_source(light1);
        scene.add_light_source(light2);

        table.render(scene);

        for (int i = 0; i < tiles.length; i++)
            tiles[i].render(scene);

        for (int i = 0; i < players.length; i++)
            players[i].render(scene);

        state.add_scene(scene);
    }

    public void ron(RenderPlayer player, RenderTile tile)
    {
        player.ron(tile);
        open_hands.add(player);
        flip_dora = player.in_riichi;
        end_animation = true;
    }

    public void tsumo(RenderPlayer player)
    {
        player.tsumo();
        open_hands.add(player);
        flip_dora = player.in_riichi;
        end_animation = true;
    }

    public void draw(ArrayList<RenderPlayer> tenpai_players)
    {
        foreach (RenderPlayer player in players)
        {
            if (tenpai_players.contains(player))
                open_hands.add(player);
            else if (player != observer)
                closed_hands.add(player);
        }

        end_animation = true;
    }

    private void process_end_animation(DeltaArgs delta)
    {
        if (!end_animation_started)
        {
            end_animation_start_time = delta.time + 1.0f;
            end_animation_started = true;
        }

        if (delta.time < end_animation_start_time)
            return;

        end_animation = false;

        foreach (RenderPlayer player in open_hands)
            player.open_hand();
        foreach (RenderPlayer player in closed_hands)
            player.close_hand();

        if (flip_dora)
            wall.flip_ura_dora();
    }

    private void position_lights(float rotation)
    {
        Vec3 pos;

        pos = Vec3() { x = 0, y = 45, z = table_length / 2 };
        pos = Calculations.rotate_y({}, rotation, pos);
        light1.position = pos;

        pos = Vec3() { x = 0, y = 45, z = table_length };
        pos = Calculations.rotate_y({}, rotation, pos);
        light2.position = pos;
    }

    public RenderPlayer[] players { get; private set; }
    public RenderTile[] tiles { get; private set; }
    public RenderWall wall { get; private set; }
    public RenderPlayer observer { get; private set; }
    public Camera camera { get; private set; }
}
