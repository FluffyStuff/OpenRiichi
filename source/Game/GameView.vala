using GL;

public class GameView : View
{
    private Render3DObject? sky = null;
    private Ball[] balls;
    private Circler[] circlers;
    private CameraController camera_controller = new CameraController();

    private SDLMusic music;
    private AubioAnalysis aubio;
    private const double music_start_time = 125; // This is probably where we want to start the scene, as not to become to long and dry

    private GLib.Timer timer;
    private double time_offset = music_start_time;

    const int light_count = 9;
    const int ball_count = 10;

    const int rand_seed = 1; // Random seed for ball colors and light speeds

    // Audio timings
    const float background_start = 139;
    const float ball_red_start = 229.5f;
    const float ball_color_start = 278.4f;
    const float background_color_start = 305.9f;

    // Audio stuff
    const int sample_rate = 44100;
    const int buffer_size = 512;
    const int hop_size = 512;

    public GameView()
    {
        string name = "./Data/Standerwick - Valyrian";
        aubio = new AubioAnalysis(name + ".wav", sample_rate, buffer_size, hop_size);
        aubio.analyse();
        music = new SDLMusic(sample_rate);
        music.load(name + ".ogg");
        timer = new GLib.Timer();
    }

    private double get_time()
    {
        double time = timer.elapsed();

        time_offset = Math.fmin(time + time_offset, (int)((double)aubio.length / sample_rate)) - time;
        time_offset = Math.fmax(time + time_offset, 0) - time;

        return time + time_offset;
    }

    public override void do_load_resources(IResourceStore store)
    {
        print("Start loading 3D objects.\n");

        parent_window.set_cursor_hidden(true);
        sky = store.load_3D_object("./Data/sky");

        circlers = new Circler[light_count];
        balls = new Ball[ball_count];
        Rand rnd = new Rand.with_seed(rand_seed);

        // Create balls
        for (int i = 0; i < ball_count; i++)
        {
            // Create colors for the balls which are used a bit into the song
            Vec3 color = Vec3() { x = -(float)rnd.next_double() * 0.1f, y = -(float)rnd.next_double() * 1.5f, z = -(float)rnd.next_double() * 3 };
            balls[i] = new Ball(color, store);
        }

        // Create lights
        for (int i = 0; i < light_count; i++)
        {
            // Create movement speeds for lights
            Vec3 vec = Vec3() { x = (float)rnd.next_double(), y = (float)rnd.next_double(), z = (float)rnd.next_double() };
            bool[] bools = new bool[3];
            bools[0] = rnd.boolean();
            bools[1] = rnd.boolean();
            bools[2] = rnd.boolean();

            circlers[i] = new Circler(vec, bools, store);
        }

        music.play(time_offset);
        timer.start();

        print("Finished loading 3D objects.\n");
    }

    private double time = 0;

    public override void do_process(double dt)
    {
        time = get_time();

        camera_x += accel_x;
        camera_y += accel_y;
        camera_z += accel_z;

        for (int i = 0; i < balls.length; i++)
        {
            // Get ball scale
            float val = aubio.get_amplitude(time, i + 3, 6, 10);
            val /= 5;
            val *= val;
            float scale = 1 + val;
            balls[i].obj.scale = Vec3() { x = scale, y = scale, z = scale };

            // Set position of the balls in a circle
            float ball_speed = 2.0f;
            float p = 2 * (float)Math.PI * i / balls.length;
            balls[i].obj.position = Vec3() { z = (float)Math.cos(time * ball_speed + p) * ball_count * 3, x = (float)Math.sin(time * ball_speed + p) * ball_count * 3, y = -5 };

            // Make the balls red in the middle of the song
            float color_mul = Math.fminf(Math.fmaxf(0, (float)time - ball_red_start), 1) * -val;
            balls[i].obj.diffuse_color = Vec3() { x = color_mul * 0.2f, y = color_mul * 2, z = color_mul * 3 };

            // Make the balls colory later in the song
            if (time > ball_color_start)
                balls[i].obj.diffuse_color = Vec3() { x = balls[i].color.x * val, y = balls[i].color.y * val, z = balls[i].color.z * val };
        }

        // Calculate the intensity of the lights in accordance with the base amplitude
        float val = aubio.get_amplitude(time, 3, 6, 10) * 1.5f;
        val *= val * 6 / light_count;

        for (int i = 0; i < circlers.length; i++)
        {
            // Calculate light positions
            circlers[i].light.position =
            Vec3()
            {
                x = (float)Math.sin(circlers[i].amount.x * time / 3) * 15,
                y = (float)Math.cos(circlers[i].amount.y * time / 3) * 20,
                z = (float)Math.sin(circlers[i].amount.z * time / 3) * 15
            };
            circlers[i].obj.position = circlers[i].light.position;

            // Set the colorful background color of the lights at the end of the song
            float color_mul = Math.fminf(Math.fmaxf(1, ((float)time - background_color_start) * 24), 10);

            float x = 0.3f / color_mul;
            float y = 0.3f / color_mul;
            float z = 0.3f / color_mul;

            // Increase R, G or B color
            if (i % 3 == 0)
                x *= color_mul * color_mul;
            else if (i % 3 == 1)
                y *= color_mul * color_mul;
            else
                z *= color_mul * color_mul;

            circlers[i].light.color = Vec3() { x = x, y = y, z = z };
            circlers[i].light.intensity = val;
        }

        // Deactivate the background until a little later at the beginning of the song
        // Linearly increase the background brightness at the end of the song
        if (time > background_start)
        {
            float mul = Math.fminf(Math.fmaxf(0.02f, ((float)time - background_color_start) * 1), 0.5f);
            sky.light_multiplier = mul;
            mul /= 100;
            mul = 0;
            sky.diffuse_color = Vec3() { x = mul, y = mul, z = mul * 4 };
        }
        else
            sky.light_multiplier = 0;
    }

    public override void do_render(RenderState state, IResourceStore store)
    {
        int slow = 300;

        // Set scene camera or custom camera position
        if (!custom_camera)
        {
            camera_controller.set_camera((float)get_time(), state, aubio, 0);

            accel_x = 0;
            accel_y = 0;
            accel_z = 0;
            camera_x = state.camera_position.x;
            camera_y = state.camera_position.y;
            camera_z = state.camera_position.z;
            last_x = (int)(-slow * state.camera_rotation.y);
            last_y = (int)(-slow * (state.camera_rotation.x - 1));
        }
        else
        {
            state.camera_rotation = Vec3(){ x = 1 - (float)last_y / slow, y = - (float)last_x / slow };
            state.camera_position = Vec3(){ x = camera_x, y = camera_y, z = camera_z };
        }

        // Add balls to scene
        for (int i = 0; i < balls.length; i++)
            state.add_3D_object(balls[i].obj);

        // Add lights and their boxes to scene
        for (int i = 0; i < circlers.length; i++)
        {
            state.add_light_source(circlers[i].light);
            state.add_3D_object(circlers[i].obj);
        }

        // Add sky to scene
        state.add_3D_object(sky);
    }

    private int last_x = 0;
    private int last_y = 0;
    private float accel_x = 0;
    private float accel_y = 0;
    private float accel_z = 0;
    private float camera_x = 0;
    private float camera_y = 0;
    private float camera_z = 0;
    private bool custom_camera = false;

    protected override void do_mouse_move(int x, int y)
    {
        last_x += x;
        last_y += y;
    }

    protected override void do_key_press(char key)
    {
        int slow = 300;
        float speed = 0.001f;

        switch (key)
        {
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
        case 87: //+
            time_offset += 10;
            music.play(get_time());
            break;
        case '-':
        case 86: //-
            time_offset -= 10;
            music.play(get_time());
            break;
        case 58: //F1
            custom_camera = !custom_camera;
            break;
        default:
            print("%i\n", (int)key);
            break;
        }
    }

    private class Ball
    {
        public Ball(Vec3 color, IResourceStore store)
        {
            this.color = color;
            obj = store.load_3D_object("./Data/ball");
        }

        public Vec3 color { get; private set; }
        public Render3DObject obj { get; private set; }
    }

    private class Circler
    {
        public Circler(Vec3 amount, bool[] cos, IResourceStore store)
        {
            this.amount = amount;
            this.cos = cos;
            light = new LightSource();
            obj = store.load_3D_object("./Data/box");
            obj.scale = Vec3() { x = 0.5f, y = 0.5f, z = 0.5f };
        }

        public Vec3 amount { get; private set; }
        public bool[] cos { get; private set; }
        public LightSource light { get; private set; }
        public Render3DObject obj { get; private set; }
    }

    // A class for custom camera angles etc
    private class CameraController
    {
        public void set_camera
        (
            float current_time,
            RenderState state,
            AubioAnalysis analysis,
            // Take in timings here
            float rotation_start_time
        )
        {
            if (current_time > rotation_start_time)
                rotation_position(state, current_time, analysis);
        }

        private void rotation_position(RenderState state, float time, AubioAnalysis analysis)
        {
            float speed = 3;

            state.camera_position = Vec3() { z = (float)Math.cos((time) * Math.PI / 10 * speed) * 45, y = 10, x = (float)Math.sin((time) * Math.PI / 10 * speed) * 45 };
            state.camera_rotation = Vec3()
            {
                y = (float)(-time / 10 * speed),
                x = (float)(Math.sin(time / 5 + 2.7) / Math.PI / 6 - 0.1),
                z = 0
            };

            float val = 1.2f - analysis.get_amplitude(time, 2, 8, 12) / 30;
            state.focal_length = val;
        }
    }

    /*private class RunningAverage
    {
        private int window_size;
        private int index = 0;
        private int count = 0;
        private float sum = 0;
        private float[] values;

        public RunningAverage(int window_size)
        {
            this.window_size = window_size;
            values = new float[window_size];
        }

        public float add(float val)
        {
            sum += val - values[index];
            values[index] = val;
            index = (index + 1) % window_size;
            if (count < window_size)
                count++;

            return average;
        }

        public float average { get { return sum / count; } }
    }*/
}
