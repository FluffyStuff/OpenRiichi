using SDL;
using GL;

public class Mahjong
{
    const GLfloat light_ambient[]  = { (GLfloat)0.0f, (GLfloat)0.0f, (GLfloat)0.0f, (GLfloat)1.0f };
    const GLfloat light_diffuse[]  = { (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f };
    const GLfloat light_specular[] = { (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f };
    const GLfloat light_position[] = { (GLfloat)2.0f, (GLfloat)5.0f, (GLfloat)5.0f, (GLfloat)0.0f };

    const GLfloat mat_ambient[]    = { (GLfloat)0.7f, (GLfloat)0.7f, (GLfloat)0.7f, (GLfloat)1.0f };
    const GLfloat mat_diffuse[]    = { (GLfloat)0.8f, (GLfloat)0.8f, (GLfloat)0.8f, (GLfloat)1.0f };
    const GLfloat mat_specular[]   = { (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f, (GLfloat)1.0f };
    const GLfloat high_shininess[] = { (GLfloat)100.0f };

    private unowned Window window;
    private GLContext context;

    private bool do_move = false;
    private int last_x = 0;
    private int last_y = 0;
    private int rot_x = 0;
    private int rot_y = 70;
    private uint color_ID = 0;

    private int focal_length = 2;
    private float distance = 12;

    private bool fullscreen = false;
    private bool exit = false;
    private bool restart = false;

    private Game game;

    public bool init(Window window)
    {
        this.window = window;
        if ((context = SDL.GL.create_context(window)) == null)
            return false;
        else
        {
            // Note: Glew needs to be initialized after a context has been created (every time)
            GLEW.init();

            glEnable(GL_CULL_FACE);
            glEnable(GL_DEPTH_TEST);
            glDepthFunc(GL_LEQUAL);

            glEnable(GL_LINE_SMOOTH);
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glShadeModel(GL_SMOOTH);

            glEnable(GL_LIGHT0);
            glEnable(GL_NORMALIZE);
            glEnable(GL_COLOR_MATERIAL);
            glEnable(GL_LIGHTING);

            glLightfv(GL_LIGHT0, GL_AMBIENT,  light_ambient);
            glLightfv(GL_LIGHT0, GL_DIFFUSE,  light_diffuse);
            glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
            glLightfv(GL_LIGHT0, GL_POSITION, light_position);

            glMaterialfv(GL_FRONT, GL_AMBIENT,   mat_ambient);
            glMaterialfv(GL_FRONT, GL_DIFFUSE,   mat_diffuse);
            glMaterialfv(GL_FRONT, GL_SPECULAR,  mat_specular);
            glMaterialfv(GL_FRONT, GL_SHININESS, high_shininess);

            // The game needs to be instantiated after a context has been created, so that images can be loaded
            game = new Game();
            window.set_size(Environment.ORIGINAL_WINDOW_WIDTH, Environment.ORIGINAL_WINDOW_HEIGHT);
            resize();

            window.show();
        }

        return true;
    }

    public bool loop()
    {
        Event e;

        while (!exit)
        {
            while (Event.poll(out e) != 0)
            {
                if (e.type == EventType.QUIT)
                    exit = true;
                else if (e.type == EventType.KEYDOWN)
                {
                    key(e.key.keysym.sym);
                }
                else if (e.type == EventType.MOUSEMOTION)
                {
                    int x = 0, y = 0;
                    Cursor.get_state(ref x, ref y);
                    mouse_move(x, y);
                }
                else if (e.type == EventType.MOUSEBUTTONDOWN || e.type == EventType.MOUSEBUTTONUP)
                {
                    int x = 0, y = 0;
                    Cursor.get_state(ref x, ref y);
                    mouse(e.button.button, e.type == EventType.MOUSEBUTTONUP, x, y);
                }
                else if (e.type == EventType.MOUSEWHEEL)
                {
                    mouse_wheel(e.wheel.y);
                }
                else if (e.type == EventType.WINDOWEVENT && e.window.event == WindowEventID.SIZE_CHANGED)
                {
                    resize();
                }
            }

            game.process();
            display();
            SDL.Timer.delay(1); // 1000 FPS limit
        }

        return restart;
    }

    ~Mahjong()
    {
        SDL.GL.delete_context(context);
        Texture.clear_cache();
    }

    private void mouse(int button, bool state, int x, int y)
    {
        if (button == 3)
        {
            last_x = x;
            last_y = y;

            do_move = !state;
        }

        if (button == 1 && state)
        {
            int width, height;
            window.get_size(out width, out height);
            game.mouse_click(x, height - y, color_ID);
        }
    }

    private void mouse_move(int x, int y)
    {
        if (do_move)
        {
            rot_x += x - last_x;
            rot_y += y - last_y;
            last_x = x;
            last_y = y;

            rot_x = int.min(int.max(rot_x, -85), 85);
            rot_y = int.min(int.max(rot_y, -50), 120);
        }

        int width, height;
        window.get_size(out width, out height);
        game.mouse_move(x, height - y, color_ID);
    }

    private void mouse_wheel(int amount)
    {
        distance -= distance * (amount / 30.0f);
        distance = float.min(float.max(distance, 8.5f), 15);
    }

    private void key(char key)
    {
        switch (key)
        {
            case 27 :
            case 'q':
                exit = true;
                break;
            case 'f':
                toggle_fullscreen();
                break;
            case 'r':
                restart = true;
                exit = true;
                break;
        }
    }

    private void toggle_fullscreen()
    {
        window.set_fullscreen((fullscreen = !fullscreen) ? WindowFlags.FULLSCREEN_DESKTOP : 0);
    }

    private void display()
    {
        // TODO: Add delta time
        /*const double t = glutGet(GLUT_ELAPSED_TIME);
        const double dt = t - lastTime;
        lastTime = t;*/

        double a = (double)rot_x / 3;
        double b = (double)rot_y / 3;

        glClearColor(0, (GLfloat)0.1, (GLfloat)0.2, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glPushMatrix();
            glTranslatef(0, 1, 0);
            glTranslatef(0, 0, -(GLfloat)distance);
            glRotatef(-60, 1, 0, 0);
            //glRotatef(-90, 1, 0, 0);

            glRotated((GLdouble)b, 1, 0, 0);
            glRotated((GLdouble)a, 0, 0, 1);

            glScalef(focal_length, focal_length, focal_length);

            glPushMatrix();
                game.render();
            glPopMatrix();

        glPopMatrix();
        glPushMatrix();
            glPushAttrib(GL_ALL_ATTRIB_BITS);
                setup_projection(true);
                glClear(GL_DEPTH_BUFFER_BIT);
                game.render_interface();
            glPopAttrib();
        glPopMatrix();
        glPushMatrix();
            setup_projection(false);

            SDL.GL.swap_window(window);

            // Draw the clickable objects and get hovered object
            //glClearColor(255, 255, 255, 0);
            glClearColor(0, 0, 0, 0);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            glTranslatef(0, 1, 0);
            glTranslatef(0, 0, -(GLfloat)distance);
            glRotatef(-60, 1, 0, 0);

            glRotated((GLdouble)b, 1, 0, 0);
            glRotated((GLdouble)a, 0, 0, 1);

            glScalef(focal_length, focal_length, focal_length);

            game.render_selection();

        glPopMatrix();
        glPushMatrix();
            glPushAttrib(GL_ALL_ATTRIB_BITS);
                setup_projection(true);
                glClear(GL_DEPTH_BUFFER_BIT);
                game.render_interface_selection();
            glPopAttrib();
        glPopMatrix();
        glPushMatrix();

            setup_projection(false);
            color_ID = get_color_ID();

        glPopMatrix();
    }

    private uint get_color_ID()
    {
        uchar color[3];
        int x = 0, y = 0, width, height;
        Cursor.get_state(ref x, ref y);
        window.get_size(out width, out height);
        glReadPixels((GLint)x, (GLint)(height - y), 1, 1, GL_RGB, GL_UNSIGNED_BYTE, (GLvoid[])color);
        return ((uint)color[0] << 16) + ((uint)color[1] << 8) + (uint)color[2];
    }

    private void setup_projection(bool ortho)
    {
        int width, height;
        window.get_size(out width, out height);

        float ar = (float) width / (float) height;
        glViewport(0, 0, (GLsizei)width, (GLsizei)height);

        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        if (ortho)
            glOrtho(0, 0, 0, 0, 0, 0);
        else
            glFrustum(-(GLdouble)ar, (GLdouble)ar, -(GLdouble)1.0, (GLdouble)1.0, focal_length, (GLdouble)1000.0);

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
    }

    private void resize()
    {
        int width, height;
        window.get_size(out width, out height);

        float ar = (float) width / (float) height;

        glViewport(0, 0, (GLsizei)width, (GLsizei)height);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glFrustum(-(GLdouble)ar, (GLdouble)ar, -(GLdouble)1.0, (GLdouble)1.0, focal_length, (GLdouble)1000.0);

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
    }
}
