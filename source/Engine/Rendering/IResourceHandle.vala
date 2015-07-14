public interface IModelResourceHandle : Object {}
public interface ITextureResourceHandle : Object {}

public class OpenGLModelResourceHandle : IModelResourceHandle, Object
{
    public OpenGLModelResourceHandle(uint handle, int triangle_count, uint array_handle)
    {
        this.handle = handle;
        this.triangle_count = triangle_count;
        this.array_handle = array_handle;
    }

    public uint handle { get; private set; }
    public int triangle_count { get; private set; }
    public uint array_handle { get; private set; }
}

public class OpenGLTextureResourceHandle : ITextureResourceHandle, Object
{
    public OpenGLTextureResourceHandle(uint handle)
    {
        this.handle = handle;
    }

    public uint handle { get; private set; }
}
