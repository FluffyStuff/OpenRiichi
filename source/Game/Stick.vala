using GL;

public class Stick
{
    private const float SIZE = 0.1f;
    private const float size = 0.25f;
    public const float WIDTH = 5.5f * size;
    public const float HEIGHT = 0.5f * size;
    public const float LENGTH = 0.3f * size;

    private Texture tile_texture;

    public Stick(string name, int points)
    {
        tile_texture = Texture.load_texture("sticks/" + name);
        this.points = points;
        this.position = new Vector.empty();
        this.rotation = new Vector.empty();
        //visible = true;
    }

    public void render()
    {
        if (!visible)
            return;

        glPushMatrix();

            glTranslatef((GLfloat)position.x, (GLfloat)position.y, (GLfloat)position.z);
            glRotatef((GLfloat)(rotation.x / 1.0f), 1, 0, 0);
            glRotatef((GLfloat)(rotation.y / 1.0f), 0, 1, 0);
            glRotatef((GLfloat)(rotation.z / 1.0f), 0, 0, 1);

            glTranslatef(0, (GLfloat)HEIGHT / 2, 0);
            glScalef((GLfloat)WIDTH, (GLfloat)HEIGHT, (GLfloat)LENGTH);

            glColor3f(1, 1, 1);
            render_box();

        glPopMatrix();
    }

    private void render_side(float size)
    {
        glBegin(GL_QUADS);
            glVertex3f(-(GLfloat)size, -(GLfloat)size, -(GLfloat)size);
            glVertex3f(-(GLfloat)size, (GLfloat)size, -(GLfloat)size);
            glVertex3f((GLfloat)size, (GLfloat)size, -(GLfloat)size);
            glVertex3f((GLfloat)size, -(GLfloat)size, -(GLfloat)size);
        glEnd();
    }

    private void render_texture(float size)
    {
        glTranslatef(0, 0, (GLfloat)size);

        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, tile_texture.texture);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);

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

        //glEnable(GL_LIGHTING);
        glDisable(GL_TEXTURE_2D);
    }

    private void render_box()
    {
        //if ((cubePart & CUBE_BACK) != 0)
        glPushMatrix();
            render_texture(size);
        glPopMatrix();

        //if ((cubePart & CUBE_FRONT) != 0)
        glPushMatrix();
            glRotatef(180, 1, 0, 0);
            render_texture(size);
        glPopMatrix();

        //if ((cubePart & CUBE_TOP) != 0)
        glPushMatrix();
            glRotatef(90, 1, 0, 0);
            render_side(size);
        glPopMatrix();

        //if ((cubePart & CUBE_BOTTOM) != 0)
        glPushMatrix();
            glRotatef(-90, 1, 0, 0);
            render_side(size);
        glPopMatrix();

        //if ((cubePart & CUBE_LEFT) != 0)
        glPushMatrix();
            glRotatef(90, 0, 1, 0);
            render_side(size);
        glPopMatrix();

        //if ((cubePart & CUBE_RIGHT) != 0)
        glPushMatrix();
            glRotatef(-90, 0, 1, 0);
            render_side(size);
        glPopMatrix();
    }

    public int points { get; private set; }
    public Vector position { get; set; }
    public Vector rotation { get; set; }
    public bool visible { get; set; }
}
