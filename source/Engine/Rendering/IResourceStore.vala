using Gee;

public abstract class IResourceStore : Object
{
    private AudioPlayer audio = new AudioPlayer();
    private LabelLoader label_loader = new LabelLoader();

    public RenderObject3D? load_object_3D(string name)
    {
        RenderModel? model = load_model(name, false);
        RenderTexture? texture = load_texture(name, false);
        RenderObject3D obj = new RenderObject3D(model, texture);
        return obj;
    }

    public RenderModel? load_model(string name, bool center)
    {
        return load_model_dir(MODEL_DIR, name, center);
    }

    public RenderTexture? load_texture(string name, bool tile)
    {
        return load_texture_dir(TEXTURE_DIR, name, tile);
    }

    public LabelInfo update_label(string font_type, float font_size, string text)
    {
        return label_loader.get_label_info(font_type, font_size, text);
    }

    public LabelBitmap generate_label_bitmap(RenderLabel2D label)
    {
        return label_loader.generate_label_bitmap(label.font_type, label.font_size, label.text);
    }

    public AudioPlayer audio_player { get { return audio; } }

    public abstract RenderModel? load_model_dir(string dir, string name, bool center);
    public abstract RenderTexture? load_texture_dir(string dir, string name, bool tile);
    public abstract RenderLabel2D? create_label();
    public abstract void delete_label(LabelResourceReference reference);

    private const string DATA_DIR = "./Data/";
    protected const string MODEL_DIR = DATA_DIR + "Models/";
    protected const string TEXTURE_DIR = DATA_DIR + "Textures/";
}

public class ResourceModel
{
    public ResourceModel(ModelPoint[] points)
    {
        this.points = points;
    }

    public ModelPoint[] points { get; private set; }
}

public class ResourceTexture
{
    public ResourceTexture(char *data, Size2i size, bool tile)
    {
        this.data = data;
        this.size = size;
        this.tile = tile;
    }

    ~ResourceTexture()
    {
        delete data;
    }

    public char *data { get; private set; }
    public Size2i size { get; private set; }
    public bool tile { get; private set; }
}

public class ResourceLabel {}

public class LabelResourceReference
{
    weak IResourceStore store;

    public LabelResourceReference(uint handle, IResourceStore store)
    {
        this.handle = handle;
        this.store = store;
    }

    public LabelInfo update(string font_type, float font_size, string text)
    {
        return store.update_label(font_type, font_size, text);
    }

    public void delete()
    {
        handle = 0;
        deleted = true;

        store.delete_label(this);
    }

    public bool deleted { get; private set; }
    public uint handle { get; private set; }
}

public class RenderModel : Object
{
    public RenderModel(uint handle, Vec3 center, Vec3 size)
    {
        this.handle = handle;
        //this.center = center;
        this.size = size;
    }

    public uint handle { get; private set; }
    //public Vec3 center { get; private set; }
    public Vec3 size { get; private set; }
}

public class RenderTexture : Object
{
    public RenderTexture(uint handle, Size2i size, bool tile)
    {
        this.handle = handle;
        this.size = size;
        this.tile = tile;
    }

    public uint handle { get; private set; }
    public Size2i size { get; private set; }
    public bool tile { get; private set; }
}
