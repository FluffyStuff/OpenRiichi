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

    public GameRenderView(GameStartState state)
    {
        start_state = state;

        parser.tile_assignment.connect(tile_assignment);
        parser.tile_draw.connect(tile_draw);
        parser.tile_discard.connect(tile_discard);
        parser.flip_dora.connect(flip_dora);
    }

    private void tile_assignment(ServerMessageTileAssignment message)
    {
        tiles[message.tile_ID].assign_type(message.get_tile(), store);
    }

    private void tile_draw(ServerMessageTileDraw message)
    {
        RenderPlayer player = players[message.player_ID];
        player.add_to_hand(wall.draw_wall());
        player.order_tiles();
    }

    private void tile_discard(ServerMessageTileDiscard message)
    {
        RenderPlayer player = players[message.player_ID];
        RenderTile tile = tiles[message.tile_ID];
        player.discard(tile);
    }

    private void flip_dora(ServerMessageFlipDora message)
    {
        wall.flip_dora();
    }

    public void receive_message(ServerMessage message)
    {
        parser.add(message);
    }

    public override void added()
    {
        //parent_window.set_cursor_hidden(true);

        RenderModel tile = store.load_model("tile", true);
        Vec3 tile_size = tile.size;

        table = new RenderTable(store);

        for (int i = 0; i < tiles.length; i++)
            tiles[i] = new RenderTile(store, new Tile(i, TileType.BLANK, false));

        wall = new RenderWall(tiles, tile_size, table.center, table.wall_offset, start_state.dealer, start_state.wall_index);

        for (int i = 0; i < players.length; i++)
            players[i] = new RenderPlayer(table.center, i, table.player_offset, table.wall_offset, tile_size);

        if (start_state.player_ID != -1)
            observer = players[start_state.player_ID];
        else
            observer = players[0];

        Vec3 pos = Vec3() { y = table.center.y + table.wall_offset };
        pos = Calculations.vec3_plus(Calculations.rotate_y({}, (float)observer.seat / 2, {0,0,table.player_offset * 1.3f}), pos);
        camera.position = pos;
        camera.pitch = -0.1f;
        camera.yaw = (float)observer.seat / 2;

        light1.color = Vec3() { x = 1, y = 1, z = 1 };
        light1.intensity = 10;
        light1.position = Vec3() { x = 0, y = 30, z = 0 };

        light2.color = Vec3() { x = 1, y = 1, z = 1 };
        light2.intensity = 3;
    }

    private int last_x = 0;
    private int last_y = 0;

    private float accel_x = 0;
    private float accel_y = 0;
    private float accel_z = 0;
    private float camera_x = 0;
    private float camera_y = 0;
    private float camera_z = 0;

    public override void do_process(DeltaArgs delta)
    {
        parser.dequeue();

        camera_x += accel_x;
        camera_y += accel_y;
        camera_z += accel_z;

        //camera.position = Vec3(){ x = camera_x, y = camera_y, z = camera_z };
        light2.position = camera.position;

        RenderTile? tile = get_hover_tile();
        parent_window.set_cursor_type((tile != null) ? CursorType.HOVER : CursorType.NORMAL);

        for (int i = 0; i < tiles.length; i++)
        {
            RenderTile t = tiles[i];
            t.set_hovered(t == tile);
        }
    }

    private float bloom_intensity = 0.2f;
    private float perlin_strength = 0;//0.25f;
    public override void do_render(RenderState state)
    {
        state.set_camera(camera);
        state.add_light_source(light1);
        state.add_light_source(light2);

        table.render(state);
        for (int i = 0; i < tiles.length; i++)
            tiles[i].render(state);

        state.bloom = bloom_intensity;
        state.perlin_strength = perlin_strength;
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
    }

    protected override void do_mouse_event(MouseEventArgs mouse)
    {
        if (mouse.button == MouseEventArgs.Button.LEFT)
        {
            if (mouse.down)
                mouse_down_tile = get_hover_tile();
            else
            {
                RenderTile? tile = get_hover_tile();

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
            print("Z: %f\n", camera.roll);
            camera.roll += 0.1f;
            break;
        case 87:
            print("Z: %f\n", camera.roll);
            camera.roll -= 0.1f;
            break;
        default:
            print("%i\n", (int)key.key);
            break;
        }
    }

    public void set_active(bool active)
    {

    }
}
