public class MainView : View
{
    public MainView(RenderWindow window)
    {
        parent_window = window;
    }

    public override void do_render(RenderState state, IResourceStore store){}
    protected override void do_mouse_move(int x, int y){}
    protected override void do_load_resources(IResourceStore store){}
    protected override void do_process(double dt){}
    protected override void do_key_press(char key){}
}
