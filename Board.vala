using GL;

public class Board
{
    private float size;
    private float border_size;
    private Texture field_texture;
    private Texture wood_texture;

    public Board(float size)
    {
        this.size = size / 2;
        border_size = size / 30;
        field_texture = Texture.load_texture("table");
        wood_texture = Texture.load_texture("wood");

        if (field_texture == null || wood_texture == null)
            exit(0);
    }

    public void render()
    {
        glDisable(GL_LIGHTING);

        float tex_u_max = 10.0f;
        float tex_v_max = 10.0f;

        glColor3d(1, 1, 1);
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, field_texture.texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);

        glBegin(GL_QUADS);

            glTexCoord2f((GLfloat)0.0f, (GLfloat)tex_v_max);
            glVertex3f(-(GLfloat)size, -(GLfloat)size, 0);
            glTexCoord2f((GLfloat)tex_u_max, (GLfloat)tex_v_max);
            glVertex3f((GLfloat)size, -(GLfloat)size, 0);
            glTexCoord2f((GLfloat)tex_u_max, (GLfloat)0.0f);
            glVertex3f((GLfloat)size, (GLfloat)size, 0);
            glTexCoord2f((GLfloat)0.0f, (GLfloat)0.0f);
            glVertex3f(-(GLfloat)size, (GLfloat)size, 0);

        glEnd();

        /* -------------- Border ---------------- */

        glBindTexture(GL_TEXTURE_2D, wood_texture.texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);

        glBegin(GL_QUADS);

            //Bottom

            glTexCoord2f(0, 1);
            glVertex3f(-(GLfloat)size - (GLfloat)border_size, -(GLfloat)size - (GLfloat)border_size, 0);

            glTexCoord2f((GLfloat)tex_u_max, 1);
            glVertex3f((GLfloat)size, -(GLfloat)size - (GLfloat)border_size, 0);

            glTexCoord2f((GLfloat)tex_u_max, 0);
            glVertex3f((GLfloat)size, -(GLfloat)size, 0);

            glTexCoord2f(0, 0);
            glVertex3f(-(GLfloat)size - (GLfloat)border_size, -(GLfloat)size, 0);

            // Right

            glTexCoord2f(0, 0);
            glVertex3f((GLfloat)size, -(GLfloat)size - (GLfloat)border_size, 0);

            glTexCoord2f(0, 1);
            glVertex3f((GLfloat)size + (GLfloat)border_size, -(GLfloat)size - (GLfloat)border_size, 0);

            glTexCoord2f((GLfloat)tex_u_max, 1);
            glVertex3f((GLfloat)size + (GLfloat)border_size, (GLfloat)size, 0);

            glTexCoord2f((GLfloat)tex_u_max, 0);
            glVertex3f((GLfloat)size, (GLfloat)size, 0);

            // Top

            glTexCoord2f(0, 0);
            glVertex3f((GLfloat)size + (GLfloat)border_size, (GLfloat)size, 0);

            glTexCoord2f(0, 1);
            glVertex3f((GLfloat)size + (GLfloat)border_size, (GLfloat)size + (GLfloat)border_size, 0);

            glTexCoord2f((GLfloat)tex_u_max, 1);
            glVertex3f(-(GLfloat)size, (GLfloat)size + (GLfloat)border_size, 0);

            glTexCoord2f((GLfloat)tex_u_max, 0);
            glVertex3f(-(GLfloat)size, (GLfloat)size, 0);

            // Left

            glTexCoord2f(0, 0);
            glVertex3f(-(GLfloat)size, (GLfloat)size + (GLfloat)border_size, 0);

            glTexCoord2f(0, 1);
            glVertex3f(-(GLfloat)size - (GLfloat)border_size, (GLfloat)size + (GLfloat)border_size, 0);

            glTexCoord2f((GLfloat)tex_u_max, 1);
            glVertex3f(-(GLfloat)size - (GLfloat)border_size, -(GLfloat)size, 0);

            glTexCoord2f((GLfloat)tex_u_max, 0);
            glVertex3f(-(GLfloat)size, -(GLfloat)size, 0);

        glEnd();

        glDisable(GL_TEXTURE_2D);
        glEnable(GL_LIGHTING);
    }
}
