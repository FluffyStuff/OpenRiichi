using Gee;

public class RenderState
{
    public RenderState(Size2i screen_size)
    {
        this.screen_size = screen_size;

        scenes = new ArrayList<RenderScene>();
    }

    public void add_scene(RenderScene scene)
    {
        scenes.add(scene);
    }

    public Color back_color { get; set; }
    public Size2i screen_size { get; private set; }

    public ArrayList<RenderScene> scenes { get; private set; }
}
