public class LightSource
{
    public LightSource()
    {
        color = Vec3() { x = 1, y = 1, z = 1 };
        intensity = 1;
    }

    public Vec3 position { get; set; }
    public Vec3 color { get; set; }
    public float intensity { get; set; }
}
