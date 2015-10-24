public struct Vec2
{
    float x;
    float y;

    public Vec2.empty()
    {
        x = 0;
        y = 0;
    }

    public Vec2(float x, float y)
    {
        this.x = x;
        this.y = y;
    }

    public Vec2 plus(Vec2 other)
    {
        return Vec2(x + other.x, y + other.y);
    }

    public Vec2 mul_scalar(float scalar)
    {
        return Vec2(x * scalar, y * scalar);
    }
}
