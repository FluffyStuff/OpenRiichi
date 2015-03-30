using GL;

public class GameView : View
{
    private Render3DObject? sky = null;
    private Ball[] balls;
    private Circler[] circlers;
    private CameraController camera_controller = new CameraController();
    private FreeLookCamera free_look_camera = new FreeLookCamera();
    private bool black_filter = false;
    private bool do_bloom = true;
    private bool do_perlin = true;
    private float bloom_intensity = 0.6f;
    private float perlin_strength = 0.25f;
    private SDLMusic music;
    private AubioAnalysis aubio;
    private const double music_start_time = 137;//125; // This is probably where we want to start the scene, as not to become to long and dry

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

    private bool custom_camera = false;
    private bool is_paused = false;
    private double time = 0;

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

    public override void do_process(double dt)
    {
		time = get_time();

        if(custom_camera) {
            free_look_camera.update();
        }

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
		perlin_strength = 0.2f + (float)Math.pow(val / 4, 2) / 6;
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
		else {
			sky.light_multiplier = 0;
		}
    }

    public override void do_render(RenderState state, IResourceStore store)
    {
        // Set scene camera or custom camera position
        if (!custom_camera)
        {
            camera_controller.set_camera((float)get_time(), state, aubio);
            free_look_camera.set_camera_by_state(state);
        }
        else
        {
            state.camera_rotation = free_look_camera.get_rotation();
            state.camera_position = free_look_camera.get_position();
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

        state.blacking = black_filter;
        state.bloom = do_bloom ? bloom_intensity : 0;
        state.perlin_strength = do_perlin ? perlin_strength : 0;
    }

    protected override void do_mouse_move(int x, int y)
    {
        if(custom_camera) {
            free_look_camera.rotateCamera(x, y);
        }
    }

    protected override void do_key_press(char key)
    {
        switch (key)
        {
        case ' ':
            if(custom_camera) {
                free_look_camera.move_up();
            }
            break;
        case 'c':
            if(custom_camera) {
                free_look_camera.move_up(true);
            }
            break;
        case 'w':
            if(custom_camera) {
                free_look_camera.move_forward();
            }
            break;
        case 's':
            if(custom_camera) {
                free_look_camera.move_forward(true);
            }
            break;
        case 'a':
           if(custom_camera) {
                free_look_camera.move_left();
            }
            break;
        case 'd':
           if(custom_camera) {
                free_look_camera.move_left(true);
            }
            break;
        case 'x':
            if(custom_camera) {
                free_look_camera.stop();
            }
            break;
		case 'z':
		    if(custom_camera) {
                free_look_camera.accelerated = !free_look_camera.accelerated;
		    }
            break;
		case 'p':
			is_paused = !is_paused;
			if(is_paused) {
				timer.stop();
				music.pause();
			}
			else {
				timer.continue();
				music.play(get_time());
			}
			break;
        case '+':
        case 87: //+
            time_offset += 10;
            if(!is_paused) {
				music.play(get_time());
            }
            break;
        case '-':
        case 86: //-
            time_offset -= 10;
            if(!is_paused) {
				music.play(get_time());
            }
            break;
        case 58: //F1
            custom_camera = !custom_camera;
            break;
        case 59: //F2
            black_filter = !black_filter;
            break;
        case 60: //F3
            do_bloom = !do_bloom;
            break;
        case 61: //F4
            black_filter = !black_filter;
            break;
        case 62: //F5
            do_perlin = !do_perlin;
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

    private class FreeLookCamera
    {
        public FreeLookCamera()
        {
            this.accelerated = false;
            this.accel_x = 0;
            this.accel_y = 0;
            this.accel_z = 0;
            this.camera_x = 0;
            this.camera_y = 0;
            this.camera_z = 0;
        }

        public bool accelerated { get; set; }
        private const int slow = 300;
        private const float accel = 0.005f;
        private const float speed = 400.0f;
        private float accel_x { get; set; }
        private float accel_y { get; set; }
        private float accel_z { get; set; }
        private float camera_x { get; set; }
        private float camera_y { get; set; }
        private float camera_z { get; set; }

        private int last_x { get; set; }
        private int last_y { get; set; }

        public void move_left(bool reverse = false) {
            int dir = reverse ? -1 : 1;
            accel_x += dir * (float)Math.cos((float)last_x / slow * Math.PI) * accel;
            accel_z -= dir * (float)Math.sin((float)last_x / slow * Math.PI) * accel;

            if(!accelerated) {
                accel_x *= speed;
                accel_z *= speed;
        }
        }

        public void move_forward(bool reverse = false) {
            int dir = reverse ? -1 : 1;
            accel_x += dir * (float)Math.sin((float)last_x / slow * Math.PI) * (float)Math.cos((float)last_y / slow * Math.PI) * accel;
            accel_y += dir * (float)Math.sin((float)last_y / slow * Math.PI) * accel;
            accel_z += dir * (float)Math.cos((float)last_x / slow * Math.PI) * (float)Math.cos((float)last_y / slow * Math.PI) * accel;

            if(!accelerated) {
                accel_x *= speed;
                accel_y *= speed;
                accel_z *= speed;
            }
        }

        public void move_up(bool reverse = false) {
            int dir = reverse ? -1 : 1;
            accel_y +=  dir * accel;

            if(!accelerated) {
                accel_y *= speed;
            }
        }

        public void rotateCamera(int x, int y) {
            last_x += x;
            last_y += y;
        }

        public void stop() {
            accel_x = 0;
            accel_y = 0;
            accel_z = 0;
        }

        public void set_camera_by_state(RenderState state) {
            accel_x = 0;
            accel_y = 0;
            accel_z = 0;
            camera_x = state.camera_position.x;
            camera_y = state.camera_position.y;
            camera_z = state.camera_position.z;
            last_x = (int)(-slow * state.camera_rotation.y);
            last_y = (int)(-slow * (state.camera_rotation.x - 1));
        }

        public void update() {
            camera_x += accel_x;
            camera_y += accel_y;
            camera_z += accel_z;

            if(!accelerated) {
                stop();
            }
        }

        public Vec3 get_rotation() {
            return Vec3() { x = 1 - (float)last_y / slow, y = - (float)last_x / slow };
        }

        public Vec3 get_position() {
            return Vec3() { x = camera_x, y = camera_y, z = camera_z };
        }
    }

    // A class for custom camera angles etc
    private class CameraController
    {
        private const float start_time = 125;
        private const float rotation_start_time = 12;
        private const float speed = 3;

        public void set_camera(float time, RenderState state, AubioAnalysis analysis)
        {
        	float t = time - start_time;
			if (t <= rotation_start_time && t > 0) {
                zoom_in(t, state, analysis);
        }

            if (t > rotation_start_time || t < 0) {
                rotation_position(time, state, analysis);
            }
        }

        private void zoom_in(float time, RenderState state, AubioAnalysis analysis) {
            float dt = time / rotation_start_time;
            Vec3 p0 = Vec3() { x = 600, y = 400, z = 0 };
            Vec3 p1 = Vec3() { x = 600, y = -50, z = 0 };
            Vec3 p2 = Vec3() { x = 70, y = -50, z = 0 };
            Vec3 p3 = Vec3() { x = 70, y = 10, z = 0 };

            var point = CalculateBezierPoint(dt, p0, p1, p2, p3);
            state.camera_position = point;

            state.camera_rotation = Vec3()
            {
                x = 0,
                y = -0.5f,
                z = 0
            };
        }

        private void rotation_position(float time, RenderState state, AubioAnalysis analysis)
        {
            state.camera_position = Vec3() { z = (float)Math.cos((time) * Math.PI / 10 * speed) * 45, y = 10, x = (float)Math.sin((time) * Math.PI / 10 * speed) * 45 };
            state.camera_rotation = Vec3() {
                x = (float)(Math.sin(time / 5 + 2.7) / Math.PI / 6 - 0.1),
                y = (float)(-time / 10 * speed),
                z = 0
            };

            float val = 1.2f - analysis.get_amplitude(time, 2, 8, 12) / 30;
            state.focal_length = val;
        }

        private Vec3 CalculateBezierPoint(float t, Vec3 p0, Vec3 p1, Vec3 p2, Vec3 p3)
        {
            float u = 1 - t;
            float tt = t*t;
            float uu = u*u;
            float uuu = uu*u;
            float ttt = tt*t;

            Vec3 p = Vec3() {
                x = uuu * p0.x,
				y = uuu * p0.y,
				z = uuu * p0.z
            };

            p.x += uu * t * p1.x;
            p.y += uu * t * p1.y;
            p.z += uu * t * p1.z;

            p.x += u * tt * p2.x;
            p.y += u * tt * p2.y;
            p.z += u * tt * p2.z;

            p.x += ttt * p3.x;
            p.y += ttt * p3.y;
            p.z += ttt * p3.z;
            return p;
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
