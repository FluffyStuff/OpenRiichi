using GameServer;

public class ServerPlayerFieldView : View2D
{
    private bool editable;
    private LabelControl name_label;

    public ServerPlayerFieldView(bool editable)
    {
        this.editable = editable;
        resize_style = ResizeStyle.ABSOLUTE;
    }

    public override void added()
    {
        RectangleControl border = new RectangleControl();
        border.color = Color(0.05f, 0, 0.4f, 1);
        border.set_size(Size2(size.width + 6, size.height + 6));

        RectangleControl rect = new RectangleControl();
        rect.color = Color(0.1f, 0, 0.8f, 1);
        rect.set_size(size);
        add_control(border);
        add_control(rect);

        name_label = new LabelControl(store);
        name_label.inner_anchor = Vec2(0, 0.5f);
        name_label.outer_anchor = Vec2(0, 0.5f);
        name_label.text = "Open";
        name_label.position = Vec2(10, 0);
        add_control(name_label);

        if (editable)
        {
            GameMenuButton expand_button = new GameMenuButton(store, "Expand");
            expand_button.inner_anchor = Vec2(1, 0.5f);
            expand_button.outer_anchor = Vec2(1, 0.5f);
            expand_button.clicked.connect(expand_clicked);
            add_control(expand_button);
        }
    }

    private void expand_clicked()
    {

    }

    public void assign(string name)
    {
        name_label.text = name;
        assigned = true;
    }

    public void unassign()
    {
        name_label.text = "Open";
        assigned = false;
    }

    public bool assigned { get; private set; }
}
