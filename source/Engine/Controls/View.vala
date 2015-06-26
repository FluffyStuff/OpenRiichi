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

    public void process(double dt)
    {
        do_process(dt);

        foreach (View view in child_views)
            view.process(dt);
    }

    public void render(RenderState state, IResourceStore store)
    {
        do_render(state, store);

        foreach (View view in child_views)
            view.render(state, store);
    }

    public void mouse_move(int x, int y)
    {
        // TODO: Check handled
        do_mouse_move(x, y);

        foreach (View view in child_views)
            view.mouse_move(x, y);
    }

    public void key_press(char key)
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
    protected virtual void do_render(RenderState state, IResourceStore store) {}
    protected virtual void do_process(double dt) {}
    protected virtual void do_mouse_move(int x, int y) {}
    protected virtual void do_key_press(char key) {}
}
