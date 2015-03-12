using GL;

public class GameView : View
{
    //private float rotation = 0;

    private Render3DObject? sky = null;
    private Render3DObject? level = null;
    /*private LightSource? light = null;
    private Render3DObject? tile = null;
    private LightSource? light2 = null;
    private Render3DObject? tile2 = null;*/

    private Circler[] circlers;
    //private Render3DObject? table = null;
    //private Render3DObject? field = null;

    private class Circler
    {
        public Circler(Vec3 amount, bool[] cos, IResourceStore store)
        {
            this.amount = amount;
            this.cos = cos;
            light = new LightSource();
            obj = store.load_3D_object("./3d/box");
        }

        public Vec3 amount { get; private set; }
        public bool[] cos { get; private set; }
        public LightSource light { get; private set; }
        public Render3DObject obj { get; private set; }
    }

    public override void do_load_resources(IResourceStore store)
    {
        parent_window.set_cursor_hidden(true);
        level = store.load_3D_object("./3d/ball");
        sky = store.load_3D_object("./3d/sky");

        int amount = 20;
        circlers = new Circler[amount];
        Rand rnd = new Rand();

        for (int i = 0; i < amount; i++)
        {
            Vec3 vec = Vec3() { x = (float)rnd.next_double(), y = (float)rnd.next_double(), z = (float)rnd.next_double() };
            bool[] bools = new bool[3];
            bools[0] = rnd.boolean();
            bools[1] = rnd.boolean();
            bools[2] = rnd.boolean();

            circlers[i] = new Circler(vec, bools, store);
        }

        //table = store.load_3D_object("./3d/table");
        /*field = store.load_3D_object("./3d/field");

        table.position = Vec3() { y = -0.163f };
        table.scale = Vec3() { x = 10, y = 10, z = 10 };
        tile.position = Vec3() { y = 12.5f };
        tile.scale = Vec3() { x = 1.0f, y = 1.0f, z = 1.0f };
        field.position = Vec3() { y = 12.4f };
        field.scale = Vec3() { x = 9.6f, z = 9.6f };*/
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
        //int slow = 300;
        camera_x += accel_x;
        camera_y += accel_y;
        camera_z += accel_z;

        for (int i = 0; i < circlers.length; i++)
        {
            circlers[i].light.position =
            Vec3()
            {
                x = (float)Math.sin(circlers[i].amount.x * derp / 10) * 10,
                y = (float)Math.cos(circlers[i].amount.y * derp / 10) * 10,
                z = (float)Math.sin(circlers[i].amount.z * derp / 10) * 10
            };
            circlers[i].obj.position = circlers[i].light.position;
        }

        /*light.position = Vec3() { x = (float)Math.cos(derp / 10 + 2) * 15f, y = 3 + (float)Math.cos(derp / 8 + 2) * 3f, z = (float)Math.sin(derp / 10 + 2) * 15f };
        tile.position = light.position;

        light2.position = Vec3() { x = 0, y = (float)Math.cos(derp / 5) * 10f, z = (float)Math.sin(derp / 5) * 10f };
        tile2.position = light2.position;*/
        //rotation += (float)dt * 0.02f;
        //tile.rotation = Vec3() { x = (float)last_y / slow + rotation * 0.25f, y = (float)last_x / (float)slow + (float)rotation, z = rotation * 0.1f };
        //table.rotation = Vec3() { x = (float)last_y / slow + rotation * 0.25f, y = (float)last_x / (float)slow + (float)rotation, z = rotation * 0.1f };
        //table.rotation = Vec3() { x = rotation * 0.25f, y = rotation, z = rotation * 0.1f };
        //tile.rotation = Vec3() { x = rotation * 0.25f, y = rotation, z = rotation * 0.1f };
        level.rotation = Vec3() { z = (float)derp * 0.025f, x = (float)derp * 0.01851f, y = (float)derp * 0.007943f };
        level.position = Vec3() { z = (float)Math.cos(derp / 10) * 2, x = (float)Math.sin(derp / 10) * 2 };

        //tile.position = Vec3() { y = -0.5f, z = 2.5f };
    }

    public override void do_render(RenderState state, IResourceStore store)
    {
        //state.add_scene();
        int slow = 300;
        state.camera_rotation = Vec3(){ x = 1 - (float)last_y / slow, y = - (float)last_x / slow };
        //state.camera_rotation = Vec3(){ x = 0, y = 0, z = 0f };
        state.camera_position = Vec3(){ x = camera_x, y = camera_y, z = camera_z };
        state.add_3D_object(level);
        state.add_3D_object(sky);

        for (int i = 0; i < circlers.length; i++)
        {
            state.add_light_source(circlers[i].light);
            state.add_3D_object(circlers[i].obj);
        }
        /*state.add_light_source(light);
        state.add_3D_object(tile);
        state.add_light_source(light2);
        state.add_3D_object(tile2);*/
        //state.add_3D_object(table);
        //state.add_3D_object(field);
        //state.finish_scene();
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
