using GL;
using SDL;
using Gee;

public class MainMenu : View
{
    public signal void menu_action();

    private MainMenuBackground background = new MainMenuBackground();
    private unowned Window window;

    private ArrayList<Button> buttons = new ArrayList<Button>();
    private Button ai_button = new Button("AI", 1);
    private Button host_button = new Button("Host", 2);
    private Button join_button = new Button("Join", 3);
    private Button exit_button = new Button("Exit", 4);

    public MainMenu(Window window)
    {
        this.window = window;
        action = MenuAction.ACTIVE;

        ai_button.position = new Vector(0.5f, 0.75f, 0);
        ai_button.visible = true;
        ai_button.press.connect(ai_button_press);
        ai_button.size = 0.4f;

        host_button.position = new Vector(0.5f, 0.25f, 0);
        host_button.visible = true;
        host_button.press.connect(host_button_press);
        host_button.size = 0.4f;

        join_button.position = new Vector(0.5f, -0.25f, 0);
        join_button.visible = true;
        join_button.press.connect(join_button_press);
        join_button.size = 0.4f;

        exit_button.position = new Vector(0.5f, -0.75f, 0);
        exit_button.visible = true;
        exit_button.press.connect(exit_button_press);
        exit_button.size = 0.4f;

        buttons.add(ai_button);
        buttons.add(host_button);
        buttons.add(join_button);
        buttons.add(exit_button);
    }

    ~MainMenu()
    {
        ai_button.press.disconnect(ai_button_press);
        host_button.press.disconnect(host_button_press);
        join_button.press.disconnect(join_button_press);
        exit_button.press.disconnect(exit_button_press);
    }

    private void ai_button_press(Button b)
    {
        action = MenuAction.SINGLE_PLAYER;
        menu_action();
    }

    private void host_button_press(Button b)
    {
        action = MenuAction.HOST_MULTI_PLAYER;
        menu_action();
    }

    private void join_button_press(Button b)
    {
        action = MenuAction.JOIN_MULTI_PLAYER;
        menu_action();
    }

    private void exit_button_press(Button b)
    {
        action = MenuAction.EXIT;
        menu_action();
    }

    public override void render()
    {
        glClearColor(0, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT);

        float distance = 3;
        glTranslatef(0, 0, -(GLfloat)distance);
        glRotatef(-60, 1, 0, 0);
        glScalef((GLfloat)0.5f, (GLfloat)0.5f, (GLfloat)0.5f);

        glTranslatef(-2, 0, 0);
        background.render();
    }

    public override void render_selection()
    {

    }

    public override void render_interface()
    {
        foreach (Button b in buttons)
            b.render();
    }

    public override void render_interface_selection()
    {
        foreach (Button b in buttons)
            b.render_selection();
    }

    public override void process(double dt)
    {
        background.process(dt);
    }

    public override void mouse_move(int x, int y, uint color_id)
    {
        Button? button = null;

        foreach (Button b in buttons)
            if (b.hover(color_id))
                button = b;

        Environment.set_cursor(button == null ? Environment.CursorType.DEFAULT : Environment.CursorType.HOVER);
    }

    public override void mouse_click(int x, int y, int mouse_button, bool state, uint color_id)
    {
        foreach (Button b in buttons)
            b.click(color_id, state);
    }

    public override void mouse_wheel(int amount){}

    public MenuAction action { get; private set; }

    public enum MenuAction
    {
        ACTIVE,
        SINGLE_PLAYER,
        HOST_MULTI_PLAYER,
        JOIN_MULTI_PLAYER,
        OPTIONS,
        EXIT
    }
}
