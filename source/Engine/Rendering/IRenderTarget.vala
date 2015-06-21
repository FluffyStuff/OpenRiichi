using Gee;

public interface IRenderTarget : Object
{
    public abstract void set_state(RenderState state);
    public abstract bool start();
    public abstract void stop();
    public abstract Mat4 get_projection_matrix(float view_angle, float aspect_ratio, float z_near, float z_far);
    //public abstract Mat4 get_view_matrix(Camera camera);

    public abstract uint load_3D_object(Resource3DObject object);
    public abstract uint load_texture(ResourceTexture texture);
    public abstract IResourceStore resource_store { get; }
}
