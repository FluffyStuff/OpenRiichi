public class OptionItemControl : View2D
{
    private string name;
    private string[] options;

    private LabelControl name_label;
    private LabelControl text_label;
    private GameMenuButton next_button;
    private GameMenuButton prev_button;

    public OptionItemControl(string name, string[] options, int index)
    {
        this.name = name;
        this.options = options;
        this.index = index;

        resize_style = ResizeStyle.ABSOLUTE;
        size = Size2(600, 100);
    }

    public override void added()
    {
        int width = 350;
        prev_button = new GameMenuButton(store, "Prev");
        next_button = new GameMenuButton(store, "Next");

        name_label = new LabelControl(store);
        name_label.text = name;
        name_label.inner_anchor = Size2(0, 0.5f);
        name_label.outer_anchor = Size2(0, 0.5f);
        add_control(name_label);

        prev_button.inner_anchor = Size2(0, 0.5f);
        prev_button.outer_anchor = Size2(1, 0.5f);
        prev_button.position = Vec2(-width, 0);
        prev_button.selectable = true;
        prev_button.clicked.connect(prev);
        add_control(prev_button);

        text_label = new LabelControl(store);
        text_label.text = "";
        text_label.inner_anchor = Size2(0.5f, 0.5f);
        text_label.outer_anchor = Size2(1, 0.5f);
        text_label.position = Vec2(-width / 2, 0);
        add_control(text_label);

        next_button.inner_anchor = Size2(1, 0.5f);
        next_button.outer_anchor = Size2(1, 0.5f);
        next_button.selectable = true;
        next_button.clicked.connect(next);
        add_control(next_button);

        set_options();
    }

    private void next()
    {
        index++;
        set_options();
    }

    private void prev()
    {
        index--;
        set_options();
    }

    private void set_options()
    {
        if (index >= options.length - 1)
        {
            index = options.length - 1;
            next_button.enabled = false;
        }
        else
            next_button.enabled = true;

        if (index <= 0)
        {
            index = 0;
            prev_button.enabled = false;
        }
        else
            prev_button.enabled = true;

        text_label.text = options[index];
    }

    public int index { get; private set; }
}
