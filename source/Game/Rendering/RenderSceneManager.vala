using Gee;

class RenderSceneManager : Object
{
    private string extension;
    private int player_index;
    private Wind round_wind;
    private int dealer;
    private int wall_index;

    private AudioPlayer audio;
    private Sound slide_sound;
    private Sound flip_sound;
    private Sound discard_sound;
    private Sound draw_sound;
    private Sound ron_sound;
    private Sound tsumo_sound;
    private Sound riichi_sound;
    private Sound kan_sound;
    private Sound pon_sound;
    private Sound chii_sound;
    private Sound reveal_sound;

    private float table_length;
    private Vec3 center;
    private Vec3 tile_size;
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();

    private RenderTable table;

    private Mutex action_lock;
    private ArrayList<RenderAction> actions = new ArrayList<RenderAction>();
    private RenderAction? current_action = null;
    private float action_start_time;

    public RenderSceneManager(string extension, int player_index, Wind round_wind, int dealer, int wall_index, AudioPlayer audio)
    {
        this.extension = extension;
        this.player_index = player_index;
        this.round_wind = round_wind;
        this.dealer = dealer;
        this.wall_index = wall_index;
        this.audio = audio;

        players = new RenderPlayer[4];
        tiles = new RenderTile[136];
        camera = new Camera();
    }

    public void added(IResourceStore store)
    {
        slide_sound = audio.load_sound("slide");
        flip_sound = audio.load_sound("flip");
        discard_sound = audio.load_sound("discard");
        draw_sound = audio.load_sound("draw");
        ron_sound = audio.load_sound("ron");
        tsumo_sound = audio.load_sound("tsumo");
        riichi_sound = audio.load_sound("riichi");
        kan_sound = audio.load_sound("kan");
        pon_sound = audio.load_sound("pon");
        chii_sound = audio.load_sound("chii");
        reveal_sound = audio.load_sound("reveal");

        float tile_scale = 1.6f;

        RenderModel tile = store.load_model("tile_" + extension, true);
        tile_size = tile.size.mul_scalar(tile_scale);

        table = new RenderTable(store, extension, tile_size);

        table_length = table.player_offset;
        center = table.center;
        float wall_offset = (tile_size.x * 19 + tile_size.z) / 2;

        for (int i = 0; i < tiles.length; i++)
            tiles[i] = new RenderTile(store, extension, new Tile(i, TileType.BLANK, false), tile_scale);

        wall = new RenderWall(tiles, tile_size, center, wall_offset, dealer, wall_index);

        for (int i = 0; i < players.length; i++)
            players[i] = new RenderPlayer(store, center, i == dealer, i, table_length, wall_offset, tile_size, i == player_index, round_wind);

        if (player_index != -1)
            observer = players[player_index];
        else
            observer = players[0];


        float camera_height = center.y + table_length * 1.3f;
        float camera_dist = table_length * 1.0f;
        camera.pitch = -0.34f;
        camera.focal_length = 0.9f;

        Vec3 pos = Vec3(0, camera_height, camera_dist);
        pos = Calculations.rotate_y({}, (float)observer.seat / 2, pos);
        camera.position = pos;
        camera.yaw = (float)observer.seat / 2;

        light1.color = Color.white();
        light1.intensity = 20;
        light2.color = Color.white();
        light2.intensity = 4;

        position_lights((float)observer.seat / 2);
    }

    public void process(DeltaArgs delta)
    {
        for (int i = 0; i < tiles.length; i++)
            tiles[i].process(delta);

        for (int i = 0; i < players.length; i++)
            players[i].process(delta);


        if (current_action != null &&
            delta.time - action_start_time > current_action.time)
            current_action = null;

        if (current_action == null)
        {
            lock (action_lock)
            {
                if (actions.size != 0)
                {
                    current_action = actions[0];
                    actions.remove_at(0);

                    action_start_time = delta.time;
                    do_action(current_action);
                }
            }
        }
    }

    public void render(RenderState state)
    {
        RenderScene3D scene = new RenderScene3D(state.screen_size, 1, Rectangle(0, 0, state.screen_size.width, state.screen_size.height));

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

    public void add_action(RenderAction action)
    {
        lock (action_lock)
            actions.add(action);
    }

    private void do_action(RenderAction action)
    {
        if (action is RenderActionSplitDeadWall)
            action_split_dead_wall(action as RenderActionSplitDeadWall);
        else if (action is RenderActionInitialDraw)
            action_initial_draw(action as RenderActionInitialDraw);
        else if (action is RenderActionDraw)
            action_draw(action as RenderActionDraw);
        else if (action is RenderActionDrawDeadWall)
            action_draw_dead_wall(action as RenderActionDrawDeadWall);
        else if (action is RenderActionDiscard)
            action_discard(action as RenderActionDiscard);
        else if (action is RenderActionRon)
            action_ron(action as RenderActionRon);
        else if (action is RenderActionTsumo)
            action_tsumo(action as RenderActionTsumo);
        else if (action is RenderActionRiichi)
            action_riichi(action as RenderActionRiichi);
        else if (action is RenderActionLateKan)
            action_late_kan(action as RenderActionLateKan);
        else if (action is RenderActionClosedKan)
            action_closed_kan(action as RenderActionClosedKan);
        else if (action is RenderActionOpenKan)
            action_open_kan(action as RenderActionOpenKan);
        else if (action is RenderActionPon)
            action_pon(action as RenderActionPon);
        else if (action is RenderActionChii)
            action_chii(action as RenderActionChii);
        else if (action is RenderActionGameDraw)
            action_game_draw(action as RenderActionGameDraw);
        else if (action is RenderActionHandReveal)
            action_hand_reveal(action as RenderActionHandReveal);
        else if (action is RenderActionFlipDora)
            action_flip_dora(action as RenderActionFlipDora);
        else if (action is RenderActionFlipUraDora)
            action_flip_ura_dora(action as RenderActionFlipUraDora);
        else if (action is RenderActionSetActive)
            action_set_active(action as RenderActionSetActive);
    }

    private void action_split_dead_wall(RenderActionSplitDeadWall action)
    {
        slide_sound.play();
        wall.split_dead_wall();
    }

    private void action_initial_draw(RenderActionInitialDraw action)
    {
        draw_sound.play();
        for (int i = 0; i < action.tiles; i++)
            action.player.draw_tile(wall.draw_wall());
    }

    private void action_draw(RenderActionDraw action)
    {
        draw_sound.play();
        action.player.draw_tile(wall.draw_wall());

        if (action.player.seat == player_index)
            active = true;
    }

    private void action_draw_dead_wall(RenderActionDrawDeadWall action)
    {
        draw_sound.play();
        action.player.draw_tile(wall.draw_dead_wall());

        if (action.player.seat == player_index)
            active = true;
    }

    private void action_discard(RenderActionDiscard action)
    {
        discard_sound.play();
        action.player.discard(action.tile);
    }

    private void action_ron(RenderActionRon action)
    {
        ron_sound.play();
        action.player.ron(action.tile);
        add_action(new RenderActionHandReveal(action.player));

        if (action.player.in_riichi)
            add_action(new RenderActionFlipUraDora());
    }

    private void action_tsumo(RenderActionTsumo action)
    {
        tsumo_sound.play();
        action.player.tsumo();
        add_action(new RenderActionHandReveal(action.player));

        if (action.player.in_riichi)
            add_action(new RenderActionFlipUraDora());
    }

    private void action_riichi(RenderActionRiichi action)
    {
        riichi_sound.play();
        action.player.riichi();
    }

    private void action_late_kan(RenderActionLateKan action)
    {
        action.player.late_kan(action.tile);
        kan(action.player);
    }

    private void action_closed_kan(RenderActionClosedKan action)
    {
        action.player.closed_kan(action.tile_type);
        kan(action.player);
    }

    private void action_open_kan(RenderActionOpenKan action)
    {
        action.discarder.rob_tile(action.tile);
        action.player.open_kan(action.discarder, action.tile, action.tile_1, action.tile_2, action.tile_3);
        kan(action.player);
    }

    private void action_pon(RenderActionPon action)
    {
        pon_sound.play();
        action.discarder.rob_tile(action.tile);
        action.player.pon(action.discarder, action.tile, action.tile_1, action.tile_2);

        if (action.player.seat == player_index)
            active = true;
    }

    private void action_chii(RenderActionChii action)
    {
        chii_sound.play();
        action.discarder.rob_tile(action.tile);
        action.player.chii(action.discarder, action.tile, action.tile_1, action.tile_2);

        if (action.player.seat == player_index)
            active = true;
    }

    private void action_game_draw(RenderActionGameDraw action)
    {
        reveal_sound.play();

        foreach (RenderPlayer player in players)
        {
            if (action.players.contains(player))
                player.open_hand();
            else if (player != observer)
                player.close_hand();
        }
    }

    private void action_hand_reveal(RenderActionHandReveal action)
    {
        reveal_sound.play();
        action.player.open_hand();
    }

    private void action_flip_dora(RenderActionFlipDora action)
    {
        flip_sound.play();
        wall.flip_dora();
    }

    private void action_flip_ura_dora(RenderActionFlipUraDora action)
    {
        flip_sound.play();
        wall.flip_ura_dora();
    }

    private void action_set_active(RenderActionSetActive action)
    {
        active = action.active;
    }

    private void kan(RenderPlayer player)
    {
        kan_sound.play();
        wall.flip_dora();
        wall.dead_tile_add();
        player.draw_tile(wall.draw_dead_wall());

        if (player.seat == player_index)
            active = true;
    }

    private void position_lights(float rotation)
    {
        Vec3 pos;

        pos = Vec3(0, 45, table_length / 2);
        pos = Calculations.rotate_y(Vec3.empty(), rotation, pos);
        light1.position = pos;

        pos = Vec3(0, 45, table_length);
        pos = Calculations.rotate_y(Vec3.empty(), rotation, pos);
        light2.position = pos;
    }

    public RenderPlayer[] players { get; private set; }
    public RenderTile[] tiles { get; private set; }
    public RenderWall wall { get; private set; }
    public RenderPlayer observer { get; private set; }
    public Camera camera { get; private set; }
    public bool active { get; set; }
}
