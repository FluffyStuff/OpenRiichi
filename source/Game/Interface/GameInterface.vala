using GL;
using Gee;

public class GameInterface
{
    private ArrayList<Button> buttons = new ArrayList<Button>();
    private Button continue_button = new Button("Continue", 256);
    private Button pon_button = new Button("Pon", 257);
    private Button kan_button = new Button("Kan", 258);
    private Button chi_button = new Button("Chi", 259);
    private Button riichi_button = new Button("Riichi", 260);
    private Button tsumo_button = new Button("Tsumo", 261);
    private Button ron_button = new Button("Ron", 262);

    public GameInterface()
    {
        continue_button.position = new Vector(0, -1 + continue_button.size * continue_button.height, 0);
        pon_button.position = new Vector(continue_button.size * continue_button.width * 2,
                                              -1 + continue_button.size * continue_button.height, 0);
        kan_button.position = new Vector(continue_button.size * continue_button.width * 4,
                                              -1 + continue_button.size * continue_button.height, 0);
        chi_button.position = new Vector(continue_button.size * continue_button.width * 6,
                                              -1 + continue_button.size * continue_button.height, 0);
        riichi_button.position = new Vector(continue_button.size * continue_button.width * 6,
                                              -1 + continue_button.size * continue_button.height, 0);
        tsumo_button.position = new Vector(continue_button.size * continue_button.width * 8,
                                              -1 + continue_button.size * continue_button.height, 0);
        ron_button.position = new Vector(continue_button.size * continue_button.width * 10,
                                              -1 + continue_button.size * continue_button.height, 0);

        continue_button.visible = true;

        buttons.add(continue_button);
        buttons.add(pon_button);
        buttons.add(kan_button);
        buttons.add(chi_button);
        buttons.add(riichi_button);
        buttons.add(tsumo_button);
        buttons.add(ron_button);
    }

    public void render()
    {
        if (!visible)
            return;

        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
        glDisable(GL_LIGHTING);
        glEnable(GL_TEXTURE_2D);
        glEnable(GL_COLOR_SUM);
        glDepthFunc(GL_LEQUAL);

        foreach (Button b in buttons)
            b.render();

        glDisable(GL_TEXTURE_2D);
    }

    public void render_selection()
    {
        if (!visible)
            return;

        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
        glDisable(GL_LIGHTING);
        glDisable(GL_TEXTURE_2D);

        foreach (Button b in buttons)
            b.render_selection();
    }

    public bool hover(int x, int y, uint color_id)
    {
        bool hovering = false;
        foreach (Button b in buttons)
        {
            if ((b.hover(color_id) && b.color_id == color_id))
                hovering = true;
        }

        return hovering;
    }

    public Button? click(int x, int y, uint color_id, bool state)
    {
        Button? button = null;

        foreach (Button b in buttons)
            if (b.click(color_id, state))
                button = b;

        return button;
    }

    public bool visible { get; set; }

    public bool show_continue
    {
        get { return continue_button.visible; }
        set { continue_button.visible = value; }
    }

    public bool show_pon
    {
        get { return pon_button.visible; }
        set { pon_button.visible = value; }
    }

    public bool show_kan
    {
        get { return kan_button.visible; }
        set { kan_button.visible = value; }
    }

    public bool show_chi
    {
        get { return chi_button.visible; }
        set { chi_button.visible = value; }
    }

    public bool show_riichi
    {
        get { return riichi_button.visible; }
        set { riichi_button.visible = value; }
    }

    public bool show_tsumo
    {
        get { return tsumo_button.visible; }
        set { tsumo_button.visible = value; }
    }

    public bool show_ron
    {
        get { return ron_button.visible; }
        set { ron_button.visible = value; }
    }
}
