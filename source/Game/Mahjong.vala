using SDL;
using GL;

public class Mahjong : View
{
    private unowned Window window;

    private const float scale = 2;
    private bool do_move = false;
    private int last_x = 0;
    private int last_y = 0;
    private int rot_x = 0;
    private int rot_y = 120;

    private float distance = 12;

    private Game game;

    public Mahjong(Window window)
    {
        this.window = window;
        game = new Game();
    }

    public Mahjong.seed(Window window, uint8[] tiles, uint8 wall_split, uint8 seat, List<GameConnection> players)
    {
        this.window = window;
        game = new Game.seed(tiles, wall_split, seat, players);
    }

    public override void process(double dt) { game.process(dt); }

    public override void render()
    {
        glClearColor(0, (GLfloat)0.1, (GLfloat)0.2, 0);
        glClear(GL_COLOR_BUFFER_BIT);
        do_transform();

        game.render();
    }

    public override void render_selection()
    {
        do_transform();
        game.render_selection();
    }

    public override void render_interface() { game.render_interface(); }

    public override void render_interface_selection() { game.render_interface_selection(); }

    private void do_transform()
    {
        double a = (double)rot_x / 3;
        double b = -(double)rot_y / 3;

        glTranslatef(0, 1, 0);
        glTranslatef(0, 0, -(GLfloat)distance);
        glRotated((GLdouble)b, 1, 0, 0);
        glRotated((GLdouble)a, 0, 0, 1);
        glScalef((GLfloat)scale, (GLfloat)scale, (GLfloat)scale);
    }

    public override void mouse_click(int x, int y, int button, bool state, uint color_id)
    {
        if (button == 3)
        {
            last_x = x;
            last_y = y;

            do_move = !state;
        }

        if (button == 1)
            game.mouse_click(x, y, color_id, state);
    }

    public override void mouse_move(int x, int y, uint color_id)
    {
        if (do_move)
        {
            rot_x += x - last_x;
            rot_y += y - last_y;
            last_x = x;
            last_y = y;

            rot_x = int.min(int.max(rot_x, -85), 85);
            rot_y = int.min(int.max(rot_y, 40), 210);
        }

        game.mouse_move(x, y, color_id);
    }

    public override void mouse_wheel(int amount)
    {
        distance -= distance * (amount / 30.0f);
        distance = float.min(float.max(distance, 8.5f), 15);
    }
}
