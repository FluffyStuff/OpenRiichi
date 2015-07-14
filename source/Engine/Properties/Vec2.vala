public struct Vec2
{
    float x;
    float y;

    public Vec2 plus(Vec2 other)
    {
        return Vec2() { x = x + other.x, y = y + other.y };
    }

    public Vec2 mul_scalar(float scalar)
    {
        return Vec2() { x = x * scalar, y = y * scalar };
    }
}
