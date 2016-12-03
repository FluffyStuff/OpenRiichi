using Gee;

private class OptionsMenuView : MainMenuSubView
{
    private ArrayList<SubOptionsMenuView> menus = new ArrayList<SubOptionsMenuView>();

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        MenuTextButton apply_button = new MenuTextButton("MenuButton", "Apply");
        apply_button.clicked.connect(apply);
        buttons.add(apply_button);

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

        return buttons;
    }

    protected override ArrayList<MenuTextButton>? get_main_buttons()
    {
        ArrayList<MenuOptionsButton> buttons = new ArrayList<MenuOptionsButton>();

        for (int i = 0; i < menus.size; i++)
        {
            SubOptionsMenuView menu = menus[i];
            MenuOptionsButton menu_button = new MenuOptionsButton(menu, menu.menu_name);
            menu_button.clicked.connect(sub_pressed);
            buttons.add(menu_button);
        }

        return buttons;
    }

    public override void load()
    {
        options = new Options.from_disk();

        string[] quality_choices = { "Low", "High" };
        string[] on_off_choices = { "Off", "On" };
        string apply_text = "Apply";
        string back_text = "Back";
        int padding = 30;

        GraphicOptionsMenuView graphics = new GraphicOptionsMenuView
        (
            "Graphic options",
            options,
            quality_choices,
            on_off_choices,
            apply_text,
            back_text,
            padding
        );
        menus.add(graphics);
        AudioOptionsMenuView audio = new AudioOptionsMenuView
        (
            "Audio options",
            options,
            on_off_choices,
            apply_text,
            back_text,
            padding
        );
        menus.add(audio);
        AppearanceOptionsMenuView appearance = new AppearanceOptionsMenuView
        (
            "Appearance options",
            options,
            apply_text,
            back_text,
            padding
        );
        menus.add(appearance);
    }

    private void sub_pressed(Control button)
    {
        MenuOptionsButton b = (MenuOptionsButton)button;
        load_sub_view(b.menu);
    }

    private void apply()
    {
        foreach (SubOptionsMenuView menu in menus)
            menu.apply();

        options.save();
        do_finish();
    }

    public Options options { get; private set; }
    public override string get_name() { return "Options"; }
}

private class MenuOptionsButton : MenuTextButton
{
    public MenuOptionsButton(SubOptionsMenuView menu, string text)
    {
        base("MenuButton", text);
        this.menu = menu;
    }

    public SubOptionsMenuView menu { get; private set; }
}

private abstract class SubOptionsMenuView : MainMenuSubView
{
    protected Options options;
    protected string apply_text;
    protected string back_text;
    protected int padding;

    protected ArrayList<OptionItemControl> opts = new ArrayList<OptionItemControl>();

    public signal void back_clicked(SubOptionsMenuView menu);

    public SubOptionsMenuView(string name, Options options, string apply_text, string back_text, int padding)
    {
        menu_name = name;
        this.options = options;
        this.apply_text = apply_text;
        this.back_text = back_text;
        this.padding = padding;
    }

    public override void load()
    {
        add_options();

        Size2 size = Size2(600, 55);
        float start = top_offset + padding;

        for (int i = 0; i < opts.size; i++)
        {
            OptionItemControl option = opts.get(i);
            add_child(option);
            option.size = size;
            option.outer_anchor = Vec2(0.5f, 1);
            option.inner_anchor = Vec2(0.5f, 1);
            option.position = Vec2(0, -(start + size.height * i));
        }
    }

    protected override ArrayList<MenuTextButton>? get_menu_buttons()
    {
        ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();

        MenuTextButton back_button = new MenuTextButton("MenuButton", "Back");
        back_button.clicked.connect(do_back);
        buttons.add(back_button);

        return buttons;
    }

    public void apply()
    {
        if (loaded)
            do_apply();
    }

    protected abstract void do_apply();
    protected abstract void add_options();

    public string menu_name { get; private set; }
    protected override string get_name() { return menu_name; }
}

private class GraphicOptionsMenuView : SubOptionsMenuView
{
    private OptionItemControl shader_option;
    private OptionItemControl model_option;
    private OptionItemControl fullscreen_option;
    private OptionItemControl aniso_option;
    private OptionItemControl aliasing_option;
    private OptionItemControl v_sync_option;

    private string[] quality_choices;
    private string[] on_off_choices;

    public GraphicOptionsMenuView(string name, Options options, string[] quality_choices, string[] on_off_choices, string apply_text, string back_text, int padding)
    {
        base
        (
            name,
            options,
            apply_text,
            back_text,
            padding
        );

        this.quality_choices = quality_choices;
        this.on_off_choices = on_off_choices;
    }

    public override void add_options()
    {
        opts.add(shader_option = new OptionItemControl(true, "Shader quality", quality_choices, (int)options.shader_quality));
        opts.add(model_option = new OptionItemControl(true, "Model quality", quality_choices, (int)options.model_quality));
        opts.add(fullscreen_option = new OptionItemControl(true, "Fullscreen", on_off_choices, (int)options.fullscreen));
        opts.add(aniso_option = new OptionItemControl(true, "Anisotropic filtering", on_off_choices, (int)options.anisotropic_filtering));
        opts.add(aliasing_option = new OptionItemControl(true, "Anti aliasing", on_off_choices, (int)options.anti_aliasing));
        opts.add(v_sync_option = new OptionItemControl(true, "V-sync", on_off_choices, (int)options.v_sync));
    }

    public override void do_apply()
    {
        options.shader_quality = (Options.QualityEnum)shader_option.index;
        options.model_quality = (Options.QualityEnum)model_option.index;
        options.fullscreen = (Options.OnOffEnum)fullscreen_option.index;
        options.anisotropic_filtering = (Options.OnOffEnum)aniso_option.index;
        options.anti_aliasing = (Options.OnOffEnum)aliasing_option.index;
        options.v_sync = (Options.OnOffEnum)v_sync_option.index;
    }
}

private class AudioOptionsMenuView : SubOptionsMenuView
{
    private OptionItemControl music_option;
    private OptionItemControl sounds_option;

    private string[] on_off_choices;

    public AudioOptionsMenuView(string name, Options options, string[] on_off_choices, string apply_text, string back_text, int padding)
    {
        base
        (
            name,
            options,
            apply_text,
            back_text,
            padding
        );

        this.on_off_choices = on_off_choices;
    }

    public override void add_options()
    {
        opts.add(music_option = new OptionItemControl(true, "Music", on_off_choices, (int)options.music));
        opts.add(sounds_option = new OptionItemControl(true, "Sound effects", on_off_choices, (int)options.sounds));
    }

    public override void do_apply()
    {
        options.music = (Options.OnOffEnum)music_option.index;
        options.sounds = (Options.OnOffEnum)sounds_option.index;
    }
}

private class AppearanceOptionsMenuView : SubOptionsMenuView
{
    private TileMenuView tile;
    private ScrollBarControl fore_red = new ScrollBarControl(false);
    private ScrollBarControl fore_green = new ScrollBarControl(false);
    private ScrollBarControl fore_blue = new ScrollBarControl(false);
    private ScrollBarControl back_red = new ScrollBarControl(false);
    private ScrollBarControl back_green = new ScrollBarControl(false);
    private ScrollBarControl back_blue = new ScrollBarControl(false);

    public AppearanceOptionsMenuView(string name, Options options, string apply_text, string back_text, int padding)
    {
        base
        (
            name,
            options,
            apply_text,
            back_text,
            padding
        );
    }

    public override void add_options()
    {
        tile = new TileMenuView(options.tile_textures, options.tile_fore_color, options.tile_back_color);
        add_child(tile);
        tile.inner_anchor = Vec2(1, 0.5f);
        tile.outer_anchor = Vec2(1, 0.5f);

        float height = 50;

        LabelControl fore_label = new LabelControl();
        add_child(fore_label);
        fore_label.text = "Tile fore color";
        fore_label.font_size = 30;
        fore_label.outer_anchor = Vec2(0.5f, 1);
        fore_label.inner_anchor = Vec2(0.5f, 0);
        fore_label.position = Vec2(0, -(top_offset + padding + height * 0));

        LabelControl back_label = new LabelControl();
        add_child(back_label);
        back_label.text = "Tile back color";
        back_label.font_size = 30;
        back_label.outer_anchor = Vec2(0.5f, 1);
        back_label.inner_anchor = Vec2(0.5f, 0);
        back_label.position = Vec2(0, -(top_offset + padding + height * 4));

        LabelControl texture_label = new LabelControl();
        add_child(texture_label);
        texture_label.text = "Tile texture type";
        texture_label.font_size = 30;
        texture_label.outer_anchor = Vec2(0.5f, 1);
        texture_label.inner_anchor = Vec2(0.5f, 0);
        texture_label.position = Vec2(0, -(top_offset + padding + height * 8));

        set_bar_properties(fore_red, -(top_offset + padding + height * 0), true);
        set_bar_properties(fore_green, -(top_offset + padding + height * 1), true);
        set_bar_properties(fore_blue, -(top_offset + padding + height * 2), true);

        fore_red.current_value = (int)(options.tile_fore_color.r * 100);
        fore_green.current_value = (int)(options.tile_fore_color.g * 100);
        fore_blue.current_value = (int)(options.tile_fore_color.b * 100);

        set_bar_properties(back_red, -(top_offset + padding + height * 4), false);
        set_bar_properties(back_green, -(top_offset + padding + height * 5), false);
        set_bar_properties(back_blue, -(top_offset + padding + height * 6), false);

        back_red.current_value = (int)(options.tile_back_color.r * 100);
        back_green.current_value = (int)(options.tile_back_color.g * 100);
        back_blue.current_value = (int)(options.tile_back_color.b * 100);

        MenuTextButton regular = new MenuTextButton("MenuButtonSmall", "Regular");
        add_child(regular);
        regular.inner_anchor = Vec2(1, 1);
        regular.outer_anchor = Vec2(0.5f, 1);
        regular.position = Vec2(-padding / 2, -(top_offset + padding + height * 8));
        regular.clicked.connect(regular_clicked);

        MenuTextButton black = new MenuTextButton("MenuButtonSmall", "Black");
        add_child(black);
        black.inner_anchor = Vec2(0, 1);
        black.outer_anchor = Vec2(0.5f, 1);
        black.position = Vec2(padding / 2, -(top_offset + padding + height * 8));
        black.clicked.connect(black_clicked);
    }

    private void set_bar_properties(ScrollBarControl bar, float height, bool fore)
    {
        Size2 size = Size2(400, 40);

        add_child(bar);
        bar.maximum = 100;
        bar.scroll_amount = bar.maximum / 10;
        bar.size = size;
        bar.outer_anchor = Vec2(0.5f, 1);
        bar.inner_anchor = Vec2(0.5f, 1);
        bar.position = Vec2(0, height);

        if (fore)
            bar.value_changed.connect(fore_color_changed);
        else
            bar.value_changed.connect(back_color_changed);
    }

    private void regular_clicked()
    {
        tile.texture_type = "Regular";
    }

    private void black_clicked()
    {
        tile.texture_type = "Black";
    }

    private void fore_color_changed()
    {
        tile.fore_color = Color(fore_red.fval, fore_green.fval, fore_blue.fval, 1);
    }

    private void back_color_changed()
    {
        tile.back_color = Color(back_red.fval, back_green.fval, back_blue.fval, 1);
    }

    public override void do_apply()
    {
        options.tile_fore_color = tile.fore_color;
        options.tile_back_color = tile.back_color;
        options.tile_textures = tile.texture_type;
    }

    public override void resized()
    {
        tile.size = Size2(size.width / 3, size.height / 3);
    }
}

private class TileMenuView : View3D
{
    private RenderTile tile;
    private Camera camera = new Camera();
    private LightSource light1 = new LightSource();
    private LightSource light2 = new LightSource();

    private string _texture_type;
    private Color _fore_color;
    private Color _back_color;

    public TileMenuView(string texture_type, Color fore_color, Color back_color)
    {
        _texture_type = texture_type;
        _fore_color = fore_color;
        _back_color = back_color;
    }

    public override void added()
    {
        resize_style = ResizeStyle.ABSOLUTE;

        float len = 3;
        camera.focal_length = 0.8f;

        Vec3 pos = Vec3(0, 0, len);
        camera.position = pos;

        light1.color = Color.white();
        light1.position = Vec3(len, len, len / 2);
        light1.intensity = 5;
        light2.color = Color.white();
        light2.position = Vec3(-len, len, len / 2);
        light2.intensity = 5;

        reload_tile();
    }

    public void reload_tile()
    {
        string extension = "high";

        float tile_scale = 4f;
        Tile t = new Tile(0, TileType.PIN1, false);
        tile = new RenderTile(store, extension, texture_type, t, tile_scale);
        tile.front_color = fore_color;
        tile.back_color = back_color;
    }

    public override void do_process(DeltaArgs delta)
    {
        float r = delta.time;
        tile.set_absolute_location(Vec3.empty(), new Quat.from_euler_vec(Vec3(r * -0.2f, r * 0.1f, r * 0.0812f)));
    }

    public override void do_render_3D(RenderState state)
    {
        window.renderer.shader_3D = "open_gl_shader_3D_high";
        RenderScene3D scene = new RenderScene3D(state.screen_size, 1, rect);

        scene.set_camera(camera);
        scene.add_light_source(light1);
        scene.add_light_source(light2);

        tile.render(scene);

        state.add_scene(scene);
    }

    public string texture_type
    {
        get { return _texture_type; }
        set
        {
            _texture_type = value;
            reload_tile();
        }
    }

    public Color fore_color
    {
        get { return _fore_color; }
        set { _fore_color = tile.front_color = value; }
    }

    public Color back_color
    {
        get { return _back_color; }
        set { _back_color = tile.back_color = value; }
    }
}
