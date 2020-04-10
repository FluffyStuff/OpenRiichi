using Engine;

public class RenderStick : WorldObjectTransformable
{
    private StickType stick_type;
    private RenderMaterial material;

    public RenderStick(StickType type)
    {
        stick_type = type;
    }

    public override void added()
    {
        RenderObject3D body = store.load_geometry_3D("stick", false).geometry[0] as RenderObject3D;
        set_object(body);
        MaterialSpecification spec = body.material.spec;
        spec.alpha = UniformType.DYNAMIC;
        material = body.material = store.load_material(spec);
        material.textures[0] = store.load_texture("Sticks/Stick" + stick_type_to_string(stick_type));
    }

    private static string stick_type_to_string(StickType stick_type)
    {
        switch (stick_type)
        {
        case StickType.STICK_100:
            return "100";
        default:
        case StickType.STICK_1000:
            return "1000";
        case StickType.STICK_5000:
            return "5000";
        case StickType.STICK_10000:
            return "10000";
        }
    }

    public float alpha
    {
        get { return material.alpha; }
        set { material.alpha = value; }
    }

    public enum StickType
    {
        STICK_100,
        STICK_1000,
        STICK_5000,
        STICK_10000
    }
}