using GL;

public class GameView : View
{
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();
    private RenderTable table;
    private RenderPlayer players[4];
    private RenderTile tiles[136];

    public GameView()
    {
    }

    public override void do_load_resources(IResourceStore store)
    {
        parent_window.set_cursor_hidden(true);

        table = new RenderTable(store);

        for (int i = 0; i < tiles.length; i++)
            tiles[i] = new RenderTile(store);

        for (int i = 0; i < players.length; i++)
            players[i] = new RenderPlayer(table.center, 0, table.player_offset, 0);

        for (int i = 0; i < 13; i++)
            players[0].add_to_hand(tiles[i]);

        light1.color = Vec3() { x = 1, y = 1, z = 1 };
        light1.intensity = 5;
        light1.position = Vec3() { x = 0, y = 30, z = 0 };

        light2.color = Vec3() { x = 1, y = 1, z = 1 };
        light2.intensity = 20;
        light2.position = Vec3() { x = 0, y = 30, z = -50 };
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

    public override void do_process(double dt)
    {
        derp += dt;
        camera_x += accel_x;
        camera_y += accel_y;
        camera_z += accel_z;
        //light.color = Vec3() { x = 0.0f, y = 1, z = 0.0f };
        //rotation += (float)dt * 0.02f;
        //tile.rotation = Vec3() { x = (float)last_y / slow + rotation * 0.25f, y = (float)last_x / (float)slow + (float)rotation, z = rotation * 0.1f };
        //table.rotation = Vec3() { x = (float)last_y / slow + rotation * 0.25f, y = (float)last_x / (float)slow + (float)rotation, z = rotation * 0.1f };
        //table.rotation = Vec3() { x = rotation * 0.25f, y = rotation, z = rotation * 0.1f };
        //tile.rotation = Vec3() { x = rotation * 0.25f, y = rotation, z = rotation * 0.1f };

        //tile.position = Vec3() { y = -0.5f, z = 2.5f };
    }

    private float bloom_intensity = 0.2f;
    private float perlin_strength = 0.25f;
    public override void do_render(RenderState state, IResourceStore store)
    {
        //state.add_scene();
        int slow = 300;
        state.camera_rotation = Vec3(){ x = 1 - (float)last_y / slow, y = - (float)last_x / slow };
        state.camera_position = Vec3(){ x = camera_x, y = camera_y, z = camera_z };
        state.add_light_source(light1);
        state.add_light_source(light2);

        table.render(state, store);
        for (int i = 0; i < tiles.length; i++)
            tiles[i].render(state);

        state.bloom = bloom_intensity;
        state.perlin_strength = perlin_strength;
    }

    protected override void do_mouse_move(int x, int y)
    {
        last_x += x;
        last_y += y;
        //int slow = 300;
        //tile.rotation = Vec3() { x = (float)y / slow + rotation * 0.25f, y = (float)x / slow + rotation, z = rotation * 0.1f };
        //table.rotation = Vec3() { x = (float)y / slow, y = (float)x / slow };
    }

    protected override void do_key_press(char key)
    {
        int slow = 300;
        float speed = 0.001f;

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
            accel_z += (float)Math.cos((float)last_x / slow * Math.PI) * (float)Math.cos((float)last_y / slow * Math.PI) * speed;
            accel_x += (float)Math.sin((float)last_x / slow * Math.PI) * (float)Math.cos((float)last_y / slow * Math.PI) * speed;
            accel_y += (float)Math.sin((float)last_y / slow * Math.PI) * speed;
            break;
        case 's':
            accel_z -= (float)Math.cos((float)last_x / slow * Math.PI) * (float)Math.cos((float)last_y / slow * Math.PI) * speed;
            accel_x -= (float)Math.sin((float)last_x / slow * Math.PI) * (float)Math.cos((float)last_y / slow * Math.PI) * speed;
            accel_y -= (float)Math.sin((float)last_y / slow * Math.PI) * speed;
            break;
        case 'a':
            accel_z -= (float)Math.sin((float)last_x / slow * Math.PI) * speed;
            accel_x += (float)Math.cos((float)last_x / slow * Math.PI) * speed;
            break;
        case 'd':
            accel_z += (float)Math.sin((float)last_x / slow * Math.PI) * speed;
            accel_x -= (float)Math.cos((float)last_x / slow * Math.PI) * speed;
            break;
        case 'x':
            accel_x = 0;
            accel_y = 0;
            accel_z = 0;
            break;
        default:
            print("%i\n", (int)key);
            break;
        }
    }
}
