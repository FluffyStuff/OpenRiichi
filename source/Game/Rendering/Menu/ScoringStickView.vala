using Gee;

public class ScoringStickNumberView : View2D
{
    private string stick_type;
    private bool left_text;
    private int _number = 0;

    private LabelControl? label;
    private ScoringStickView? stick;

    public ScoringStickNumberView(string stick_type, bool left_text)
    {
        this.stick_type = stick_type;
        this.left_text = left_text;
        resize_style = ResizeStyle.ABSOLUTE;
    }

    protected override void added()
    {
        label = new LabelControl();
        add_child(label);
        label.inner_anchor = Vec2(left_text ? 0 : 1, 0.5f);
        label.outer_anchor = Vec2(left_text ? 0 : 1, 0.5f);

        stick = new ScoringStickView(stick_type);
        add_child(stick);
        stick.inner_anchor = Vec2(left_text ? 1 : 0, 0.5f);
        stick.outer_anchor = Vec2(left_text ? 1 : 0, 0.5f);

        number = _number;
    }

    protected override void resized()
    {
        if (stick != null && label != null)
            stick.size = Size2(size.width - label.size.width, size.height);
    }

    public int number
    {
        get { return _number; }
        set
        {
            _number = value;
            label.text = left_text ? (value.to_string() + "x") : ("x" + value.to_string());
            resized();
        }
    }
}

public class ScoringStickView : View3D
{
    private string stick_type;
    private RenderGeometry3D stick;

    private Camera camera = new Camera();
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();
    private float width = 1;

    public ScoringStickView(string stick_type)
    {
        this.stick_type = stick_type;
        resize_style = ResizeStyle.ABSOLUTE;
    }

    public override void added()
    {
        /*RectangleControl rect = new RectangleControl();
        add_child(rect);
        rect.resize_style = ResizeStyle.RELATIVE;
        rect.color = Color(1, 0, 0, 0.1f);*/

        float scale = 0.9f;

        stick = store.load_geometry_3D("stick", false);
        RenderBody3D body = ((RenderBody3D)stick.geometry[0]);
        body.texture = store.load_texture("Sticks/Stick" + stick_type);

        stick.scale = Vec3(scale, scale, scale);
        Vec3 size = ((RenderBody3D)stick.geometry[0]).model.size;

        width = size.x / scale;

        float len = 15;
        camera.focal_length = 0.03f;

        Vec3 pos = Vec3(0, len, len);
        camera.position = pos;
        camera.pitch = -0.249f;
        camera.roll = 0;

        light1.color = Color.white();
        light1.position = Vec3(len, len * 2, -len);
        light1.intensity = 15;
        light2.color = Color.white();
        light2.position = Vec3(-len, len * 2, -len);
        light2.intensity = 15;
    }

    public override void do_render_3D(RenderState state)
    {
        RenderScene3D scene = new RenderScene3D(state.screen_size, 1.11f * width, rect);

        scene.set_camera(camera);
        scene.add_light_source(light1);
        scene.add_light_source(light2);

        scene.add_object(stick);

        state.add_scene(scene);
    }

    /*float mul = 1;
    float pitch;
    protected override void do_key_press(KeyArgs key)
    {
        pitch = camera.pitch;

        if (key.keycode == KeyCode.NUM_0)
            mul += 0.01f;
        else if (key.keycode == KeyCode.NUM_1)
            mul -= 0.01f;
        else if (key.keycode == KeyCode.NUM_2)
            pitch += 0.001f;
        else if (key.keycode == KeyCode.NUM_3)
            pitch -= 0.001f;

        camera.pitch = pitch;
    }*/
}
