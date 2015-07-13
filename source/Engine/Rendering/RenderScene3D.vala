using Gee;

public abstract class RenderScene {}

public class RenderScene3D : RenderScene
{
    ArrayList<RenderObject3D> objs = new ArrayList<RenderObject3D>();
    ArrayList<LightSource> _lights = new ArrayList<LightSource>();

    public RenderScene3D(int width, int height)
    {
        this.width = width;
        this.height = height;

        focal_length = 1;

        set_camera(new Camera());
    }

    public void add_object(RenderObject3D object)
    {
        objs.add(object.copy());
    }

    public void add_light_source(LightSource light)
    {
        _lights.add(light.copy());
    }

    public void set_camera(Camera camera)
    {
        view_transform = camera.get_view_transform(true);
        camera_position = camera.position;
        focal_length = camera.focal_length;
    }

    public ArrayList<RenderObject3D> objects { get { return objs; } }
    public ArrayList<LightSource> lights { get { return _lights; } }
    public Mat4 view_transform { get; set; }
    public Vec3 camera_position { get; set; }
    public float focal_length { get; set; }
    public int width { get; private set; }
    public int height { get; private set; }
}
