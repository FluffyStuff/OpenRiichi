public class Camera
{
    public Camera()
    {
        focal_length = 1;
    }

    public Mat4 get_view_transform(bool b)
    {
        float pi = (float)Math.PI;
        Mat4 x = Calculations.rotation_matrix(Vec3(1, 0, 0), pi * pitch);
        Mat4 y = Calculations.rotation_matrix(Vec3(0, 1, 0), pi * yaw);
        Mat4 z = Calculations.rotation_matrix(Vec3(0, 0, 1), pi * roll);
        Mat4 p = Calculations.translation_matrix(position.negate());

        return p.mul_mat(y).mul_mat(x).mul_mat(z);
    }

    public float pitch { get; set; }
    public float yaw { get; set; }
    public float roll { get; set; }

    public Vec3 position { get; set; }
    public float focal_length { get; set; }
}
