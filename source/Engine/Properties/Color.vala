public struct Color : Vec4
{
    public float r { get { return x; } set { x = value; } }
    public float g { get { return y; } set { y = value; } }
    public float b { get { return z; } set { z = value; } }
    public float a { get { return w; } set { w = value; } }

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
