using GL;

public class GameView : View
{
    //private float rotation = 0;

    private Render3DObject? sky = null;
    //private Render3DObject? level = null;

    private Render3DObject[] balls;
    private Circler[] circlers;
    //private Render3DObject? table = null;
    //private Render3DObject? field = null;

    private float[] values;
    private float[] samples;
    public SDLMusicHook music;
    private RunningAverage[] avgs;

    int light_count = 20;
    int ball_count = 10;

    public GameView()
    {
        values = libaubio.load("Standerwick - Valyrian - test.wav", out samples);
        print("?: " + samples.length.to_string() + "\n");
    }

    public override void do_load_resources(IResourceStore store)
    {
        parent_window.set_cursor_hidden(true);
        //level = store.load_3D_object("./3d/level");
        sky = store.load_3D_object("./3d/sky");
        sky.light_multiplier = 0;
        sky.color_modifier = 0;

        circlers = new Circler[light_count];
        balls = new Render3DObject[ball_count];
        Rand rnd = new Rand();
        avgs = new RunningAverage[ball_count];

        for (int i = 0; i < ball_count; i++)
        {
            avgs[i] = new RunningAverage(6);
            balls[i] = store.load_3D_object("./3d/ball");
            //balls[i].scale = Vec3() { x = 1, y = 0.001f, z = 1 };
        }

        for (int i = 0; i < light_count; i++)
        {
            Vec3 vec = Vec3() { x = (float)rnd.next_double(), y = (float)rnd.next_double(), z = (float)rnd.next_double() };
            bool[] bools = new bool[3];
            bools[0] = rnd.boolean();
            bools[1] = rnd.boolean();
            bools[2] = rnd.boolean();

            circlers[i] = new Circler(vec, bools, store);
        }
        music = new SDLMusicHook(samples);

        //table = store.load_3D_object("./3d/table");
        /*field = store.load_3D_object("./3d/field");

        table.position = Vec3() { y = -0.163f };
        table.scale = Vec3() { x = 10, y = 10, z = 10 };
        tile.position = Vec3() { y = 12.5f };
        tile.scale = Vec3() { x = 1.0f, y = 1.0f, z = 1.0f };
        field.position = Vec3() { y = 12.4f };
        field.scale = Vec3() { x = 9.6f, z = 9.6f
        };*/
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
    private double speed = 1;

    public override void do_process(double dt)
    {
        //dt *= speed;
        //derp += dt * speed;
        derp = dt;
        //int slow = 300;
        camera_x += accel_x;
        camera_y += accel_y;
        camera_z += accel_z;

        int r = 44100;
        int s = 512;

        //print(derp.to_string() + "\n");

        for (int i = 0; i < balls.length; i++)
        {
            float val = 0;
            for (int j = 0; j < 10; j++)
            {
                float sq = values[(int)(derp * r / s) * 512 + (i+3) * 10 + j];
                val += sq*sq;
            }

            val /= 10;
            val = (float)Math.sqrt(val);
            val = avgs[i].add(val);

            val /= 5;
            val *= val;
            balls[i].color_modifier = val;
            //print("val: " + val.to_string() + "\n");
            float scale = 1 + val;

            float p = 2 * (float)Math.PI * i / balls.length;
            balls[i].position = Vec3() { z = (float)Math.cos(derp / 10 + p) * ball_count * 3, x = (float)Math.sin(derp / 10 + p) * ball_count * 3, y = -5 };
            balls[i].scale = Vec3() { x = scale, y = scale, z = scale };
        }

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

        //level.rotation = Vec3() { /*z = (float)derp * 0.025f, x = (float)derp * 0.01851f,*/ y = (float)derp * 0.007943f };
        //level.position = Vec3() { z = (float)Math.cos(derp / 10) * 2, x = (float)Math.sin(derp / 10) * 2 };

        //tile.position = Vec3() { y = -0.5f, z = 2.5f };
    }

    float lst = 0;
    float run = 0;
    RunningAverage cam = new RunningAverage(10);
    public override void do_render(RenderState state, IResourceStore store)
    {
        //state.add_scene();
        int slow = 300;
        state.camera_rotation = Vec3(){ x = 1 - (float)last_y / slow, y = - (float)last_x / slow };
        state.camera_position = Vec3(){ x = camera_x, y = camera_y, z = camera_z };
        //state.camera_position = Vec3() { x = pos.x + 0.5f, y = pos.y + 0.5f, z = pos.z + 0.5f };
        int r = 44100;
        int s = 512;
        float val = avgs[0].average;
        float scale = val;
        float abs = scale - lst;
        abs = abs > 0 ? abs : -abs;
        abs = (float)Math.sqrt(abs) * 50;
        run += cam.add(abs);
        lst = scale;
        float speed = 3;

        state.camera_position = Vec3() { z = (float)Math.cos((derp) * Math.PI / 10 * speed) * 40, y = 10, x = (float)Math.sin((derp) * Math.PI / 10 * speed) * 40 };
        state.camera_rotation = Vec3()
        {
            y = (float)(-derp / 10 * speed) + (float)(Math.cos(run / 500) / 500),
            x = (float)(Math.sin(derp / 5) / Math.PI / 6 - 0.1) + (float)(Math.sin(run / 500) / 500),
            z = 0
        };
        //state.add_3D_object(level);
        //if (derp > 174)
        val /= 1;
        val *= val / 5;
        //print("val: " + val.to_string() + "\n");
        if (derp > 14)
            sky.light_multiplier = (float)(val);
        state.add_3D_object(sky);

        for (int i = 0; i < balls.length; i++)
        {
            state.add_3D_object(balls[i]);
        }

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
        case '+':
            this.speed *= 2;
            break;
        case '-':
            this.speed /= 2;
            break;
        default:
            print("%i\n", (int)key);
            break;
        }
    }

    private class Circler
    {
        public Circler(Vec3 amount, bool[] cos, IResourceStore store)
        {
            this.amount = amount;
            this.cos = cos;
            light = new LightSource();
            obj = store.load_3D_object("./3d/box");
            obj.scale = Vec3() { x = 0.5f, y = 0.5f, z = 0.5f };
        }

        public Vec3 amount { get; private set; }
        public bool[] cos { get; private set; }
        public LightSource light { get; private set; }
        public Render3DObject obj { get; private set; }
    }

    private class RunningAverage
    {
        private int window_size;
        private int index = 0;
        private float sum = 0;
        private float last = 0;
        private float[] values;

        public RunningAverage(int window_size)
        {
            this.window_size = window_size;
            values = new float[window_size];
        }

        public float add(float val)
        {
            if (val == last)
                return sum / window_size;
            last = val;

            sum -= values[index];
            sum += val;
            values[index] = val;
            index = (index + 1) % window_size;

            return sum / window_size;
        }

        public float average { get { return sum / window_size; } }
    }
}
