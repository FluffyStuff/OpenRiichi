using Gee;

public interface IRenderTarget : Object
{
    public abstract void set_state(RenderState state);
    public abstract bool start();
    public abstract void stop();
    public abstract Mat4 get_projection_matrix(float view_angle, float aspect_ratio);

    public abstract uint load_model(ResourceModel object);
    public abstract uint load_texture(ResourceTexture texture);
    public abstract IResourceStore resource_store { get; }
    public abstract bool v_sync { get; set; }
    public abstract string shader_3D { get; set; }
    public abstract string shader_2D { get; set; }
}
