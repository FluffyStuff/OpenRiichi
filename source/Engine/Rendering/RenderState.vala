public class RenderState
{
    Gee.ArrayList<Render3DObject> objs = new Gee.ArrayList<Render3DObject>();
    Gee.ArrayList<LightSource> _lights = new Gee.ArrayList<LightSource>();

    public RenderState(int width, int height)
    {
        screen_width = width;
        screen_height = height;
        focal_length = 1;
        perlin_strength = 0;
    }

    public void add_3D_object(Render3DObject object)
    {
        //TODO: create copy
        objs.add(object);
    }

    public void add_light_source(LightSource light)
    {
        _lights.add(light);
    }

    public void set_camera(Camera camera)
    {
        view_transform = camera.get_view_transform(true);
        camera_position = camera.position;
        focal_length = camera.focal_length;
    }

    public bool blacking { get; set; }
    public bool vertical {get; set;}
    public float bloom { get; set; }
    public float perlin_strength { get; set; }
    public int screen_width { get; private set; }
    public int screen_height { get; private set; }
    public Gee.ArrayList<Render3DObject> objects { get { return objs; } }
    public Gee.ArrayList<LightSource> lights { get { return _lights; } }
    public Color back_color { get; set; }
    public Mat4 view_transform { get; set; }
    public Vec3 camera_position { get; set; }
    public float focal_length { get; set; }
}
