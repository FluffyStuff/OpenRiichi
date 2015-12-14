public abstract class View2D : Container
{
    public override void render(RenderState state, RenderScene2D scene)
    {
        if (!visible)
            return;

        RenderScene2D new_scene = new RenderScene2D(rect);

        do_render(state, new_scene);

        foreach (Container child in children)
            child.render(state, new_scene);

        state.add_scene(new_scene);
    }
}
