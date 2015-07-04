public abstract class View : Object
{
    private Gee.ArrayList<View> child_views = new Gee.ArrayList<View>();
    protected RenderWindow parent_window;
    private View parent;

    public void add_child(View child)
    {
        child_views.add(child);
        child.set_parent(this);
        child.activated();
    }

    private void set_parent(View parent)
    {
        this.parent = parent;

        if (parent == null)
            parent_window = null;
        else
            parent_window = parent.parent_window;
    }

    public void process(DeltaArgs delta, IResourceStore store)
    {
        do_process(delta, store);

        foreach (View view in child_views)
            view.process(delta, store);
    }

    public void render(RenderState state)
    {
        do_render(state);

        foreach (View view in child_views)
            view.render(state);
    }

    public void mouse_event(MouseEventArgs mouse)
    {
        // TODO: Check handled
        do_mouse_event(mouse);

        foreach (View view in child_views)
            view.mouse_event(mouse);
    }

    public void mouse_move(MouseMoveArgs mouse)
    {
        // TODO: Check handled
        do_mouse_move(mouse);

        foreach (View view in child_views)
            view.mouse_move(mouse);
    }

    public void key_press(KeyArgs key)
    {
        // TODO: Check handled
        do_key_press(key);

        foreach (View view in child_views)
            view.key_press(key);
    }

    public void load_resources(IResourceStore store)
    {
        do_load_resources(store);

        foreach (View view in child_views)
            view.load_resources(store);
    }

    protected virtual void activated() {}
    protected virtual void do_load_resources(IResourceStore store) {}
    protected virtual void do_render(RenderState state) {}
    protected virtual void do_process(DeltaArgs delta, IResourceStore store) {}
    protected virtual void do_mouse_event(MouseEventArgs mouse) {}
    protected virtual void do_mouse_move(MouseMoveArgs mouse) {}
    protected virtual void do_key_press(KeyArgs key) {}
}
