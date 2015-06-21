public class Camera
{
    private float _pitch;
    private float _yaw;
    private float _roll;

    public Camera()
    {
        focal_length = 1;
        calc_transform();
    }

    private void calc_transform()
    {
        float pi = (float)Math.PI;
        Mat4 x = Calculations.rotation_matrix({1, 0, 0}, pi * pitch);
        Mat4 y = Calculations.rotation_matrix({0, 1, 0}, pi * yaw);
        Mat4 z = Calculations.rotation_matrix({0, 0, 1}, pi * roll);
        Mat4 p = Calculations.translation_matrix(Calculations.vec3_neg(position));

        view_transform = p.mul_mat(x).mul_mat(y).mul_mat(z);

        //rotation = rot;

        rotation = Vec3() { x = yaw, y = pitch, z = roll };
    }

    public float pitch
    {
        get { return _pitch; }
        set { _pitch = value; calc_transform(); }
    }

    public float yaw
    {
        get { return _yaw; }
        set { _yaw = value; calc_transform(); }
    }

    public float roll
    {
        get { return _roll; }
        set { _roll = value; calc_transform(); }
    }

    public Vec3 position { get; set; }
    public Vec3 rotation { get; private set; }
    public float focal_length { get; set; }
    public Mat4 view_transform { get; private set; }
}
