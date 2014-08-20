using GL;

public class Button
{
    private Texture texture;

    public Button(ButtonEnum button, uint color_id)
    {
        string name;

        switch (button)
        {
        case ButtonEnum.CONTINUE:
            name = "Continue";
            break;
        case ButtonEnum.PON:
            name = "Pon";
            break;
        case ButtonEnum.KAN:
            name = "Kan";
            break;
        case ButtonEnum.CHI:
            name = "Chi";
            break;
        case ButtonEnum.RIICHI:
            name = "Riichi";
            break;
        case ButtonEnum.TSUMO:
            name = "Tsumo";
            break;
        case ButtonEnum.RON:
            name = "Ron";
            break;
        default:
            name = "";
            break;
        }

        this.button = button;
        texture = Texture.load_texture("interface/" + name);
        this.color_id = color_id;
        position = new Vector.empty();
        visible = false;
        size = 0.1f;
        width = 0.5f;
        height = 0.5f;
    }

    public void render()
    {
        if (!visible)
            return;

        glPushMatrix();
        glTranslatef((GLfloat)position.x, (GLfloat)position.y, (GLfloat)position.z);

        float add = hovering ? 0.25f : 0;
        glSecondaryColor3f((GLfloat)add, (GLfloat)add, (GLfloat)add);

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

    public ButtonEnum button { get; private set; }
    public uint color_id { get; private set; }
    public Vector position { get; set; }
    public float size { get; private set; }
    public float width { get; private set; }
    public float height { get; private set; }
    public bool hovering { get; set; }
    public bool visible { get; set; }

    public enum ButtonEnum
    {
        NONE,
        CONTINUE,
        PON,
        KAN,
        CHI,
        RIICHI,
        TSUMO,
        RON
    }
}
