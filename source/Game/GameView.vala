using GL;

public class GameView : View
{
    private float rotation = 0;

    private Render3DObject? tile = null;
    private Render3DObject? table = null;
    private Render3DObject? field = null;
    private LightSource light = new LightSource();

    public GameView()
    {
    }

    public override void do_load_resources(IResourceStore store)
    {
        table = store.load_3D_object("./Data/models/table");
        tile = store.load_3D_object("./Data/models/box");
        field = store.load_3D_object("./Data/models/field");
        parent_window.set_cursor_hidden(true);

        table.position = Vec3() { y = -0.163f };
        table.scale = Vec3() { x = 10, y = 10, z = 10 };
        tile.position = Vec3() { y = 12.5f };
        tile.scale = Vec3() { x = 1.0f, y = 1.0f, z = 1.0f };
        field.position = Vec3() { y = 12.4f };
        field.scale = Vec3() { x = 9.6f, y = 1, z = 9.6f };

        light.color = Vec3() { x = 1, y = 1, z = 1 };
        light.intensity = 3;
        light.position = Vec3() { x = 0, y = 30, z = 0 };
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
        int slow = 300;
        camera_x += accel_x;
        camera_y += accel_y;
        camera_z += accel_z;
        light.position = Vec3() { x = 0, y = 20, z = 0 };
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
        state.add_3D_object(tile);
        state.add_3D_object(table);
        state.add_3D_object(field);
        state.add_light_source(light);
        //state.finish_scene();

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
