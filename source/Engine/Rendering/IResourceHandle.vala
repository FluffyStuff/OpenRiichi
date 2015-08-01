public interface IModelResourceHandle : Object {}
public interface ITextureResourceHandle : Object {}
public abstract class ILabelResourceHandle : Object
{
    public bool created { get; set; }
    public string font_type { get; set; }
    public float font_size { get; set; }
    public string text { get; set; }
}
