using Engine;

public class OptionItemControl : View2D
{
    private bool can_control;
    private string name;
    private string[] options;

    private LabelControl name_label;
    private LabelControl text_label;
    private GameMenuButton next_button;
    private GameMenuButton prev_button;

    public OptionItemControl(bool can_control, string name, string[] options, int index)
    {
        base();

        this.can_control = can_control;
        this.name = name;
        this.options = options;
        this.index = index;

        resize_style = ResizeStyle.ABSOLUTE;
        size = Size2(600, 100);
    }

    public override void added()
    {
        int width = 350;

        if (can_control)
        {
            prev_button = new GameMenuButton("Prev");
            next_button = new GameMenuButton("Next");
        }

        name_label = new LabelControl();
        add_child(name_label);
        name_label.text = name;
        name_label.inner_anchor = Vec2(0, 0.5f);
        name_label.outer_anchor = Vec2(0, 0.5f);

        if (can_control)
        {
            add_child(prev_button);
            prev_button.inner_anchor = Vec2(0, 0.5f);
            prev_button.outer_anchor = Vec2(1, 0.5f);
            prev_button.position = Vec2(-width, 0);
            prev_button.selectable = true;
            prev_button.clicked.connect(prev);
        }

        text_label = new LabelControl();
        add_child(text_label);
        text_label.text = "";
        text_label.inner_anchor = Vec2(0.5f, 0.5f);
        text_label.outer_anchor = Vec2(1, 0.5f);
        text_label.position = Vec2(-width / 2, 0);

        if (can_control)
        {
            add_child(next_button);
            next_button.inner_anchor = Vec2(1, 0.5f);
            next_button.outer_anchor = Vec2(1, 0.5f);
            next_button.selectable = true;
            next_button.clicked.connect(next);
        }

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
        if (can_control)
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
        }

        text_label.text = options[index];
    }

    public int index { get; private set; }
}
