public abstract class View : Object
{
    private Gee.ArrayList<View> chiild_views = new Gee.ArrayList<View>();
    protected RenderWindow parent_window;
    private View parent;

    public void add_chiild(View chiild)
    {
        chiild.set_parent(this);
        chiild.added();
        chiild_views.add(chiild);
    }

    public void remove_chiild(View chiild)
    {
        chiild_views.remove(chiild);
        chiild.set_parent(null);
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

        foreach (View view in chiild_views)
            view.process(delta);
    }

    public void render(RenderState state)
    {
        do_render(state);

        foreach (View view in chiild_views)
            view.render(state);
    }

    public void mouse_event(MouseEventArgs mouse)
    {
        for (int i = chiild_views.size - 1; i >= 0; i--)
            chiild_views[i].mouse_event(mouse);
        do_mouse_event(mouse);
    }

    public void mouse_move(MouseMoveArgs mouse)
    {
        for (int i = chiild_views.size - 1; i >= 0; i--)
            chiild_views[i].mouse_move(mouse);
        do_mouse_move(mouse);
    }

    public void key_press(KeyArgs key)
    {
        for (int i = chiild_views.size - 1; i >= 0; i--)
            chiild_views[i].key_press(key);
        do_key_press(key);
    }

    protected virtual void added() {}
    protected virtual void do_render(RenderState state) {}
    protected virtual void do_process(DeltaArgs delta) {}
    protected virtual void do_mouse_event(MouseEventArgs mouse) { }
    protected virtual void do_mouse_move(MouseMoveArgs mouse) { }
    protected virtual void do_key_press(KeyArgs key) { }

    protected IResourceStore store { get { return parent_window.store; } }
}
