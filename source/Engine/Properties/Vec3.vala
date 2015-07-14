public struct Vec3
{
    float x;
    float y;
    float z;

    public Vec3 plus(Vec3 other)
    {
        return Vec3() { x = x + other.x, y = y + other.y, z = z + other.z };
    }

    public Vec3 mul_scalar(float scalar)
    {
        return Vec3() { x = x * scalar, y = y * scalar, z = z * scalar };
    }

    public float dot(Vec3 other)
    {
        return x * other.x + y * other.y + z * other.z;
    }
}
