using GL;
using Gee;

public class GameRenderView : View, IGameRenderer
{
    private RenderTile[] tiles;
    private RenderPlayer[] players;
    private GameStartState start_state;

    private RenderSceneManager scene;
    private ServerMessageParser parser = new ServerMessageParser();
    private RenderTile? mouse_down_tile;
    private ArrayList<TileSelectionGroup>? select_groups = null;
    private ArrayList<RenderPlayer> tenpai_players = new ArrayList<RenderPlayer>();

    public GameRenderView(GameStartState state)
    {
        start_state = state;

        parser.connect(server_tile_assignment, typeof(ServerMessageTileAssignment));
        parser.connect(server_tile_draw, typeof(ServerMessageTileDraw));
        parser.connect(server_tile_discard, typeof(ServerMessageTileDiscard));
        parser.connect(server_flip_dora, typeof(ServerMessageFlipDora));
        parser.connect(server_dead_tile_add, typeof(ServerMessageDeadTileAdd));

        parser.connect(server_ron, typeof(ServerMessageRon));
        parser.connect(server_tsumo, typeof(ServerMessageTsumo));
        parser.connect(server_riichi, typeof(ServerMessageRiichi));
        parser.connect(server_late_kan, typeof(ServerMessageLateKan));
        parser.connect(server_closed_kan, typeof(ServerMessageClosedKan));
        parser.connect(server_open_kan, typeof(ServerMessageOpenKan));
        parser.connect(server_pon, typeof(ServerMessagePon));
        parser.connect(server_chii, typeof(ServerMessageChii));
        parser.connect(server_tenpai_player, typeof(ServerMessageTenpaiPlayer));
        parser.connect(server_draw, typeof(ServerMessageDraw));

        scene = new RenderSceneManager(state.player_ID, state.round_wind, state.dealer, state.wall_index);
    }

    public override void added()
    {
        scene.added(store);
        tiles = scene.tiles;
        players = scene.players;
    }

    public override void do_process(DeltaArgs delta)
    {
        parser.dequeue();
        scene.process(delta);
    }

    public override void do_render(RenderState state)
    {
        scene.render(state);
    }

    private void server_tile_assignment(ServerMessage message)
    {
        ServerMessageTileAssignment tile_assignment = (ServerMessageTileAssignment)message;
        tiles[tile_assignment.tile_ID].assign_type(tile_assignment.get_tile(), store);
    }

    private void server_tile_draw(ServerMessage message)
    {
        ServerMessageTileDraw tile_draw = (ServerMessageTileDraw)message;
        RenderPlayer player = players[tile_draw.player_ID];

        if (tile_draw.dead_wall)
            player.draw_tile(scene.wall.draw_dead_wall());
        else
            player.draw_tile(scene.wall.draw_wall());
    }

    private void server_tile_discard(ServerMessage message)
    {
        ServerMessageTileDiscard tile_discard = (ServerMessageTileDiscard)message;
        RenderPlayer player = players[tile_discard.player_ID];
        RenderTile tile = tiles[tile_discard.tile_ID];
        player.discard(tile);
    }

    private void server_flip_dora(ServerMessage message)
    {
        scene.wall.flip_dora();
    }

    private void server_dead_tile_add(ServerMessage message)
    {
        scene.wall.dead_tile_add();
    }

    private void server_ron(ServerMessage message)
    {
        ServerMessageRon ron = (ServerMessageRon)message;
        RenderPlayer player = players[ron.player_ID];
        RenderPlayer discard_player = players[ron.discard_player_ID];

        RenderTile tile = tiles[ron.tile_ID];
        discard_player.rob_tile(tile);

        scene.ron(player, tile);
    }

    private void server_tsumo(ServerMessage message)
    {
        ServerMessageTsumo tsumo = (ServerMessageTsumo)message;
        RenderPlayer player = players[tsumo.player_ID];

        scene.tsumo(player);
    }

    private void server_riichi(ServerMessage message)
    {
        ServerMessageRiichi riichi = (ServerMessageRiichi)message;
        RenderPlayer player = players[riichi.player_ID];

        player.riichi();
    }

    private void server_late_kan(ServerMessage message)
    {
        ServerMessageLateKan kan = (ServerMessageLateKan)message;
        RenderPlayer player = players[kan.player_ID];
        RenderTile tile = tiles[kan.tile_ID];
        player.late_kan(tile);
    }

    private void server_closed_kan(ServerMessage message)
    {
        ServerMessageClosedKan kan = (ServerMessageClosedKan)message;
        RenderPlayer player = players[kan.player_ID];
        player.closed_kan(kan.get_type_enum());
    }

    private void server_open_kan(ServerMessage message)
    {
        ServerMessageOpenKan kan = (ServerMessageOpenKan)message;
        RenderPlayer player = players[kan.player_ID];
        RenderPlayer discard_player = players[kan.discard_player_ID];

        RenderTile tile   = tiles[kan.tile_ID];
        RenderTile tile_1 = tiles[kan.tile_1_ID];
        RenderTile tile_2 = tiles[kan.tile_2_ID];
        RenderTile tile_3 = tiles[kan.tile_3_ID];

        discard_player.rob_tile(tile);
        player.open_kan(discard_player, tile, tile_1, tile_2, tile_3);
    }

    private void server_pon(ServerMessage message)
    {
        ServerMessagePon pon = (ServerMessagePon)message;
        RenderPlayer player = players[pon.player_ID];
        RenderPlayer discard_player = players[pon.discard_player_ID];

        RenderTile tile   = tiles[pon.tile_ID];
        RenderTile tile_1 = tiles[pon.tile_1_ID];
        RenderTile tile_2 = tiles[pon.tile_2_ID];

        discard_player.rob_tile(tile);
        player.pon(discard_player, tile, tile_1, tile_2);
    }

    private void server_chii(ServerMessage message)
    {
        ServerMessageChii chii = (ServerMessageChii)message;
        RenderPlayer player = players[chii.player_ID];
        RenderPlayer discard_player = players[chii.discard_player_ID];

        RenderTile tile   = tiles[chii.tile_ID];
        RenderTile tile_1 = tiles[chii.tile_1_ID];
        RenderTile tile_2 = tiles[chii.tile_2_ID];

        discard_player.rob_tile(tile);
        player.chii(discard_player, tile, tile_1, tile_2);
    }

    private void server_tenpai_player(ServerMessage message)
    {
        ServerMessageTenpaiPlayer tenpai = (ServerMessageTenpaiPlayer)message;
        RenderPlayer player = players[tenpai.player_ID];

        tenpai_players.add(player);
    }

    private void server_draw(ServerMessage message)
    {
        scene.draw(tenpai_players);
    }

    /////////////////////

    public void receive_message(ServerMessage message)
    {
        parser.add(message);
    }

    protected override void do_mouse_move(MouseMoveArgs mouse)
    {
        for (int i = 0; i < tiles.length; i++)
            tiles[i].set_hovered(false);

        RenderTile? tile = null;
        if (!mouse.handled && active)
            tile = get_hover_tile(scene.camera, scene.observer.hand_tiles, mouse.pos_x, mouse.pos_y);

        bool hovered = false;

        if (tile != null)
        {
            if (select_groups == null)
            {
                tile.set_hovered(true);
                hovered = true;
            }
            else
            {
                TileSelectionGroup? group = get_tile_selection_group(tile);

                if (group != null)
                {
                    foreach (Tile t in group.highlight_tiles)
                        tiles[t.ID].set_hovered(true);

                    hovered = true;
                }
            }
        }

        if (hovered)
        {
            mouse.cursor_type = CursorType.HOVER;
            mouse.handled = true;
        }
    }

    private TileSelectionGroup? get_tile_selection_group(RenderTile? tile)
    {
        if (tile == null || select_groups == null)
            return null;

        foreach (TileSelectionGroup group in select_groups)
            foreach (Tile t in group.selection_tiles)
                if (t.ID == tile.tile_type.ID)
                    return group;

        return null;
    }

    protected override void do_mouse_event(MouseEventArgs mouse)
    {
        if (!active)
        {
            mouse_down_tile = null;
            return;
        }

        if (mouse.button == MouseEventArgs.Button.LEFT)
        {
            RenderTile? tile = get_hover_tile(scene.camera, scene.observer.hand_tiles, mouse.pos_x, mouse.pos_y);

            if (mouse.down)
            {
                if (select_groups != null && get_tile_selection_group(tile) == null)
                    tile = null;

                mouse_down_tile = tile;
            }
            else
            {
                if (select_groups != null && get_tile_selection_group(tile) == null)
                    tile = null;

                if (tile != null && tile == mouse_down_tile)
                    tile_selected(tile.tile_type);

                mouse_down_tile = null;
            }
        }
    }

    private RenderTile? get_hover_tile(Camera camera, ArrayList<RenderTile> tiles, int x, int y)
    {
        float width = parent_window.width;
        float height = parent_window.height;
        float aspect_ratio = width / height;
        float focal_length = camera.focal_length;
        Mat4 projection_matrix = parent_window.renderer.get_projection_matrix(focal_length, aspect_ratio);
        Mat4 view_matrix = camera.get_view_transform(false);
        Vec3 ray = Calculations.get_ray(projection_matrix, view_matrix, x, y, width, height);

        float shortest = 0;
        RenderTile? shortest_tile = null;

        for (int i = 0; i < tiles.size; i++)
        {
            RenderTile tile = tiles.get(i);
            float collision_distance = Calculations.get_collision_distance(tile.tile, camera.position, ray);

            if (collision_distance >= 0)
                if (shortest_tile == null || collision_distance < shortest)
                {
                    shortest = collision_distance;
                    shortest_tile = tile;
                }
        }

        return shortest_tile;
    }

    protected override void do_key_press(KeyArgs key)
    {
        switch (key.key)
        {
        case 118:
            parent_window.renderer.v_sync = !parent_window.renderer.v_sync;
            print("V-Sync is now %s\n", parent_window.renderer.v_sync ? "enabled" : "disabled");
            break;
        default:
            //print("%i\n", (int)key.key);
            break;
        }
    }

    public void set_active(bool active)
    {
        this.active = active;
    }

    public void set_tile_select_groups(ArrayList<TileSelectionGroup>? groups)
    {
        select_groups = groups;
    }

    public bool active { get; set; }
}
