using SDL;
using GL;

public class MainWindow
{
    private unowned Window window;

    private View view;
    private bool fullscreen = false;
    private uint color_id;

    private bool exit = false;
    private bool restart = false;

    private int focal_length = 2;
    private GameNetworking net = new GameNetworking();

    private MainMenu menu;

    public MainWindow(Window window)
    {
        this.window = window;
        menu = new MainMenu(window);
        view = menu;
        menu.menu_action.connect(menu_action);
    }

    ~MainWindow()
    {
        menu.menu_action.disconnect(menu_action);
    }

    private void menu_action(MainMenu m)
    {
        switch (m.action)
        {
        case MainMenu.MenuAction.SINGLE_PLAYER:
            view = new Mahjong(window);
            break;
        case MainMenu.MenuAction.HOST_MULTI_PLAYER:
            net.host();
            break;
        case MainMenu.MenuAction.JOIN_MULTI_PLAYER:
            net.join("localhost");
            break;
        case MainMenu.MenuAction.EXIT:
            exit = true;
            break;
        }
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
                    key(e.key.keysym.sym);
                else if (e.type == EventType.MOUSEMOTION)
                {
                    int x = 0, y = 0, width, height;
                    Cursor.get_state(ref x, ref y);
                    window.get_size(out width, out height);
                    view.mouse_move(x, height - y, color_id);
                }
                else if (e.type == EventType.MOUSEBUTTONDOWN || e.type == EventType.MOUSEBUTTONUP)
                {
                    int x = 0, y = 0, width, height;
                    Cursor.get_state(ref x, ref y);
                    window.get_size(out width, out height);
                    view.mouse_click(x, height - y, e.button.button, e.type == EventType.MOUSEBUTTONUP, color_id);
                }
                else if (e.type == EventType.MOUSEWHEEL)
                    view.mouse_wheel(e.wheel.y);
            }

            view.process(0.1);
            render();
        }

        return restart;
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

    private uint get_color_id()
    {
        uchar color[3];
        int x = 0, y = 0, width, height;
        Cursor.get_state(ref x, ref y);
        window.get_size(out width, out height);
        glReadPixels((GLint)x, (GLint)(height - y), 1, 1, GL_RGB, GL_UNSIGNED_BYTE, (GLvoid[])color);
        return ((uint)color[0] << 16) + ((uint)color[1] << 8) + (uint)color[2];
    }

    private void render()
    {
        color_id = get_color_id();
        glPushMatrix();
            glPushAttrib(GL_ALL_ATTRIB_BITS);
            setup_projection(false);
            glClear(GL_DEPTH_BUFFER_BIT);
            glClearColor(0, (GLfloat)0.1, (GLfloat)0.2, 0);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            view.render();
            glPopAttrib();
        glPopMatrix();

        glPushMatrix();
            glPushAttrib(GL_ALL_ATTRIB_BITS);
            setup_projection(true);
            glClear(GL_DEPTH_BUFFER_BIT);

            glDisable(GL_DEPTH_TEST);
            glDisable(GL_LIGHTING);
            glEnable(GL_TEXTURE_2D);
            glEnable(GL_COLOR_SUM);
            glDepthFunc(GL_LEQUAL);
            view.render_interface();

            glPopAttrib();
        glPopMatrix();

        SDL.GL.swap_window(window);

        glPushMatrix();
            glPushAttrib(GL_ALL_ATTRIB_BITS);
            setup_projection(false);
            glClearColor(0, 0, 0, 0);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            view.render_selection();
            glPopAttrib();
        glPopMatrix();

        glPushMatrix();
            glPushAttrib(GL_ALL_ATTRIB_BITS);
            glClear(GL_DEPTH_BUFFER_BIT);
            setup_projection(true);

            glDisable(GL_DEPTH_TEST);
            glDisable(GL_LIGHTING);
            glEnable(GL_COLOR_SUM);
            glDepthFunc(GL_LEQUAL);
            view.render_interface_selection();

            glPopAttrib();
        glPopMatrix();

        //SDL.GL.swap_window(window);
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
}

public abstract class View
{
    public abstract void process(double dt);
    public abstract void render();
    public abstract void render_selection();
    public abstract void render_interface();
    public abstract void render_interface_selection();
    public abstract void mouse_move(int x, int y, uint color_id);
    public abstract void mouse_click(int x, int y, int button, bool state, uint color_id);
    public abstract void mouse_wheel(int amount);
}
