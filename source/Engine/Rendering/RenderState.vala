using Gee;

public class RenderState
{
    public RenderState(int screen_width, int screen_height)
    {
        this.screen_width = screen_width;
        this.screen_height = screen_height;

        scenes = new ArrayList<RenderScene>();
    }

    public void add_scene(RenderScene scene)
    {
        scenes.add(scene);
    }

    public Color back_color { get; set; }
    public int screen_width { get; private set; }
    public int screen_height { get; private set; }

    public ArrayList<RenderScene> scenes { get; private set; }
}
