using Gee;

public class OptionsMenuView : View2D
{
    private Options options = new Options.from_disk();
    private OptionItemControl shader_option;
    private OptionItemControl model_option;
    private OptionItemControl aniso_option;
    private OptionItemControl aliasing_option;
    private OptionItemControl v_sync_option;

    public signal void apply_clicked();
    public signal void back_clicked();

    public override void added()
    {
        LabelControl label = new LabelControl();
        add_child(label);
        label.text = "Options";
        label.font_size = 40;
        label.outer_anchor = Vec2(0.5f, 1);
        label.inner_anchor = Vec2(0.5f, 1);
        label.position = Vec2(0, -60);

        string[] quality_choices = { "Low", "High" };
        string[] on_off_choices = { "Off", "On" };

        ArrayList<OptionItemControl> opts = new ArrayList<OptionItemControl>();

        shader_option = new OptionItemControl("Shader quality", quality_choices, (int)options.shader_quality);
        opts.add(shader_option);
        model_option = new OptionItemControl("Model quality", quality_choices, (int)options.model_quality);
        opts.add(model_option);
        aniso_option = new OptionItemControl("Anisotropic filtering", on_off_choices, (int)options.anisotropic_filtering);
        opts.add(aniso_option);
        aliasing_option = new OptionItemControl("Anti aliasing", on_off_choices, (int)options.anti_aliasing);
        opts.add(aliasing_option);
        v_sync_option = new OptionItemControl("V-sync", on_off_choices, (int)options.v_sync);
        opts.add(v_sync_option);

        int padding = 30;

        Size2 size = Size2(700, 70);
        float start = label.size.height - label.position.y + padding;

        for (int i = 0; i < opts.size; i++)
        {
            OptionItemControl option = opts.get(i);
            add_child(option);
            option.size = size;
            option.outer_anchor = Vec2(0.5f, 1);
            option.inner_anchor = Vec2(0.5f, 1);
            option.position = Vec2(0, -(start + size.height * i));
        }

        MenuTextButton apply_button = new MenuTextButton("MenuButton", "Apply");
        add_child(apply_button);
        apply_button.outer_anchor = Vec2(0.5f, 0);
        apply_button.inner_anchor = Vec2(1, 0);
        apply_button.position = Vec2(-padding, padding);
        apply_button.clicked.connect(apply);

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        add_child(back_button);
        back_button.outer_anchor = Vec2(0.5f, 0);
        back_button.inner_anchor = Vec2(0, 0);
        back_button.position = Vec2(padding, padding);
        back_button.clicked.connect(back);
    }

    public override void do_render(RenderState state, RenderScene2D scene)
    {
        state.back_color = Color.black();
    }

    private void apply()
    {
        options.shader_quality = (Options.QualityEnum)shader_option.index;
        options.model_quality = (Options.QualityEnum)model_option.index;
        options.anisotropic_filtering = (Options.OnOffEnum)aniso_option.index;
        options.anti_aliasing = (Options.OnOffEnum)aliasing_option.index;
        options.v_sync = (Options.OnOffEnum)v_sync_option.index;
        options.save();

        apply_clicked();
    }

    private void back()
    {
        back_clicked();
    }
}
