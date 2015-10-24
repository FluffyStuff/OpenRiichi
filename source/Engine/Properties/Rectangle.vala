public struct Rectangle : Vec4
{
    public float width { get { return z; } set { z = value; } }
    public float height { get { return w; } set { w = value; } }

    public Rectangle(float x, float y, float width, float height)
    {
        this.x = x;
        this.y = y;
        z = width;
        w = height;
    }

    public Vec2 position { get { return Vec2(x, y); } }
    public Size2 size { get { return Size2(width, height); } }
}
