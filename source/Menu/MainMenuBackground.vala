using GL;

public class MainMenuBackground
{
    private Texture table_texture;
    private Tile tile;

    private double rotation = 0;

    public MainMenuBackground()
    {
        table_texture = Texture.load_texture("table");
        tile = new Tile(1, -1, TILE_TYPE.PIN1);
        tile.position = new Vector(0, -Tile.TILE_HEIGHT / 2, 0);
    }

    public void process(double dt)
    {
        rotation += dt * 1;
    }

    public void render()
    {
        float tex_u_max = 10.0f;
        float tex_v_max = 10.0f;
        float size = 1;

        glRotatef(-(GLfloat)rotation, 0, 0, 1);

        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, table_texture.texture);
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

        tile.render();
    }
}
