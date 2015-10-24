public struct Vec3
{
    float x;
    float y;
    float z;

    public Vec3.empty()
    {
        x = 0;
        y = 0;
        z = 0;
    }

    public Vec3(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public Vec3 plus(Vec3 other)
    {
        return Vec3(x + other.x, y + other.y, z + other.z);
    }

    public Vec3 minus(Vec3 other)
    {
        return Vec3(x - other.x, y - other.y, z - other.z);
    }

    public Vec3 mul_scalar(float scalar)
    {
        return Vec3(x * scalar, y * scalar, z * scalar);
    }

    public float dot(Vec3 other)
    {
        return x * other.x + y * other.y + z * other.z;
    }

    public float length()
    {
        return (float)Math.sqrt(x * x + y * y + z * z);
    }

    public Vec3 normalize()
    {
        float len = length();
        return Vec3(x / len, y / len, z / len);
    }

    public Vec3 negate()
    {
        return Vec3(-x, -y, -z);
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

        return Vec3(x, y, z);
    }
}
