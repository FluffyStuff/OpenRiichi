using GL;

public interface IObject3DResourceHandle : Object {}
public interface ITextureResourceHandle : Object {}

public class OpenGLObject3DResourceHandle : IObject3DResourceHandle, Object
{
    public OpenGLObject3DResourceHandle(GLuint handle, int triangle_count)
    {
        this.handle = handle;
        this.triangle_count = triangle_count;
    }

    // Can't use GLuint as a property due to a bug in vala...
    public /*GL*/uint handle { get; private set; }
    public int triangle_count { get; private set; }
}

public class OpenGLTextureResourceHandle : ITextureResourceHandle, Object
{
    public OpenGLTextureResourceHandle(GLuint handle)
    {
        this.handle = handle;
    }

    // Can't use GLuint as a property due to a bug in vala...
    public /*GL*/uint handle { get; private set; }
}
