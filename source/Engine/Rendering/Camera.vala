public class Camera
{
    private float _pitch;
    private float _yaw;
    private float _roll;

    public Camera()
    {
        focal_length = 1;
    }

    private void recalc()
    {
        /*Mat4 x = Calculations.rotation_matrix({1, 0, 0}, pitch);
        Mat4 y = Calculations.rotation_matrix({0, 1, 0}, yaw);
        Mat4 z = Calculations.rotation_matrix({0, 0, 1}, roll);

        rotation = rot;*/

        rotation = Vec3() { x = yaw, y = pitch, z = roll };
    }

    public float pitch
    {
        get { return _pitch; }
        set { _pitch = value; recalc(); }
    }

    public float yaw
    {
        get { return _yaw; }
        set { _yaw = value; recalc(); }
    }

    public float roll
    {
        get { return _roll; }
        set { _roll = value; recalc(); }
    }

    public Vec3 position { get; set; }
    public Vec3 rotation { get; private set; }
    public float focal_length { get; set; }
}
