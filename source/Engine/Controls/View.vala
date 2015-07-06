public abstract class View : Object
{
    private Gee.ArrayList<View> child_views = new Gee.ArrayList<View>();
    protected RenderWindow parent_window;
    private View parent;

    public void add_child(View child)
    {
        child.set_parent(this);
        child.added();
        child_views.add(child);
    }

    public void remove_child(View child)
    {
        child_views.remove(child);
        child.set_parent(null);
    }

    private void set_parent(View? parent)
    {
        this.parent = parent;

        if (parent == null)
            parent_window = null;
        else
            parent_window = parent.parent_window;
    }

    public void process(DeltaArgs delta)
    {
        do_process(delta);

        foreach (View view in child_views)
            view.process(delta);
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

    protected virtual void added() {}
    protected virtual void do_render(RenderState state) {}
    protected virtual void do_process(DeltaArgs delta) {}
    protected virtual void do_mouse_event(MouseEventArgs mouse) {}
    protected virtual void do_mouse_move(MouseMoveArgs mouse) {}
    protected virtual void do_key_press(KeyArgs key) {}

    protected IResourceStore store { get { return parent_window.store; } }
}
