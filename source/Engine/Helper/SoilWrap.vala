// libSOIL is not thread safe, so let's use this thread safe wrapper
public class SoilWrap : Object
{
    private static Mutex mutex = Mutex();

    private SoilWrap() {}

    public static SoilImage load_image(string name)
    {
        int width, height;

        mutex.lock();
        uchar *image = SOIL.load_image(name, out width, out height, null, SOIL.LoadFlags.RGBA);
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
