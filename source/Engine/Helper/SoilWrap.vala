// libSOIL is not thread safe, so let's use this thread safe wrapper
public class SoilWrap : Object
{
    private static Mutex mutex = new Mutex();

    private SoilWrap() {}

    // Need this for static fields
    public static void static_init()
    {
        if (typeof(SoilWrap).class_peek() == null)
            typeof(SoilWrap).class_ref();
    }

    public static SoilImage load_image(string name)
    {
        static_init();

        int width, height;

        mutex.lock();
        uchar *image = SOIL.load_image(name, out width, out height, null, SOIL.LoadFlags.RGB);
        mutex.unlock();

        return new SoilImage((char*)image, width, height);
    }
}

public class SoilImage
{
    public SoilImage(char *data, int width, int height)
    {
        this.data = data;
        this.width = width;
        this.height = height;
    }

    public char *data { get; private set; }
    public int width { get; private set; }
    public int height { get; private set; }
}
