public struct Size2i : Vec2i
{
    public int width { get { return x; } set { x = value; } }
    public int height { get { return y; } set { y = value; } }

    public Size2i(int width, int height)
    {
        this.width = width;
        this.height = height;
    }

    public Size2 to_size2()
    {
        return Size2(width, height);
    }
}
