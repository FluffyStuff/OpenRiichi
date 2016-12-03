using Gee;

class RenderSceneManager : Object
{
    private Options options;
    private int player_index;
    private Wind round_wind;
    private int dealer;
    private int wall_index;
    private RoundScoreState score;

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

    public RenderSceneManager(Options options, int player_index, Wind round_wind, int dealer, int wall_index, AudioPlayer audio, RoundScoreState score)
    {
        this.options = options;
        this.player_index = player_index;
        this.round_wind = round_wind;
        this.dealer = dealer;
        this.wall_index = wall_index;
        this.audio = audio;
        this.score = score;

        players = new RenderPlayer[4];
        tiles = new RenderTile[136];
        camera = new Camera();
    }

    public void added(ResourceStore store)
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

        int index = player_index == -1 ? 0 : player_index;

        float tile_scale = 1.74f;
        string extension = Options.quality_enum_to_string(options.model_quality);

        RenderGeometry3D tile = store.load_geometry_3D("tile_" + extension, false);
        tile_size = ((RenderBody3D)tile.geometry[0]).model.size;
        tile_size = Vec3(tile_size.x, tile_size.y + ((RenderBody3D)tile.geometry[1]).model.size.y, tile_size.z).mul_scalar(tile_scale);

        table = new RenderTable(store, extension, tile_size, round_wind, -(float)index / 2, score);

        table_length = table.player_offset;
        center = table.center;
        float wall_offset = (tile_size.x * 19 + tile_size.z) / 2;

        for (int i = 0; i < tiles.length; i++)
        {
            RenderTile t = new RenderTile(store, extension, options.tile_textures, new Tile(i, TileType.BLANK, false), tile_scale);
            t.front_color = options.tile_fore_color;
            t.back_color = options.tile_back_color;
            tiles[i] = t;
        }

        wall = new RenderWall(tiles, tile_size, center, wall_offset, dealer, wall_index);

        for (int i = 0; i < players.length; i++)
            players[i] = new RenderPlayer(store, center, i == dealer, i, table_length, wall_offset, tile_size, i == index, round_wind);

        observer = players[index];


        float camera_height = center.y + table_length * 1.8f;
        float camera_dist = table_length * 1.0f;
        camera.pitch = -0.366f;
        camera.focal_length = 0.77f;

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

    public void load_options(ResourceStore store, Options options)
    {
        this.options = options;

        string extension = Options.quality_enum_to_string(options.model_quality);

        foreach (RenderTile tile in tiles)
        {
            tile.reload(store, extension, options.tile_textures);
            tile.front_color = options.tile_fore_color;
            tile.back_color = options.tile_back_color;
        }
        table.reload(store, extension);
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
        else if (action is RenderActionReturnRiichi)
            action_return_riichi(action as RenderActionReturnRiichi);
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
        wall.flip_dora();
        wall.dead_tile_add();
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

        if (action.winners.length == 1 && action.tile != null)
            action.winners[0].ron(action.tile);

        bool flip_ura_dora = false;

        foreach (RenderPlayer player in action.winners)
        {
            if (!player.open)
                add_action(new RenderActionHandReveal(player));
            if (player.in_riichi)
                flip_ura_dora = true;
        }

        if (action.return_riichi_player != null)
            add_action(new RenderActionReturnRiichi(action.return_riichi_player));

        if (flip_ura_dora && action.allow_dora_flip)
            add_action(new RenderActionFlipUraDora());
    }

    private void action_tsumo(RenderActionTsumo action)
    {
        tsumo_sound.play();
        action.player.tsumo();

        if (!action.player.open)
            add_action(new RenderActionHandReveal(action.player));

        if (action.player.in_riichi)
            add_action(new RenderActionFlipUraDora());
    }

    private void action_riichi(RenderActionRiichi action)
    {
        riichi_sound.play();
        if (action.open)
            reveal_sound.play();

        action.player.riichi(action.open);
    }

    private void action_return_riichi(RenderActionReturnRiichi action)
    {
        action.player.return_riichi();
    }

    private void action_late_kan(RenderActionLateKan action)
    {
        action.player.late_kan(action.tile);
        kan_sound.play();
    }

    private void action_closed_kan(RenderActionClosedKan action)
    {
        action.player.closed_kan(action.tile_type);
        kan_sound.play();
    }

    private void action_open_kan(RenderActionOpenKan action)
    {
        action.discarder.rob_tile(action.tile);
        action.player.open_kan(action.discarder, action.tile, action.tile_1, action.tile_2, action.tile_3);
        kan_sound.play();
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
        bool revealed = false;

        foreach (RenderPlayer player in players)
        {
            if (action.players.contains(player))
            {
                if (!player.open)
                {
                    player.open_hand();
                    revealed = true;
                }
            }
            else if (player != observer && action.draw_type != GameDrawType.VOID_HAND)
            {
                player.close_hand();
                revealed = true;
            }
        }

        if (revealed)
            reveal_sound.play();
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

    private void position_lights(float rotation)
    {
        Vec3 pos;

        pos = Vec3(0, 50, table_length / 2);
        pos = Calculations.rotate_y(Vec3.empty(), rotation, pos);
        light1.position = pos;

        pos = Vec3(0, 50, table_length);
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
