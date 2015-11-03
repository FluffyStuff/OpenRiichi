using Gee;

public class RenderScene2D : RenderScene
{
    ArrayList<RenderObject2D> objs = new ArrayList<RenderObject2D>();

    public RenderScene2D(Rectangle rect)
    {
        this.rect = rect;
    }

    public void add_object(RenderObject2D object)
    {
        objs.add(object.copy());
    }

    public ArrayList<RenderObject2D> objects { get { return objs; } }
    public Rectangle rect { get; private set; }
}
