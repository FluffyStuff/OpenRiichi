public abstract class ListControl : Control
{
    private RectangleControl background;
    private ListItemControl? header;
    private ListItemControl[]? items;
    private bool row_selectable;

    public signal void selected_index_changed(ListControl list);

    public ListControl(bool row_selectable)
    {
        font_size = 30;
        row_height = 40;
        selected_index = -1;
        this.row_selectable = row_selectable;
    }

    public override void added()
    {
        background = new RectangleControl();
        add_child(background);
        background.resize_style = ResizeStyle.RELATIVE;
        background.color = Color.with_alpha(0.2f);

        selectable = true;
        cursor_type = CursorType.NORMAL;

        on_added();
    }

    protected void refresh_data()
    {
        if (header != null)
            remove_child(header);

        if (items != null)
            foreach (ListItemControl item in items)
                remove_child(item);

        ListColumnInfo[] columns = new ListColumnInfo[column_count];
        for (int i = 0; i < columns.length; i++)
            columns[i] = get_column_info(i);

        ListCell[] header_cells = new ListCell[column_count];
        for (int i = 0; i < column_count; i++)
            header_cells[i] = new ListCell(columns[i].name, columns[i].style, font_size);
        header = new ListItemControl.header(header_cells);
        add_child(header);
        header.inner_anchor = Vec2(0, 1);
        header.outer_anchor = Vec2(0, 1);

        items = new ListItemControl[row_count];
        for (int i = 0; i < items.length; i++)
        {
            ListCell[] cells = new ListCell[column_count];
            for (int j = 0; j < column_count; j++)
                cells[j] = new ListCell(get_cell_data(i, j), columns[j].style, font_size);

            ListItemControl item = new ListItemControl(cells, i);
            items[i] = item;

            add_child(item);
            item.inner_anchor = Vec2(0, 1);
            item.outer_anchor = Vec2(0, 1);
            item.selectable = row_selectable;
            item.selected.connect(item_selected);
        }

        resized();
    }

    protected override void resized()
    {
        if (header != null)
            header.size = Size2(size.width, row_height);

        if (items == null)
            return;

        for (int i = 0; i < items.length; i++)
        {
            ListItemControl item = items[i];
            item.size = Size2(size.width, row_height);
            item.position = Vec2(0, -(i + 1) * row_height);
        }
    }

    protected override void on_click(Vec2 pos)
    {
        item_selected(null);
    }

    /*protected override void do_mouse_event(MouseEventArgs mouse)
    {
        base.do_mouse_event(mouse);

        bool focus = false;
        foreach (ListItemControl control in items)
        {
            if (control.focused)
            {
                focus = true;
                break;
            }
        }

        if (!focus)
            item_selected(null);
    }*/

    private void item_selected(ListItemControl? control)
    {
        foreach (ListItemControl item in items)
            item.is_selected = item == control;

        if (control == null)
            selected_index = -1;
        else
            selected_index = control.index;

        selected_index_changed(this);
    }

    protected virtual void on_added() {}
    protected abstract string get_cell_data(int row, int column);
    protected abstract ListColumnInfo get_column_info(int column);

    public float row_height { get; set; }
    public float font_size { get; set; }
    public int selected_index { get; private set; }
    protected abstract int row_count { get; }
    protected abstract int column_count { get; }

    private class ListItemControl : Control
    {
        private RectangleControl background;
        private ListCell[]? cells;
        private bool is_header;

        public signal void selected(ListItemControl control);

        public ListItemControl(ListCell[] cells, int index)
        {
            this.cells = cells;
            this.index = index;
            is_header = false;
        }

        public ListItemControl.header(ListCell[] cells)
        {
            this.cells = cells;
            index = -1;
            is_header = true;
        }

        public override void added()
        {
            resize_style = ResizeStyle.ABSOLUTE;

            background = new RectangleControl();
            add_child(background);
            background.resize_style = ResizeStyle.RELATIVE;

            if (is_header)
                background.color = Color(0.9f, 0.03f, 0.03f, 1);
            else
            {
                background.color = Color(0.8f, 0, 0, 0.6f);
                selectable = true;
            }

            foreach (ListCell cell in cells)
                add_child(cell);
        }

        protected override void resized()
        {
            if (cells == null)
                return;

            float rest_width = size.width;
            float relative_width = 0;

            foreach (ListCell cell in cells)
            {
                if (cell.style.resize_style == ResizeStyle.ABSOLUTE)
                {
                    rest_width -= cell.style.width;
                    cell.size = Size2(cell.style.width, size.height);
                }
                else
                    relative_width += cell.style.width;
            }

            foreach (ListCell cell in cells)
                if (cell.style.resize_style == ResizeStyle.RELATIVE)
                    cell.size = Size2(rest_width * (cell.style.width / relative_width), size.height);

            float pos = 0;
            foreach (ListCell cell in cells)
            {
                cell.position = Vec2(pos, 0);
                pos += cell.size.width;
            }
        }

        protected override void do_render(RenderState state, RenderScene2D scene)
        {
            if (is_header)
                return;

            if (is_selected)
            {
                if (hovering)
                {
                    if (mouse_down)
                        background.color = Color(0.75f, 0.225f, 0.025f, 1);
                    else
                        background.color = Color(0.9f, 0.23f, 0.03f, 1);
                }
                else
                    background.color = Color(0.6f, 0.22f, 0.02f, 1);
            }
            else
            {
                if (hovering)
                {
                    if (mouse_down)
                        background.color = Color(0.75f, 0.025f, 0.025f, 1);
                    else
                        background.color = Color(0.9f, 0.03f, 0.03f, 1);
                }
                else
                    background.color = Color(0.2f, 0.005f, 0.005f, 1);
            }
        }

        protected override void on_click(Vec2 position)
        {
            selected(this);
        }

        public int index { get; private set; }
        public bool is_selected { get; set; }
    }

    private class ListCell : Control
    {
        private LabelControl label;
        private float font_size;

        public ListCell(string text, ListCellStyle style, float font_size)
        {
            this.text = text;
            this.style = style;
            this.font_size = font_size;
        }

        public override void added()
        {
            resize_style = ResizeStyle.ABSOLUTE;
            inner_anchor = Vec2(0, 0.5f);
            outer_anchor = Vec2(0, 0.5f);

            label = new LabelControl();
            add_child(label);
            label.inner_anchor = Vec2(0, 0.5f);
            label.outer_anchor = Vec2(0, 0.5f);
            label.text = text;
            label.font_size = font_size;
        }

        public string text { get; private set; }
        public ListCellStyle style { get; private set; }
    }
}

public class ListColumnInfo
{
    public ListColumnInfo(string name, ListCellStyle style)
    {
        this.name = name;
        this.style = style;
    }

    public string name { get; private set; }
    public ListCellStyle style { get; private set; }
}

public class ListCellStyle
{
    public ListCellStyle(ResizeStyle resize_style, float width)
    {
        this.resize_style = resize_style;
        this.width = width;
    }

    public ResizeStyle resize_style { get; private set; }
    public float width { get; private set; }
}
