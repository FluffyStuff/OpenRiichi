public class Vector
{
    public Vector.empty()
    {
        this(0, 0, 0);
    }

    public Vector(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public float x { get; set; }
    public float y { get; set; }
    public float z { get; set; }
}
