public struct Size2i
{
    int width;
    int height;

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
