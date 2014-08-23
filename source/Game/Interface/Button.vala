using GL;

public class Button
{
    public signal void press();
    private Texture texture;
    private bool press_down = false;
    private bool hovering = false;

    public Button(string name, uint color_id)
    {
        this.name = name;
        texture = Texture.load_texture("interface/" + name);
        this.color_id = color_id;
        position = new Vector.empty();
        visible = false;
        size = 0.1f;
        width = 0.5f;
        height = 0.5f;
    }

    public bool hover(uint color_id)
    {
        if (!(hovering = this.color_id == color_id))
            press_down = false;

        return hovering;
    }

    public bool click(uint color_id, bool up)
    {
        hover(color_id);

        if (!hovering)
            return false;

        if (!up)
            press_down = true;
        else if (press_down)
        {
            press();
            press_down = false;
            return true;
        }

        return false;
    }

    public void render()
    {
        if (!visible)
            return;

        glPushMatrix();
            glPushAttrib(GL_ALL_ATTRIB_BITS);
            glTranslatef((GLfloat)position.x, (GLfloat)position.y, (GLfloat)position.z);

            if (press_down)
                glColor3f((GLfloat)0.5, (GLfloat)0.5, (GLfloat)0.5);
            else
            {
                float add = hovering ? 0.25f : 0;
                glSecondaryColor3f((GLfloat)add, (GLfloat)add, (GLfloat)add);
            }

            glBindTexture(GL_TEXTURE_2D, texture.texture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
            glScalef((GLfloat)width, (GLfloat)height, 1);

            glBegin(GL_QUADS);
                glTexCoord2f(0, 1);
                glVertex3f(-(GLfloat)size, -(GLfloat)size, 0);
                glTexCoord2f(1, 1);
                glVertex3f((GLfloat)size, -(GLfloat)size, 0);
                glTexCoord2f(1, 0);
                glVertex3f((GLfloat)size, (GLfloat)size, 0);
                glTexCoord2f(0, 0);
                glVertex3f(-(GLfloat)size, (GLfloat)size, 0);
            glEnd();
            glPopAttrib();
        glPopMatrix();
    }

    public void render_selection()
    {
        if (!visible)
            return;

        glPushMatrix();
            glTranslatef((GLfloat)position.x, (GLfloat)position.y, (GLfloat)position.z);
            glDepthFunc(GL_LEQUAL);

            uint r = (color_id >> 16) % 256;
            uint g = (color_id >> 8) % 256;
            uint b = color_id % 256;
            glColor3f((GLfloat)(r / 255.0f), (GLfloat)(g / 255.0f), (GLfloat)(b / 255.0f));
            glScalef((GLfloat)width, (GLfloat)height, 1);

            glBegin(GL_QUADS);
                glVertex3f(-(GLfloat)size, -(GLfloat)size, 0);
                glVertex3f((GLfloat)size, -(GLfloat)size, 0);
                glVertex3f((GLfloat)size, (GLfloat)size, 0);
                glVertex3f(-(GLfloat)size, (GLfloat)size, 0);
            glEnd();
        glPopMatrix();
    }

    public string name { get; private set; }
    public uint color_id { get; private set; }
    public Vector position { get; set; }
    public float size { get; set; }
    public float width { get; private set; }
    public float height { get; private set; }
    public bool visible { get; set; }
}
