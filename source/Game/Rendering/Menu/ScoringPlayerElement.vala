class ScoringPlayerElement
{
    private Vec2 screen_size;
    private RenderImage2D background;
    private RenderLabel2D name_label;
    private RenderLabel2D score_label;
    private RenderLabel2D transfer_label;

    public ScoringPlayerElement(IResourceStore store, string player_name, int score, int transfer)
    {
        RenderTexture texture = store.load_texture("Menu/score_background");
        background = new RenderImage2D(texture);

        name_label = store.create_label();
        name_label.text = player_name;
        name_label.font_size = 30 / 1.6f;
        name_label.font_type = "Sans Bold";
        name_label.diffuse_color = Color(0, 0.2f, 1, 1);

        score_label = store.create_label();
        score_label.text = score.to_string();
        score_label.font_size = 30 / 1.6f;
        score_label.font_type = "Sans Bold";
        score_label.diffuse_color = Color.white();

        transfer_label = store.create_label();
        transfer_label.text = transfer.to_string();
        transfer_label.font_size = 30 / 1.6f;
        transfer_label.font_type = "Sans Bold";
        if (transfer > 0)
            transfer_label.diffuse_color = Color.green();
        else
            transfer_label.diffuse_color = Color.red();
    }

    public void render(RenderScene2D scene, Vec2 screen_size)
    {
        this.screen_size = screen_size;

        reposition();

        scene.add_object(background);
        scene.add_object(name_label);
        scene.add_object(score_label);
        scene.add_object(transfer_label);
    }

    private void reposition()
    {

    }
}
