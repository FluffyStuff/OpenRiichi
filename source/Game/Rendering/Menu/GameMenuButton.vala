class GameMenuButton
{
    private RenderImage2D button;
    private Vec2 screen_size;

    public signal void clicked();

    public GameMenuButton(IResourceStore store, string name)
    {
        RenderTexture texture = store.load_texture("Buttons/" + name);
        button = new RenderImage2D(texture);

        scale = 1;
        visible = true;
        enabled = false;
    }

    public void render(RenderScene2D scene, Vec2 screen_size)
    {
        this.screen_size = screen_size;

        if (!visible)
            return;

        resize();

        if (!enabled)
        {
            button.alpha = 0.05f;
            button.diffuse_color = {};
        }
        else
        {
            button.alpha = 1;
            if (hovering)
                button.diffuse_color = { 0.5f, 0.5f, 0.3f };
            else
                button.diffuse_color = {};
        }

        scene.add_object(button);
    }

    public void resize()
    {
        float width = button.texture.size.x / screen_size.x;
        float height = button.texture.size.y / screen_size.y;

        button.scale = { width * scale, height * scale };

        //float x = position.x + button.scale.x * -anchor.x;
        //float y = position.y + button.scale.y * -anchor.y;
        float x = anchor.x + position.x / screen_size.x * 2;
        float y = anchor.y + position.y / screen_size.y * 2;

        button.position = { x, y };
    }

    public bool hover_check(Vec2 point)
    {
        if (!enabled || !visible)
            return false;

        float x = screen_size.x / 2 * (1 + anchor.x) + position.x;
        float y = screen_size.y / 2 * (1 + anchor.y) + position.y;

        Vec2 top_left = Vec2() { x = x - button.texture.size.x / 2 * scale, y = y - button.texture.size.y / 2 * scale };
        Vec2 bottom_right = Vec2() { x = x + button.texture.size.x / 2 * scale, y = y + button.texture.size.y / 2 * scale };

        return
            point.x >= top_left.x &&
            point.x <= bottom_right.x &&
            point.y >= top_left.y &&
            point.y <= bottom_right.y;
    }

    public void click()
    {
        if (enabled)
            clicked();
    }

    public Vec2 position { get; set; }
    public Vec2 anchor { get; set; }
    public float scale { get; set; }
    public bool visible { get; set; }
    public bool enabled { get; set; }
    public bool hovering { get; set; }

    public Vec2 size { get { return button.texture.size; } }
}
