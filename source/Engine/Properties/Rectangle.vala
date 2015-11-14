public struct Rectangle
{
    float x;
    float y;
    float width;
    float height;

    public Rectangle(float x, float y, float width, float height)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    public Vec2 position { get { return Vec2(x, y); } }
    public Size2 size { get { return Size2(width, height); } }
}
