public struct Size2
{
    float width;
    float height;

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
