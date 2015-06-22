using GL;
using Gee;

public class GameView : View
{
    private Camera camera = new Camera();
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();

    private RenderTile width_collision;
    private RenderTile height_collision;

    private RenderTable table;
    private RenderWall wall;
    private RenderPlayer players[4];
    private RenderTile tiles[136];

    public GameView()
    {
    }

    public override void do_load_resources(IResourceStore store)
    {
        //parent_window.set_cursor_hidden(true);

        // TODO: Only load model
        Render3DObject tile = store.load_3D_object("./Data/models/box");
        Vec3 tile_size = tile.object_size;

        table = new RenderTable(store, 0);

        float scale = 0.3f;
        width_collision = new RenderTile(store);
        width_collision.tile.scale = { scale, scale, scale };
        height_collision = new RenderTile(store);
        height_collision.tile.scale = { scale, scale, scale };

        for (int i = 0; i < tiles.length; i++)
            tiles[i] = new RenderTile(store);

        wall = new RenderWall(tiles, tile_size, table.center, table.wall_offset, 0, 7);

        for (int i = 0; i < players.length; i++)
            players[i] = new RenderPlayer(table.center, i, table.player_offset, 0, tile_size);

        for (int i = 0; i < 8; i++)
            for (int j = 0; j < 4; j++)
                players[i%4].add_to_hand(wall.draw_wall());
        for (int i = 0; i < 3; i++)
            players[i].add_to_hand(wall.draw_wall());

        light1.color = Vec3() { x = 1, y = 1, z = 1 };
        light1.intensity = 5;
        light1.position = Vec3() { x = 0, y = 30, z = 0 };

        light2.color = Vec3() { x = 1, y = 1, z = 1 };
        light2.intensity = 20;
        light2.position = Vec3() { x = 0, y = 30, z = -50 };

        rot = {};
    }

    private int last_x = 0;
    private int last_y = 0;

    private float accel_x = 0;
    private float accel_y = 0;
    private float accel_z = 0;
    private float camera_x = 0;
    private float camera_y = 0;
    private float camera_z = 0;

    private double derp = 0;
    private Vec3 rot;

    public override void do_process(double dt)
    {
        derp += dt;
        camera_x += accel_x;
        camera_y += accel_y;
        camera_z += accel_z;

        int slow = 300;
        /*camera.pitch = (float)last_y / slow;
        camera.yaw = (float)last_x / slow;*/
        camera.position = Vec3(){ x = camera_x, y = camera_y, z = camera_z };

        ArrayList<RenderTile> tiles = players[1].hand_tiles;

        for (int i = 0; i < tiles.size; i++)
            tiles[i].set_hovered(i == (int)derp % tiles.size);

        tiles = players[0].hand_tiles;
        tiles[0].rotation = rot;

        do_mouse_check();
    }

    private float bloom_intensity = 0.0f;
    private float perlin_strength = 0;//0.25f;
    public override void do_render(RenderState state, IResourceStore store)
    {
        state.set_camera(camera);
        state.add_light_source(light1);
        state.add_light_source(light2);
        state.add_3D_object(width_collision.tile);
        state.add_3D_object(height_collision.tile);

        table.render(state, store);
        for (int i = 0; i < tiles.length; i++)
            tiles[i].render(state);

        state.bloom = bloom_intensity;
        state.perlin_strength = perlin_strength;
    }

    protected override void do_mouse_move(int x, int y)
    {
        int slow = 300;
        last_x += x;
        last_y += y;

        Vec3 dir = Calculations.rotate_z({}, -camera.roll, {x,y,0});

        camera.yaw   += dir.x / slow;
        camera.pitch += dir.y / slow;
    }

    private void do_mouse_check()
    {
        float width = parent_window.width;
        float height = parent_window.height;
        float focal_length = camera.focal_length;
        float aspect_ratio = width / height;
        Mat4 projection_matrix = parent_window.renderer.get_projection_matrix(focal_length, aspect_ratio);
        Mat4 view_matrix = camera.get_view_transform(false);

        Vec3 ray = Calculations.get_ray(projection_matrix, view_matrix, last_x, last_y, width, height);

        // TODO: Change
        ArrayList<RenderTile> tiles = players[0].hand_tiles;

        for (int i = 0; i < tiles.size; i++)
        {
            RenderTile tile = tiles.get(i);
            Vec3 point = tile.position;
            //float collision_distance = Calculations.get_collision_distance(tile.tile, camera.position, ray);
            Vec3 collision_distance = Calculations.get_collision_distance(tile.tile, camera.position, ray, true);
            width_collision.position = collision_distance;
            collision_distance = Calculations.get_collision_distance(tile.tile, camera.position, ray, false);
            height_collision.position = collision_distance;
            //print("Dist: %f\n", collision_distance);
            break;
        }
    }

    protected override void do_key_press(char key)
    {
        float speed = 0.001f;

        float yaw   = camera.yaw   * (float)Math.PI;
        float pitch = camera.pitch * (float)Math.PI;

        switch (key)
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
            accel_z += (float)Math.cos(yaw) * (float)Math.cos(pitch) * speed;
            accel_x += (float)Math.sin(yaw) * (float)Math.cos(pitch) * speed;
            accel_y -= (float)Math.sin(pitch) * speed;
            break;
        case 's':
            accel_z -= (float)Math.cos(yaw) * (float)Math.cos(pitch) * speed;
            accel_x -= (float)Math.sin(yaw) * (float)Math.cos(pitch) * speed;
            accel_y += (float)Math.sin(pitch) * speed;
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
        case 89:
            rot.x += 0.1f;
            break;
        case 90:
            rot.x -= 0.1f;
            break;
        case 92:
            rot.y += 0.1f;
            break;
        case 93:
            rot.y -= 0.1f;
            break;
        case 95:
            rot.z += 0.1f;
            break;
        case 96:
            rot.z -= 0.1f;
            break;
        default:
            print("%i\n", (int)key);
            break;
        }
    }
}
