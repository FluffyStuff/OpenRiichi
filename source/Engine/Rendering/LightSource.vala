public class LightSource
{
    public LightSource()
    {
        color = Color.white();
        intensity = 1;
    }

    public LightSource copy()
    {
        LightSource light = new LightSource();
        light.position = position;
        light.color = color;
        light.intensity = intensity;

        return light;
    }

    public Vec3 position { get; set; }
    public Color color { get; set; }
    public float intensity { get; set; }
}
