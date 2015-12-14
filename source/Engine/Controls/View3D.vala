public abstract class View3D : Container
{
    protected abstract void do_render_3D(RenderState state);

    protected override void do_render(RenderState state, RenderScene2D scene)
    {
        do_render_3D(state);
    }
}
