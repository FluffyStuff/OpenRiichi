using Gee;

public interface IRenderTarget : Object
{
    public abstract void set_state(RenderState state);
    public abstract bool start();
    public abstract void stop();

    public abstract uint load_3D_object(Resource3DObject object);
    public abstract uint load_texture(ResourceTexture texture);
    public abstract IResourceStore resource_store { get; }
}
