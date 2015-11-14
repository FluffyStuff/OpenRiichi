public struct Color
{
    float r;
    float g;
    float b;
    float a;

    public Color(float r, float g, float b, float a)
    {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }

    public Color.with_alpha(float a)
    {
        r = 0;
        g = 0;
        b = 0;
        this.a = a;
    }

    public Color.black()
    {
        r = 0;
        g = 0;
        b = 0;
        a = 1;
    }

    public Color.white()
    {
        r = 1;
        g = 1;
        b = 1;
        a = 1;
    }

    public Color.red()
    {
        r = 1;
        g = 0;
        b = 0;
        a = 1;
    }

    public Color.green()
    {
        r = 0;
        g = 1;
        b = 0;
        a = 1;
    }

    public Color.blue()
    {
        r = 0;
        g = 0;
        b = 1;
        a = 1;
    }
}
