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

    public float dist_sq(Vec3 other)
    {
        float x = this.x - other.x;
        float y = this.y - other.y;
        float z = this.z - other.z;
        return x*x + y*y + z*z;
    }

    public float dist(Vec3 other)
    {
        return (float)Math.sqrt(dist_sq(other));
    }

    public static Vec3 lerp(Vec3 start, Vec3 end, float lerp)
    {
        float x = start.x + (end.x - start.x) * lerp;
        float y = start.y + (end.y - start.y) * lerp;
        float z = start.z + (end.z - start.z) * lerp;

        return Vec3() { x = x, y = y, z = z };
    }
}
