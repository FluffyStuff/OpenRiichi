public class Vector2
{
    public Vector2.empty()
    {
        this(0, 0, 0);
    }

    public Vector2(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public float x { get; set; }
    public float y { get; set; }
    public float z { get; set; }
}
