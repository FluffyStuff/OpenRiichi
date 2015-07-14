using Gee;

public class RenderScene2D : RenderScene
{
    ArrayList<RenderObject2D> objs = new ArrayList<RenderObject2D>();

    public RenderScene2D(int width, int height)
    {
        this.width = width;
        this.height = height;
    }

    public void add_object(RenderObject2D object)
    {
        objs.add(object.copy());
    }

    public ArrayList<RenderObject2D> objects { get { return objs; } }
    public int width { get; private set; }
    public int height { get; private set; }
}
