using GL;
using Gee;

public class GameRenderView : View3D, IGameRenderer
{
    private RenderTile[] tiles;
    private RenderPlayer[] players;

    private RenderSceneManager scene;
    private RenderTile? mouse_down_tile;
    private ArrayList<TileSelectionGroup>? select_groups = null;

    private Sound hover_sound;

    private RoundStartInfo info;
    private int player_index;
    private Wind round_wind;
    private int dealer_index;
    private Options options;
    private RoundScoreState score;

    public GameRenderView(RoundStartInfo info, int player_index, Wind round_wind, int dealer_index, Options options, RoundScoreState score)
    {
        this.info = info;
        this.player_index = player_index;
        this.round_wind = round_wind;
        this.dealer_index = dealer_index;
        this.options = options;
        this.score = score;
    }

    public override void added()
    {
        scene = new RenderSceneManager(options, player_index, round_wind, dealer_index, info.wall_index, store.audio_player, score);

        scene.added(store);
        tiles = scene.tiles;
        players = scene.players;

        hover_sound = store.audio_player.load_sound("mouse_over");

        buffer_action(new RenderActionDelay(0.5f));
        buffer_action(new RenderActionSplitDeadWall());

        int index = dealer_index;

        for (int i = 0; i < 3; i++)
        {
            for (int p = 0; p < 4; p++)
            {
                buffer_action(new RenderActionInitialDraw(players[index % 4], 4));
                index++;
            }
        }

        for (int p = 0; p < 4; p++)
        {
            buffer_action(new RenderActionInitialDraw(players[index % 4], 1));
            index++;
        }

        buffer_action(new RenderActionFlipDora());
    }

    public override void do_process(DeltaArgs delta)
    {
        scene.process(delta);
    }

    public override void do_render_3D(RenderState state)
    {
        scene.render(state);
    }

    public void load_options(Options options)
    {
        scene.load_options(store, options);
    }

    private void game_finished(RoundFinishResult results)
    {
        switch (results.result)
        {
        case RoundFinishResult.RoundResultEnum.DRAW:
            draw(results.tenpai_indices, results.draw_type);
            break;
        case RoundFinishResult.RoundResultEnum.RON:
            ron(results.winner_indices, results.loser_index, results.discard_tile, results.riichi_return_index, true);
            break;
        case RoundFinishResult.RoundResultEnum.TSUMO:
            tsumo(results.winner_indices[0]);
            break;
        }
    }

    private void ron(int[] winner_indices, int discard_player_index, int tile_ID, int return_riichi_index, bool allow_dora_flip)
    {
        RenderPlayer? discard_player = null;
        if (discard_player_index != -1)
            discard_player = players[discard_player_index];

        RenderPlayer? return_riichi_player = null;
        if (return_riichi_index != -1)
            return_riichi_player = players[return_riichi_index];

        RenderTile? tile = null;

        if (tile_ID != -1)
        {
            tile = tiles[tile_ID];
            discard_player.rob_tile(tile);
        }

        RenderPlayer[] winners = new RenderPlayer[winner_indices.length];
        for (int i = 0; i < winners.length; i++)
            winners[i] = players[winner_indices[i]];

        buffer_action(new RenderActionRon(winners, discard_player, tile, return_riichi_player, allow_dora_flip));
    }

    private void tsumo(int player_index)
    {
        RenderPlayer player = players[player_index];
        buffer_action(new RenderActionTsumo(player));
    }

    private void draw(int[] tenpai_indices, GameDrawType draw_type)
    {
        if (draw_type == GameDrawType.TRIPLE_RON)
        {
            ron(tenpai_indices, -1, -1, -1, false);
            return;
        }

        if (draw_type == GameDrawType.EMPTY_WALL ||
            draw_type == GameDrawType.FOUR_RIICHI ||
            draw_type == GameDrawType.VOID_HAND ||
            draw_type == GameDrawType.TRIPLE_RON)
        {
            ArrayList<RenderPlayer> tenpai_players = new ArrayList<RenderPlayer>();
            foreach (int i in tenpai_indices)
                tenpai_players.add(players[i]);

            buffer_action(new RenderActionGameDraw(tenpai_players, draw_type));
        }
    }

    private void tile_assignment(Tile tile)
    {
        tiles[tile.ID].assign_type(tile, store);
    }

    private void tile_draw(int player_index)
    {
        RenderPlayer player = players[player_index];
        buffer_action(new RenderActionDraw(player));

        /*if (tile_draw.dead_wall)
            player.draw_tile(scene.wall.draw_dead_wall());
        else
            player.draw_tile(scene.wall.draw_wall());*/
    }

    public void dead_tile_draw(int player_index)
    {
        RenderPlayer player = players[player_index];
        buffer_action(new RenderActionDrawDeadWall(player));
    }

    private void tile_discard(int player_index, int tile_ID)
    {
        RenderPlayer player = players[player_index];
        RenderTile tile = tiles[tile_ID];
        buffer_action(new RenderActionDiscard(player, tile));
    }

    private void flip_dora()
    {
        scene.wall.flip_dora();
    }

    /*private void server_dead_tile_add()
    {
        scene.wall.dead_tile_add();
    }*/

    private void riichi(int player_index, bool open)
    {
        RenderPlayer player = players[player_index];
        buffer_action(new RenderActionRiichi(player, open));
    }

    private void late_kan(int player_index, int tile_ID)
    {
        RenderPlayer player = players[player_index];
        RenderTile tile = tiles[tile_ID];
        buffer_action(new RenderActionLateKan(player, tile));
    }

    private void closed_kan(int player_index, TileType type)
    {
        RenderPlayer player = players[player_index];
        buffer_action(new RenderActionClosedKan(player, type));
    }

    private void open_kan(int player_index, int discard_player_index, int tile_ID, int tile_1_ID, int tile_2_ID, int tile_3_ID)
    {
        RenderPlayer player = players[player_index];
        RenderPlayer discard_player = players[discard_player_index];

        RenderTile tile   = tiles[tile_ID];
        RenderTile tile_1 = tiles[tile_1_ID];
        RenderTile tile_2 = tiles[tile_2_ID];
        RenderTile tile_3 = tiles[tile_3_ID];

        buffer_action(new RenderActionOpenKan(player, discard_player, tile, tile_1, tile_2, tile_3));

        dead_tile_draw(player_index);
    }

    private void pon(int player_index, int discard_player_index, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        RenderPlayer player = players[player_index];
        RenderPlayer discard_player = players[discard_player_index];

        RenderTile tile   = tiles[tile_ID];
        RenderTile tile_1 = tiles[tile_1_ID];
        RenderTile tile_2 = tiles[tile_2_ID];

        buffer_action(new RenderActionPon(player, discard_player, tile, tile_1, tile_2));
    }

    private void chii(int player_index, int discard_player_index, int tile_ID, int tile_1_ID, int tile_2_ID)
    {
        RenderPlayer player = players[player_index];
        RenderPlayer discard_player = players[discard_player_index];

        RenderTile tile   = tiles[tile_ID];
        RenderTile tile_1 = tiles[tile_1_ID];
        RenderTile tile_2 = tiles[tile_2_ID];

        buffer_action(new RenderActionChii(player, discard_player, tile, tile_1, tile_2));
    }

    public void set_active(bool active)
    {
        if (active)
            buffer_action(new RenderActionSetActive(active));
        else
            scene.active = active;

        if (!active)
            foreach (RenderTile tile in tiles)
                tile.indicated = false;
    }

    /////////////////////

    private void buffer_action(RenderAction action)
    {
        scene.add_action(action);
    }

    protected override void do_mouse_move(MouseMoveArgs mouse)
    {
        RenderTile? tile = null;
        if (!mouse.handled && scene.active)
            tile = get_hover_tile(scene.camera, scene.observer.hand_tiles, mouse.position);

        bool hovered = false;

        if (tile != null)
        {
            if (select_groups == null)
            {
                if (!tile.hovered)
                    hover_sound.play();

                foreach (RenderTile t in tiles)
                    t.hovered = false;

                tile.hovered = true;
                hovered = true;
            }
            else
            {
                TileSelectionGroup? group = get_tile_selection_group(tile);

                if (group != null)
                {
                    if (!tile.hovered)
                        hover_sound.play();
                    foreach (RenderTile t in tiles)
                        t.hovered = false;
                    foreach (Tile t in group.highlight_tiles)
                        tiles[t.ID].hovered = true;

                    hovered = true;
                }
                else
                    foreach (RenderTile t in tiles)
                        t.hovered = false;
            }
        }
        else
            foreach (RenderTile t in tiles)
                t.hovered = false;

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
        if (mouse.handled || !scene.active)
        {
            mouse_down_tile = null;
            return;
        }

        if (mouse.button == MouseEventArgs.Button.LEFT)
        {
            RenderTile? tile = get_hover_tile(scene.camera, scene.observer.hand_tiles, mouse.position);

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

    private RenderTile? get_hover_tile(Camera camera, ArrayList<RenderTile> tiles, Vec2i position)
    {
        Size2 size = Size2(parent_window.size.width, parent_window.size.height);
        float aspect_ratio = size.width / size.height;
        float focal_length = camera.focal_length;

        Mat4 projection_matrix = parent_window.renderer.get_projection_matrix(focal_length, aspect_ratio);
        Mat4 view_matrix = camera.get_view_transform();
        Vec3 ray = Calculations.get_ray(projection_matrix, view_matrix, position, Size2i((int)size.width, (int)size.height));

        float shortest = 0;
        RenderTile? shortest_tile = null;

        for (int i = 0; i < tiles.size; i++)
        {
            RenderTile tile = tiles.get(i);
            float collision_distance = Calculations.get_collision_distance(camera.position, ray, tile.model_size.mul_scalar(1.0f), tile.tile.transform);

            if (collision_distance >= 0)
                if (shortest_tile == null || collision_distance < shortest)
                {
                    shortest = collision_distance;
                    shortest_tile = tile;
                }
        }

        return shortest_tile;
    }

    public void set_tile_select_groups(ArrayList<TileSelectionGroup>? groups)
    {
        foreach (RenderTile tile in tiles)
            tile.indicated = false;

        select_groups = groups;

        if (groups != null)
            foreach (TileSelectionGroup group in groups)
                if (group.group_type != TileSelectionGroup.GroupType.DISCARD)
                    foreach (Tile tile in group.highlight_tiles)
                        tiles[tile.ID].indicated = true;
    }
}
