public struct Vec2i
{
    int x;
    int y;

    public Vec2i.empty()
    {
        x = 0;
        y = 0;
    }

    public Vec2i(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    public Vec2i plus(Vec2i other)
    {
        return Vec2i(x + other.x, y + other.y);
    }

    public Vec2i mul_scalar(int scalar)
    {
        return Vec2i(x * scalar, y * scalar);
    }
}
