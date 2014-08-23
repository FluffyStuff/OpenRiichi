using GL;
using Gee;

public class Texture
{
    private static ArrayList<Texture> textures;

    public static Texture? load_texture(string name)
    {
        if (textures == null)
            textures = new ArrayList<Texture>();
        int id = 1;

        foreach (Texture t in textures)
            if (t.name == name)
                return t;
            else if (t.id >= id)
                id = t.id + 1;

        GLuint texture = (GLuint)SOIL.load_OGL_texture("textures/" + name + ".png", SOIL.LoadFlags.AUTO, id, 0);

        if (texture > 0)
            return new Texture(name, id, texture);
        return null;
    }

    public static void clear_cache()
    {
        textures.clear();
    }

    private static void free_texture(Texture texture)
    {
        textures.remove(texture);
        glDeleteTextures(1, new GLuint[] { texture.texture });
    }

    private Texture(string name, int id, GLuint texture)
    {
        this.name = name;
        this.id = id;
        this.texture = texture;

        textures.add(this);
    }

    ~Texture()
    {
        free_texture(this);
    }

    public string name { get; private set; }
    public int id { get; private set; }
    public GLuint texture { get; private set; }
}
