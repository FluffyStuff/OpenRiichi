using Engine;
using Gee;

class GameScene : WorldObject
{
    private GameRenderContext context;
    private int observer_index;
    private Options options;
    private RoundScoreState score;

    private AudioPlayer audio;
    private Sound slide_sound;
    private Sound flip_sound;
    private Sound discard_sound;
    private Sound draw_sound;
    private Sound ron_sound;
    private Sound tsumo_sound;
    private Sound riichi_sound;
    private Sound kan_sound;
    private Sound pon_sound;
    private Sound chii_sound;
    private Sound reveal_sound;

    private RenderTable table;

    private Mutex action_lock;
    private ArrayList<RenderAction> actions = new ArrayList<RenderAction>();
    private RenderAction? current_action = null;
    private float action_start_time;

    public GameScene(GameRenderContext context, int observer_index, Options options, AudioPlayer audio, RoundScoreState score)
    {
        this.context = context;
        this.observer_index = observer_index;
        this.options = options;
        this.audio = audio;
        this.score = score;
    }

    public override void added()
    {
        slide_sound = audio.load_sound("slide");
        flip_sound = audio.load_sound("flip");
        discard_sound = audio.load_sound("discard");
        draw_sound = audio.load_sound("draw");
        ron_sound = audio.load_sound("ron");
        tsumo_sound = audio.load_sound("tsumo");
        riichi_sound = audio.load_sound("riichi");
        kan_sound = audio.load_sound("kan");
        pon_sound = audio.load_sound("pon");
        chii_sound = audio.load_sound("chii");
        reveal_sound = audio.load_sound("reveal");

        RenderTile[] tiles = new RenderTile[136];
        for (int i = 0; i < tiles.length; i++)
        {
            tiles[i] = new RenderTile();
            add_object(tiles[i]);
            tiles[i].scale = context.tile_scale;
        }

        table = new RenderTable(context, tiles, observer_index, score);
        add_object(table);
        load_options(options);
    }

    public void load_options(Options options)
    {
        this.options = options;

        foreach (RenderTile tile in tiles)
        {
            tile.model_quality = options.model_quality;
            tile.texture_type = options.tile_textures;
            tile.front_color = options.tile_fore_color;
            tile.back_color = options.tile_back_color;
            tile.reload();
        }
        table.reload(options.model_quality, options.table_texture_path);
    }

    public override void process(DeltaArgs delta)
    {
        if (current_action != null &&
            delta.time - action_start_time > current_action.time.total())
            current_action = null;

        if (current_action == null)
        {
            lock (action_lock)
            {
                if (actions.size != 0)
                {
                    current_action = actions[0];
                    actions.remove_at(0);

                    action_start_time = delta.time;
                    do_action(current_action);
                }
            }
        }
    }

    public void add_action(RenderAction action)
    {
        lock (action_lock)
            actions.add(action);
    }

    private void do_action(RenderAction action)
    {
        if (action is RenderActionSplitDeadWall)
            action_split_dead_wall(action as RenderActionSplitDeadWall);
        else if (action is RenderActionInitialDraw)
            action_initial_draw(action as RenderActionInitialDraw);
        else if (action is RenderActionDraw)
            action_draw(action as RenderActionDraw);
        else if (action is RenderActionDrawDeadWall)
            action_draw_dead_wall(action as RenderActionDrawDeadWall);
        else if (action is RenderActionDiscard)
            action_discard(action as RenderActionDiscard);
        else if (action is RenderActionRon)
            action_ron(action as RenderActionRon);
        else if (action is RenderActionTsumo)
            action_tsumo(action as RenderActionTsumo);
        else if (action is RenderActionRiichi)
            action_riichi(action as RenderActionRiichi);
        else if (action is RenderActionReturnRiichi)
            action_return_riichi(action as RenderActionReturnRiichi);
        else if (action is RenderActionLateKan)
            action_late_kan(action as RenderActionLateKan);
        else if (action is RenderActionClosedKan)
            action_closed_kan(action as RenderActionClosedKan);
        else if (action is RenderActionOpenKan)
            action_open_kan(action as RenderActionOpenKan);
        else if (action is RenderActionPon)
            action_pon(action as RenderActionPon);
        else if (action is RenderActionChii)
            action_chii(action as RenderActionChii);
        else if (action is RenderActionGameDraw)
            action_game_draw(action as RenderActionGameDraw);
        else if (action is RenderActionHandReveal)
            action_hand_reveal(action as RenderActionHandReveal);
        else if (action is RenderActionFlipDora)
            action_flip_dora(action as RenderActionFlipDora);
        else if (action is RenderActionFlipUraDora)
            action_flip_ura_dora(action as RenderActionFlipUraDora);
        else if (action is RenderActionSetActive)
            action_set_active(action as RenderActionSetActive);
    }

    private void action_split_dead_wall(RenderActionSplitDeadWall action)
    {
        slide_sound.play();
        table.split_dead_wall(context.server_times.split_wall);
    }

    private void action_initial_draw(RenderActionInitialDraw action)
    {
        draw_sound.play();
        for (int i = 0; i < action.tiles; i++)
            action.player.draw_tile(wall.draw_wall());
    }

    private void action_draw(RenderActionDraw action)
    {
        draw_sound.play();
        action.player.draw_tile(wall.draw_wall());

        if (action.player.seat == context.observer_index)
            active = true;
    }

    private void action_draw_dead_wall(RenderActionDrawDeadWall action)
    {
        wall.flip_dora();
        wall.dead_tile_add();
        draw_sound.play();
        action.player.draw_tile(wall.draw_dead_wall());

        if (action.player.seat == context.observer_index)
            active = true;
    }

    private void action_discard(RenderActionDiscard action)
    {
        discard_sound.play();
        action.player.discard(action.tile);
    }

    private void action_ron(RenderActionRon action)
    {
        ron_sound.play();

        var winners = action.get_winners();
        if (winners.length == 1 && action.tile != null)
            winners[0].ron(action.tile);

        bool flip_ura_dora = false;

        foreach (RenderPlayer player in winners)
        {
            if (!player.open)
                add_action(new RenderActionHandReveal(new AnimationTime.zero(), player));
            if (player.in_riichi)
                flip_ura_dora = true;
        }

        if (action.return_riichi_player != null)
            add_action(new RenderActionReturnRiichi(new AnimationTime.zero(), action.return_riichi_player));

        if (flip_ura_dora && action.allow_dora_flip)
            add_action(new RenderActionFlipUraDora(new AnimationTime.zero()));
    }

    private void action_tsumo(RenderActionTsumo action)
    {
        tsumo_sound.play();
        action.player.tsumo();

        if (!action.player.open)
            add_action(new RenderActionHandReveal(context.server_times.hand_reveal, action.player));

        if (action.player.in_riichi)
            add_action(new RenderActionFlipUraDora(new AnimationTime.zero()));
    }

    private void action_riichi(RenderActionRiichi action)
    {
        riichi_sound.play();
        if (action.open)
            reveal_sound.play();

        action.player.riichi(action.open);
    }

    // Non-blocking
    private void action_return_riichi(RenderActionReturnRiichi action)
    {
        action.player.return_riichi(context.server_times.riichi);
    }

    private void action_late_kan(RenderActionLateKan action)
    {
        action.player.late_kan(action.tile, action.time);
        kan_sound.play();
    }

    private void action_closed_kan(RenderActionClosedKan action)
    {
        action.player.closed_kan(action.tile_type, action.time);
        kan_sound.play();
    }

    private void action_open_kan(RenderActionOpenKan action)
    {
        kan_sound.play();
        action.discarder.rob_tile(action.tile);
        action.player.open_kan(action.discarder, action.tile, action.tile_1, action.tile_2, action.tile_3);

        if (action.player.seat == context.observer_index)
            active = true;
    }

    private void action_pon(RenderActionPon action)
    {
        pon_sound.play();
        action.discarder.rob_tile(action.tile);
        action.player.pon(action.discarder, action.tile, action.tile_1, action.tile_2);

        if (action.player.seat == context.observer_index)
            active = true;
    }

    private void action_chii(RenderActionChii action)
    {
        chii_sound.play();
        action.discarder.rob_tile(action.tile);
        action.player.chii(action.tile, action.tile_1, action.tile_2, action.time);

        if (action.player.seat == context.observer_index)
            active = true;
    }

    private void action_game_draw(RenderActionGameDraw action)
    {
        bool revealed = false;

        foreach (RenderPlayer player in players)
        {
            if (action.players.contains(player))
            {
                if (!player.open)
                {
                    player.open_hand();
                    revealed = true;
                }
            }
            else if (player != observer && action.draw_type != GameDrawType.VOID_HAND)
            {
                player.close_hand();
                revealed = true;
            }
        }

        if (revealed)
            reveal_sound.play();
    }

    private void action_hand_reveal(RenderActionHandReveal action)
    {
        reveal_sound.play();
        action.player.open_hand();
    }

    private void action_flip_dora(RenderActionFlipDora action)
    {
        flip_sound.play();
        wall.flip_dora();
    }

    private void action_flip_ura_dora(RenderActionFlipUraDora action)
    {
        flip_sound.play();
        wall.flip_ura_dora();
    }

    private void action_set_active(RenderActionSetActive action)
    {
        active = action.active;
    }

    public RenderPlayer[] players { get { return table.players; } }
    public RenderTile[] tiles { get { return table.tiles; } }
    public RenderWall wall { get { return table.wall; } }
    public RenderPlayer observer { get; private set; }
    public bool active { get; set; }
}
