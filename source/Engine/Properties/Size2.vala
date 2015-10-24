public struct Size2 : Vec2
{
    public float width { get { return x; } set { x = value; } }
    public float height { get { return y; } set { y = value; } }

    public Size2(float width, float height)
    {
        this.width = width;
        this.height = height;
    }

    public Size2i to_size2i()
    {
        return Size2i((int)width, (int)height);
    }
}
