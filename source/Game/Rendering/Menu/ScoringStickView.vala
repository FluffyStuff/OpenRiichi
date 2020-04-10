using Engine;
using Gee;

public class ScoringStickNumberView : View2D
{
    private RenderStick.StickType stick_type;
    private bool left_text;
    private int _number = 0;

    private LabelControl? label;
    private ScoringStickView? stick;

    public ScoringStickNumberView(RenderStick.StickType stick_type, bool left_text)
    {
        this.stick_type = stick_type;
        this.left_text = left_text;
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

    public float alpha
    {
        get { return label.alpha; }
        set
        {
            label.alpha = value;
            stick.alpha = value;
        }
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
    private RenderStick.StickType stick_type;
    private RenderStick stick;

    public ScoringStickView(RenderStick.StickType stick_type)
    {
        this.stick_type = stick_type;
    }

    public override void added()
    {
        stick = new RenderStick(stick_type);
        world.add_object(stick);

        float len = 2.5f;

        WorldCamera camera = new TargetWorldCamera(stick);
        world.add_object(camera);
        world.active_camera = camera;
        camera.position = Vec3(0, len * 2, len);

        WorldLight light1 = new WorldLight();
        WorldLight light2 = new WorldLight();
        world.add_object(light1);
        world.add_object(light2);

        light1.color = Color.white();
        light1.position = Vec3(len * 2, len * 2, len);
        light1.intensity = 15;
        light2.color = Color.white();
        light2.position = Vec3(-len * 2, len * 2, len);
        light2.intensity = 15;
    }

    public float alpha
    {
        get { return stick.alpha; }
        set { stick.alpha = value; }
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
