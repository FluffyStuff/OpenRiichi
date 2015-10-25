using Gee;

public class OptionsMenuView : View2D
{
    private Options options = new Options.from_disk();
    private OptionItemControl shader_option;
    private OptionItemControl model_option;

    public signal void apply_clicked();
    public signal void back_clicked();

    public override void added()
    {
        LabelControl label = new LabelControl(store);
        label.text = "Options";
        label.font_size = 40;
        label.outer_anchor = Vec2(0.5f, 1);
        label.inner_anchor = Vec2(0.5f, 1);
        add_control(label);

        string[] choices = { "Low", "High" };

        ArrayList<OptionItemControl> opts = new ArrayList<OptionItemControl>();

        shader_option = new OptionItemControl("Shader quality", choices, (int)options.shader_quality);
        opts.add(shader_option);

        model_option = new OptionItemControl("Model quality", choices, (int)options.model_quality);
        opts.add(model_option);

        int padding = 50;

        Size2 size = Size2(600, 100);
        float start = label.size.height + padding;

        for (int i = 0; i < opts.size; i++)
        {
            OptionItemControl option = opts.get(i);
            option.size = size;
            option.outer_anchor = Vec2(0.5f, 1);
            option.inner_anchor = Vec2(0.5f, 1);
            option.position = Vec2(0, -(start + size.height * i));

            add_child(option);
        }

        GameMenuButton apply_button = new GameMenuButton(store, "Apply");
        apply_button.outer_anchor = Vec2(0.5f, 0);
        apply_button.inner_anchor = Vec2(1, 0);
        apply_button.position = Vec2(-padding, padding);
        apply_button.clicked.connect(apply);
        add_control(apply_button);

        GameMenuButton back_button = new GameMenuButton(store, "Back");
        back_button.outer_anchor = Vec2(0.5f, 0);
        back_button.inner_anchor = Vec2(0, 0);
        back_button.position = Vec2(padding, padding);
        back_button.clicked.connect(back);
        add_control(back_button);
    }

    public override void do_render_2D(RenderState state, RenderScene2D scene)
    {
        state.back_color = Color.black();
    }

    private void apply()
    {
        options.shader_quality = (Options.QualityEnum)shader_option.index;
        options.model_quality = (Options.QualityEnum)model_option.index;
        options.save();

        apply_clicked();
    }

    private void back()
    {
        back_clicked();
    }
}
