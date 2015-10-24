public abstract class View2D : View
{
    private Gee.ArrayList<Control> child_controls = new Gee.ArrayList<Control>();

    public void add_control(Control control)
    {
        child_controls.add(control);
        control.set_parent(this);
    }

    public void remove_control(Control control)
    {
        control.set_parent(null);
        child_controls.remove(control);
    }

    protected override void do_process(DeltaArgs delta)
    {
        foreach (Control control in child_controls)
            control.process(delta);

        do_process_2D(delta);
    }

    protected override void do_render(RenderState state)
    {
        RenderScene2D scene = new RenderScene2D(state.screen_size);

        foreach (Control control in child_controls)
            control.render(scene);

        do_render_2D(state, scene);

        state.add_scene(scene);
    }

    protected override void resized()
    {
        foreach (Control control in child_controls)
            control.resize();
        on_resized();
    }

    protected override void do_mouse_move(MouseMoveArgs mouse)
    {
        foreach (Control control in child_controls)
            control.mouse_move(mouse);
    }

    protected override void do_mouse_event(MouseEventArgs mouse)
    {
        foreach (Control control in child_controls)
            control.mouse_event(mouse);
    }

    protected virtual void on_resized() {}
    protected virtual void do_process_2D(DeltaArgs args) {}
    protected virtual void do_render_2D(RenderState state, RenderScene2D scene) {}
}
