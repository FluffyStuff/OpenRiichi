using GL;
using Gee;

public class Tile
{
    private const float tile_size = 0.1f;
    public const float TILE_WIDTH = 1.94f * tile_size;
    public const float TILE_HEIGHT = 2.6f * tile_size;
    public const float TILE_LENGTH = 1.59f * tile_size;
    public const float TILE_SPACING = 0.005f;

    private const float HOVER_MULT = 2.5f;
    private const float HOVER_ADD = 1 - 1 / ((HOVER_MULT - 1) / 3 + 1);

    private Texture tile_texture;

    public Tile(float size, int id, int type)
    {
        this.size = size / 2;
        tile_type = type;
        this.id = id;
        position = new Vector.empty();
        rotation = new Vector.empty();

        string name;

        if (type <= 8)
            name = "Man" + (type+1).to_string();
        else if (type <= 17)
            name = "Pin" + ((type%9)+1).to_string();
        else if (type <= 26)
            name = "Sou" + ((type%9)+1).to_string();
        else if (type == 27)
            name = "Higashi";
        else if (type == 28)
            name = "Minami";
        else if (type == 29)
            name = "Nishi";
        else if (type == 30)
            name = "Kita";
        else if (type == 31)
            name = "Haku";
        else if (type == 32)
            name = "Hatsu";
        else if (type == 33)
            name = "Chun";
        else
            name = "";

        this.name = name;

        tile_texture = Texture.load_texture("tiles/" + name);
    }

    const int CUBE_NONE = 0;
    const int CUBE_TOP = 1;
    const int CUBE_BOTTOM = 2;
    const int CUBE_LEFT = 4;
    const int CUBE_RIGHT = 8;
    const int CUBE_FRONT = 16;
    const int CUBE_BACK = 32;
    const int CUBE_ALL = 63;

    private void renderSide(float size)
    {
        glBegin(GL_QUADS);
            glVertex3f(-(GLfloat)size, -(GLfloat)size, -(GLfloat)size);
            glVertex3f(-(GLfloat)size, (GLfloat)size, -(GLfloat)size);
            glVertex3f((GLfloat)size, (GLfloat)size, -(GLfloat)size);
            glVertex3f((GLfloat)size, -(GLfloat)size, -(GLfloat)size);
        glEnd();
    }

    private void renderPartialCube(float size, int cubePart)
    {
        size /= 2;

        if ((cubePart & CUBE_BACK) != 0)
        {
            glPushMatrix();
                renderSide(size);
            glPopMatrix();
        }

        if ((cubePart & CUBE_FRONT) != 0)
        {
            glPushMatrix();
                glRotatef(180, 1, 0, 0);
                renderSide(size);
            glPopMatrix();
        }

        if ((cubePart & CUBE_TOP) != 0)
        {
            glPushMatrix();
                glRotatef(90, 1, 0, 0);
                renderSide(size);
            glPopMatrix();
        }

        if ((cubePart & CUBE_BOTTOM) != 0)
        {
            glPushMatrix();
                glRotatef(-90, 1, 0, 0);
                renderSide(size);
            glPopMatrix();
        }

        if ((cubePart & CUBE_LEFT) != 0)
        {
            glPushMatrix();
                glRotatef(90, 0, 1, 0);
                renderSide(size);
            glPopMatrix();
        }

        if ((cubePart & CUBE_RIGHT) != 0)
        {
            glPushMatrix();
                glRotatef(-90, 0, 1, 0);
                renderSide(size);
            glPopMatrix();
        }
    }

    private void renderBackBox()
    {
        glPushMatrix();
            glTranslatef(0, 0, (GLfloat)(size * 0.2));
            glScalef(1, 1, (GLfloat)0.2);
            renderPartialCube(size * 2, CUBE_ALL & ~CUBE_FRONT);
        glPopMatrix();
    }

    private void renderFrontBox(bool front)
    {
        glScalef(1, 1, (GLfloat)0.8);
        glTranslatef(0, 0, (GLfloat)(size * 1.5));
        renderPartialCube(size * 2, CUBE_ALL & ~(front ? 0 : CUBE_FRONT) & ~CUBE_BACK);
    }

    private void renderFront()
    {
        glTranslatef(0, 0, (GLfloat)size);

        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, tile_texture.texture);
        glDisable(GL_LIGHTING);
        glEnable(GL_COLOR_SUM);

        float add = hovering ? HOVER_ADD : 0;
        glSecondaryColor3f((GLfloat)add, (GLfloat)add, (GLfloat)add);
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

        glDisable(GL_COLOR_SUM);
        glEnable(GL_LIGHTING);
        glDisable(GL_TEXTURE_2D);
    }

    public void render()
    {
        float colorMult = hovering ? HOVER_MULT : 1;

        glPushMatrix();

            glTranslatef((GLfloat)position.x, (GLfloat)position.y, (GLfloat)position.z);
            //glRotatef(90, (GLfloat)(rotation.x / 360.0f), (GLfloat)(rotation.y / 360.0f), (GLfloat)(rotation.z / 360.0f));
            glRotatef((GLfloat)(rotation.x / 1.0f), 1, 0, 0);
            glRotatef((GLfloat)(rotation.y / 1.0f), 0, 1, 0);
            glRotatef((GLfloat)(rotation.z / 1.0f), 0, 0, 1);

            glTranslatef(0, (GLfloat)TILE_HEIGHT / 2, 0);
            glScalef((GLfloat)TILE_WIDTH, (GLfloat)TILE_HEIGHT, (GLfloat)TILE_LENGTH);

            glColor3f((GLfloat)(1 * colorMult), (GLfloat)(0.8 * colorMult), (GLfloat)(0.2 * colorMult));
            renderBackBox();

            glColor3f((GLfloat)(245 / 255.0 * colorMult), (GLfloat)(245 / 255.0 * colorMult), (GLfloat)(233 / 255.0 * colorMult));
            renderFrontBox(false);

            glColor3f((GLfloat)colorMult + 2, (GLfloat)colorMult + 2, (GLfloat)colorMult + 2);
            renderFront();

        glPopMatrix();
    }

    public void render_selection()
    {
        uint r = (color_ID >> 16) % 256;
        uint g = (color_ID >> 8) % 256;
        uint b = color_ID % 256;

        glDisable(GL_LIGHTING);
        glPushMatrix();

            glTranslatef((GLfloat)position.x, (GLfloat)position.y, (GLfloat)position.z);
            glRotatef((GLfloat)(rotation.x / 1.0f), 1, 0, 0);
            glRotatef((GLfloat)(rotation.y / 1.0f), 0, 1, 0);
            glRotatef((GLfloat)(rotation.z / 1.0f), 0, 0, 1);

            glTranslatef(0, (GLfloat)TILE_HEIGHT / 2, 0);
            glScalef((GLfloat)TILE_WIDTH, (GLfloat)TILE_HEIGHT, (GLfloat)TILE_LENGTH);

            glColor3f((GLfloat)(r / 255.0f), (GLfloat)(g / 255.0f), (GLfloat)(b / 255.0f));
            renderBackBox();
            renderFrontBox(true);

        glPopMatrix();
        glEnable(GL_LIGHTING);
    }

    public static void sort_tiles(ArrayList<Tile> tiles)
    {
        while (true)
        {
            bool sorted = true;

            for (int i = 0; i < tiles.size - 1; i++)
            {
                if (tiles[i].tile_type > tiles[i+1].tile_type)
                {
                    Tile t = tiles[i];
                    tiles[i] = tiles[i+1];
                    tiles[i+1] = t;
                    sorted = false;
                }
            }

            if (sorted)
                break;
        }
    }

    public string name { get; private set; }
    public Vector position { get; set; }
    public Vector rotation { get; set; }
    public uint color_ID { get; set; }
    public bool hovering { get; set; }
    public float size { get; private set; }
    public int tile_type { get; private set; }
    public int id { get; private set; }
}
