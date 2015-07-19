using GL;
using Gee;

public class GameRenderView : View, IGameRenderer
{
    private GameStartState start_state;

    private Camera camera = new Camera();
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();

    private RenderTable table;
    private RenderWall wall;
    private RenderPlayer players[4];
    private RenderPlayer observer;
    private RenderTile tiles[136];

    private ServerMessageParser parser = new ServerMessageParser();
    private RenderTile? mouse_down_tile;
    private ArrayList<TileSelectionGroup>? select_groups = null;

    public GameRenderView(GameStartState state)
    {
        start_state = state;

        parser.connect(server_tile_assignment, typeof(ServerMessageTileAssignment));
        parser.connect(server_tile_draw, typeof(ServerMessageTileDraw));
        parser.connect(server_tile_discard, typeof(ServerMessageTileDiscard));
        parser.connect(server_flip_dora, typeof(ServerMessageFlipDora));
        parser.connect(server_dead_tile_add, typeof(ServerMessageDeadTileAdd));

        parser.connect(server_ron, typeof(ServerMessageRon));
        parser.connect(server_late_kan, typeof(ServerMessageLateKan));
        parser.connect(server_closed_kan, typeof(ServerMessageClosedKan));
        parser.connect(server_open_kan, typeof(ServerMessageOpenKan));
        parser.connect(server_pon, typeof(ServerMessagePon));
        parser.connect(server_chi, typeof(ServerMessageChi));
    }

    private void server_tile_assignment(ServerMessage message)
    {
        ServerMessageTileAssignment tile_assignment = (ServerMessageTileAssignment)message;
        tiles[tile_assignment.tile_ID].assign_type(tile_assignment.get_tile(), store);
    }

    private void server_tile_draw(ServerMessage message)
    {
        ServerMessageTileDraw tile_draw = (ServerMessageTileDraw)message;
        RenderPlayer player = players[tile_draw.player_ID];

        if (tile_draw.dead_wall)
            player.add_to_hand(wall.draw_dead_wall());
        else
            player.add_to_hand(wall.draw_wall());
    }

    private void server_tile_discard(ServerMessage message)
    {
        ServerMessageTileDiscard tile_discard = (ServerMessageTileDiscard)message;
        RenderPlayer player = players[tile_discard.player_ID];
        RenderTile tile = tiles[tile_discard.tile_ID];
        player.discard(tile);
    }

    private void server_flip_dora(ServerMessage message)
    {
        wall.flip_dora();
    }

    private void server_dead_tile_add(ServerMessage message)
    {
        wall.dead_tile_add();
    }

    private void server_ron(ServerMessage message)
    {
        ServerMessageRon ron = (ServerMessageRon)message;
    }

    private void server_late_kan(ServerMessage message)
    {
        ServerMessageLateKan kan = (ServerMessageLateKan)message;
        RenderPlayer player = players[kan.player_ID];
        RenderTile tile = tiles[kan.tile_ID];
        player.late_kan(tile);
    }

    private void server_closed_kan(ServerMessage message)
    {
        ServerMessageClosedKan kan = (ServerMessageClosedKan)message;
        RenderPlayer player = players[kan.player_ID];
        player.closed_kan(kan.get_type_enum());
    }

    private void server_open_kan(ServerMessage message)
    {
        ServerMessageOpenKan kan = (ServerMessageOpenKan)message;
        RenderPlayer player = players[kan.player_ID];
        RenderPlayer discard_player = players[kan.discard_player_ID];

        RenderTile tile = tiles[kan.tile_ID];
        RenderTile tile_1 = tiles[kan.tile_1_ID];
        RenderTile tile_2 = tiles[kan.tile_2_ID];
        RenderTile tile_3 = tiles[kan.tile_3_ID];

        discard_player.rob_tile(tile);
        player.open_kan(discard_player, tile, tile_1, tile_2, tile_3);
    }

    private void server_pon(ServerMessage message)
    {
        ServerMessagePon pon = (ServerMessagePon)message;
        RenderPlayer player = players[pon.player_ID];
        RenderPlayer discard_player = players[pon.discard_player_ID];

        RenderTile tile   = tiles[pon.tile_ID];
        RenderTile tile_1 = tiles[pon.tile_1_ID];
        RenderTile tile_2 = tiles[pon.tile_2_ID];

        discard_player.rob_tile(tile);
        player.pon(discard_player, tile, tile_1, tile_2);
    }

    private void server_chi(ServerMessage message)
    {
        ServerMessageChi chi = (ServerMessageChi)message;
        RenderPlayer player = players[chi.player_ID];
        RenderPlayer discard_player = players[chi.discard_player_ID];

        RenderTile tile   = tiles[chi.tile_ID];
        RenderTile tile_1 = tiles[chi.tile_1_ID];
        RenderTile tile_2 = tiles[chi.tile_2_ID];

        discard_player.rob_tile(tile);
        player.chi(discard_player, tile, tile_1, tile_2);
    }

    /////////////////////

    public void receive_message(ServerMessage message)
    {
        parser.add(message);
    }

    public override void added()
    {
        float tile_scale = 1.20f;
        //parent_window.set_cursor_hidden(true);

        RenderModel tile = store.load_model("tile", true);
        Vec3 tile_size = tile.size.mul_scalar(tile_scale);

        table = new RenderTable(store, tile_size);

        float player_offset = table.player_offset;
        float wall_offset = (tile_size.x * 19 + tile_size.z) / 2;

        for (int i = 0; i < tiles.length; i++)
            tiles[i] = new RenderTile(store, new Tile(i, TileType.BLANK, false), tile_scale);

        wall = new RenderWall(tiles, tile_size, table.center, wall_offset, start_state.dealer, start_state.wall_index);

        for (int i = 0; i < players.length; i++)
            players[i] = new RenderPlayer(table.center, i, player_offset, wall_offset, tile_size);

        if (start_state.player_ID != -1)
            observer = players[start_state.player_ID];
        else
            observer = players[0];


        float camera_height = table.center.y + player_offset;
        float camera_dist = player_offset * 1.5f;
        camera.pitch = -0.25f;
        camera.focal_length = 0.9f;

        Vec3 pos = { 0, camera_height, camera_dist};
        pos = Calculations.rotate_y({}, (float)observer.seat / 2, pos);
        camera.position = pos;
        camera.yaw = (float)observer.seat / 2;

        light1.color = Vec3() { x = 1, y = 1, z = 1 };
        light1.intensity = 20;

        pos = Vec3() { x = 0, y = 45, z = camera_dist / 3 };
        pos = Calculations.rotate_y({}, (float)observer.seat / 2, pos);
        light1.position = pos;

        light2.color = Vec3() { x = 1, y = 1, z = 1 };
        light2.intensity = 4;
    }

    private int last_x = 0;
    private int last_y = 0;

    private float accel_x = 0;
    private float accel_y = 0;
    private float accel_z = 0;

    public override void do_process(DeltaArgs delta)
    {
        parser.dequeue();

        Vec3 pos = camera.position;
        pos = pos.plus({accel_x, accel_y, accel_z});

        //camera.position = pos;
        light2.position = camera.position;
    }

    //private float bloom_intensity = 0.2f;
    //private float perlin_strength = 0;//0.25f;
    public override void do_render(RenderState state)
    {
        RenderScene3D scene = new RenderScene3D(state.screen_width, state.screen_height);

        scene.set_camera(camera);
        scene.add_light_source(light1);
        scene.add_light_source(light2);

        table.render(scene);
        for (int i = 0; i < tiles.length; i++)
            tiles[i].render(scene);

        state.add_scene(scene);

        //scene.bloom = bloom_intensity;
        //scene.perlin_strength = perlin_strength;
    }

    protected override void do_mouse_move(MouseMoveArgs mouse)
    {
        last_x = mouse.pos_x;
        last_y = mouse.pos_y;

        /*
        Vec3 dir = Calculations.rotate_z({}, -camera.roll, {last_x, last_y, 0});
        int slow = 300;
        camera.yaw   = -dir.x / slow;
        camera.pitch = -dir.y / slow;
        //*/

        for (int i = 0; i < tiles.length; i++)
            tiles[i].set_hovered(false);

        RenderTile? tile = null;
        if (!mouse.handled && active)
            tile = get_hover_tile();

        bool hovered = false;

        if (tile != null)
        {
            if (select_groups == null)
            {
                tile.set_hovered(true);
                hovered = true;
            }
            else
            {
                TileSelectionGroup? group = get_tile_selection_group(tile);

                if (group != null)
                {
                    foreach (Tile t in group.highlight_tiles)
                        tiles[t.ID].set_hovered(true);

                    hovered = true;
                }
            }
        }

        if (hovered)
        {
            mouse.cursor_type = CursorType.HOVER;
            mouse.handled = true;
        }
    }

    private TileSelectionGroup? get_tile_selection_group(RenderTile? tile)
    {
        if (tile == null || select_groups == null)
            return null;

        foreach (TileSelectionGroup group in select_groups)
            foreach (Tile t in group.selection_tiles)
                if (t.ID == tile.tile_type.ID)
                    return group;

        return null;
    }

    protected override void do_mouse_event(MouseEventArgs mouse)
    {
        if (!active)
        {
            mouse_down_tile = null;
            return;
        }

        if (mouse.button == MouseEventArgs.Button.LEFT)
        {
            if (mouse.down)
            {
                RenderTile? tile = get_hover_tile();
                if (select_groups != null && get_tile_selection_group(tile) == null)
                    tile = null;

                mouse_down_tile = tile;
            }
            else
            {
                RenderTile? tile = get_hover_tile();
                if (select_groups != null && get_tile_selection_group(tile) == null)
                    tile = null;

                if (tile != null && tile == mouse_down_tile)
                    tile_selected(tile.tile_type);

                mouse_down_tile = null;
            }
        }
    }

    private RenderTile get_hover_tile()
    {
        float width = parent_window.width;
        float height = parent_window.height;
        float aspect_ratio = width / height;
        float focal_length = camera.focal_length;
        Mat4 projection_matrix = parent_window.renderer.get_projection_matrix(focal_length, aspect_ratio);
        Mat4 view_matrix = camera.get_view_transform(false);
        Vec3 ray = Calculations.get_ray(projection_matrix, view_matrix, last_x, last_y, width, height);

        // TODO: Change
        ArrayList<RenderTile> tiles = observer.hand_tiles;

        float shortest = 0;
        RenderTile? shortest_tile = null;

        for (int i = 0; i < tiles.size; i++)
        {
            RenderTile tile = tiles.get(i);
            float collision_distance = Calculations.get_collision_distance(tile.tile, camera.position, ray);

            if (collision_distance >= 0)
                if (shortest_tile == null || collision_distance < shortest)
                {
                    shortest = collision_distance;
                    shortest_tile = tile;
                }
        }

        return shortest_tile;
    }

    protected override void do_key_press(KeyArgs key)
    {
        float speed = 0.001f;

        float yaw   = camera.yaw   * (float)Math.PI;
        float pitch = camera.pitch * (float)Math.PI;

        switch (key.key)
        {
            //case 27 :
            //case 'q':
        case ' ':
            accel_y += speed;
            break;
        case 'c':
            accel_y -= speed;
            break;
        case 'w':
            accel_z -= (float)Math.cos(yaw) * (float)Math.cos(pitch) * speed;
            accel_x -= (float)Math.sin(yaw) * (float)Math.cos(pitch) * speed;
            accel_y += (float)Math.sin(pitch) * speed;
            break;
        case 's':
            accel_z += (float)Math.cos(yaw) * (float)Math.cos(pitch) * speed;
            accel_x += (float)Math.sin(yaw) * (float)Math.cos(pitch) * speed;
            accel_y -= (float)Math.sin(pitch) * speed;
            break;
        case 'a':
            accel_z += (float)Math.sin(yaw) * speed;
            accel_x -= (float)Math.cos(yaw) * speed;
            break;
        case 'd':
            accel_z -= (float)Math.sin(yaw) * speed;
            accel_x += (float)Math.cos(yaw) * speed;
            break;
        case 'x':
            accel_x = 0;
            accel_y = 0;
            accel_z = 0;
            break;
        case 86:
            camera.focal_length -= 0.1f;
            break;
        case 87:
            camera.focal_length += 0.1f;
            break;
        case 118:
            parent_window.renderer.v_sync = !parent_window.renderer.v_sync;
            print("V-Sync is now %s\n", parent_window.renderer.v_sync ? "enabled" : "disabled");
            break;
        default:
            print("%i\n", (int)key.key);
            break;
        }
    }

    public void set_active(bool active)
    {
        this.active = active;
    }

    public void set_tile_select_groups(ArrayList<TileSelectionGroup>? groups)
    {
        select_groups = groups;
    }

    public bool active { get; set; }
}
