using Gee;
using GL;
using SDL;

// TODO: Add classes for normal/dead wall and other stuff
public class Game
{
    private static Rand rnd = new Rand();

    private GameInterface ui = new GameInterface();
    private GameState state = GameState.WAITING_TURN;
    private Board board = new Board(6);
    private Player[] players = new Player[4];
    private Tile[] tiles = new Tile[136];
    private ArrayList<Tile> dead_wall = new ArrayList<Tile>();
    private ArrayList<Tile> wall_tiles = new ArrayList<Tile>();
    private ArrayList<Tile> dora_tiles = new ArrayList<Tile>();
    private Tile? last_played_tile;
    private int drawing_tile;
    private int kan_count = 0;
    private int current_player = 0;
    private int game_turn = 0;
    private bool first_round = true;
    private int player_seat = 0;

    public Game()
    {
        uint8 wall_split = (uint8)rnd.int_range(2, 12);

        uint8[] tiles = new uint8[this.tiles.length];

        for (uint8 i = 0; i < tiles.length; i++)
            tiles[i] = i;

        for (uint8 i = 0; i < tiles.length; i++)
        {
            int r = rnd.int_range(0, tiles.length - 1);

            //r1 -= r1 % 4;
            //r2 -= r2 % 4;

            uint8 t = tiles[r];
            tiles[r] = tiles[i];
            tiles[i] = t;
        }

        Game.seed(tiles, wall_split, (uint8)rnd.int_range(0, 4));
    }

    public Game.seed(uint8[] tile_seed, uint8 wall_split, uint8 seat)
    {
        player_seat = (int)seat % 4;

        for (int i = 0; i < tiles.length; i++)
        {
            Tile t = new Tile(1, i, i / 4);
            t.rotation = new Vector(90, 0, 0);
            t.color_ID = i + 1;
            tiles[tile_seed[i]] = t;
        }

        for (int i = 0; i < tiles.length; i++)
        {
            wall_tiles.add(tiles[i]);

            float rot = (i / 34) * 90;
            float x = ((i % 34) / 2 - 8f) * (Tile.TILE_WIDTH + Tile.TILE_SPACING);
            float y = 2.2f;
            float z = Tile.TILE_LENGTH * (i % 2 == 0 ? 2 : 1);

            if (i / 34 == 1)
            {
                float a = x;
                x = y;
                y = -a;
            }
            else if (i / 34 == 2)
            {
                x = -x;
                y = -y;
            }
            else if (i / 34 == 3)
            {
                float a = x;
                x = -y;
                y = a;
            }

            tiles[i].rotation = new Vector(180, 0, rot);
            tiles[i].position = new Vector(x, y, z);
        }

        int starting_player = wall_split % 4;

        drawing_tile = int.max(starting_player * 34 + wall_split * 2 - 14, 0);
        dead_wall_split(starting_player, wall_split);

        flip_dora();

        for (int i = 0; i < 4; i++)
            players[i] = new Player(i, "Player" + i.to_string());

        for (int i = 0; i < 4; i++)
            players[i].computer_player = false;
        players[player_seat].computer_player = false;

        for (int i = 0; i < 52; i++)
        {
            int p = i < 48 ? (i / 4) % 4 : i % 4;
            drawing_tile = drawing_tile % wall_tiles.size;
            players[p].add_tile(wall_tiles[drawing_tile]);
            wall_tiles.remove(wall_tiles[drawing_tile]);
        }

        for (int i = 0; i < 4; i++)
            players[i].arrange_hand();

        game_start();
    }

    public void process(double dt)
    {
        if (state == GameState.WAITING_CALLS)
        {
            foreach (Player p in players)
                if (p.state != Player.PlayerState.READY)
                    return;

            int player = -1;

            foreach (Player p in players)
            {
                if (p == players[current_player] || p.call_action == null)
                    continue;
                else if (p.call_action.action == CallAction.CallActionEnum.RON)
                {
                    players[current_player].steal_tile(last_played_tile);
                    p.do_ron(last_played_tile);
                    state = GameState.FINISHED;
                    toggle_interface(false);
                    return;
                }
            }

            foreach (Player p in players)
            {
                if (p == players[current_player] || p.call_action == null)
                    continue;
                else if (p.call_action.action == CallAction.CallActionEnum.OPEN_KAN)
                {
                    //stdout.printf("Starting Open Kan for player: " + p.name + "\n");
                    p.do_open_kan(p.call_action.tiles, last_played_tile, current_player);
                    p.call_action = null;
                    players[current_player].steal_tile(last_played_tile);
                    player = p.position;
                    current_player = player;
                    draw_dead_wall();
                }
                else if (p.call_action.action == CallAction.CallActionEnum.PON)
                {
                    //stdout.printf("Starting Pon for player: " + p.name + "\n");
                    p.do_pon(p.call_action.tiles, last_played_tile, current_player);
                    p.call_action = null;
                    players[current_player].steal_tile(last_played_tile);
                    player = p.position;
                }
            }

            if (player == -1)
            {
                foreach (Player p in players)
                {
                    if (p == players[current_player] || p.call_action == null)
                        continue;
                    if (p.call_action.action == CallAction.CallActionEnum.CHI)
                    {
                        //stdout.printf("Starting Chi for player: " + p.name + "\n");
                        p.do_chi(p.call_action.tiles, last_played_tile);
                        p.call_action = null;
                        players[current_player].steal_tile(last_played_tile);
                        player = p.position;
                    }
                }
            }

            if (player == -1)
            {
                if (wall_tiles.size - kan_count <= 0)
                {
                    state = GameState.FINISHED;
                    return;
                }

                current_player = (current_player + 1) % 4;
                draw_tile();
            }
            else
            {
                current_player = player;
                first_round = false;
            }

            game_turn++;
            if (game_turn >= 4)
                first_round = false;

            state = GameState.WAITING_TURN;
            if (players[current_player].turn_decision() && !players[current_player].computer_player)
                toggle_interface(true);
        }

        if (state == GameState.WAITING_TURN)
        {
            if (players[current_player].state == Player.PlayerState.READY)
            {
                switch (players[current_player].turn_action.action)
                {
                    case TurnAction.TurnActionEnum.DISCARD:
                        //stdout.printf("Starting Discard for player: " + players[current_player].name + "\n");
                        players[current_player].discard_tile(players[current_player].turn_action.discard_tile);
                        discard_tile(players[current_player].turn_action.discard_tile);
                        break;
                    case TurnAction.TurnActionEnum.CLOSED_KAN:
                        //stdout.printf("Starting Closed Kan for player: " + players[current_player].name + "\n");
                        players[current_player].do_closed_kan(players[current_player].turn_action.kan_tiles);
                        draw_dead_wall();
                        players[current_player].turn_decision();
                        break;
                    case TurnAction.TurnActionEnum.LATE_KAN:
                        //stdout.printf("Starting Late Kan for player: " + players[current_player].name + "\n");
                        players[current_player].do_late_kan(players[current_player].turn_action.late_kan_tile, players[current_player].turn_action.late_kan_pon);
                        draw_dead_wall();
                        players[current_player].turn_decision();
                        break;
                    case TurnAction.TurnActionEnum.RIICHI:
                        players[current_player].do_riichi(players[current_player].turn_action.action == TurnAction.TurnActionEnum.OPEN_RIICHI, game_turn, players[current_player].turn_action.discard_tile);
                        discard_tile(players[current_player].turn_action.discard_tile);
                        break;
                    case TurnAction.TurnActionEnum.TSUMO:
                        players[current_player].do_tsumo();
                        state = GameState.FINISHED;
                        toggle_interface(false);
                        break;
                }
            }
        }
    }

    private void flip_dora()
    {
        if (dora_tiles.size >= 5)
            return;

        int tile = 5 + dora_tiles.size;

        if (dead_wall[tile].rotation.z % 180 == 0)
            dead_wall[tile].rotation.y += 180;
        else
            dead_wall[tile].rotation.x += 180;
        dead_wall[tile].position.z -= Tile.TILE_LENGTH;

        dora_tiles.add(dead_wall[tile]);
    }

    private void draw_tile()
    {
        // TODO: Remove kan_count once the wall tile moves to the dead wall correctly
        if (wall_tiles.size - kan_count <= 0)
            return;
        drawing_tile = drawing_tile % wall_tiles.size;

        Tile t = wall_tiles[drawing_tile];
        wall_tiles.remove(t);
        players[current_player].draw_tile(t);
    }

    private void draw_dead_wall()
    {
        if (kan_count >= 4)
            return;

        Tile t = dead_wall[1 - kan_count % 2];
        dead_wall.remove(t);
        players[current_player].draw_tile(t);
        kan_count++;

        // TODO: Add normal wall tile to dead wall

        flip_dora();
    }

    private void game_start()
    {
        state = GameState.WAITING_TURN;
        draw_tile();
        players[current_player].turn_decision();
    }

    private void discard_tile(Tile t)
    {
        last_played_tile = t;

        state = GameState.WAITING_CALLS;

        for (int i = 0; i < 4; i++)
        {
            if (i == current_player)
                continue;

            if (players[i].call_decision(t, i == (current_player + 1) % 4) && !players[i].computer_player)
                toggle_interface(true);
        }
    }

    private void dead_wall_split(int player, int number)
    {
        player = player % 4;
        number = number % 13;

        int start = 34 * player;
        int end = start + number * 2;
        float shift = /*Tile.TILE_WIDTH + */Tile.TILE_SPACING * 10; // Add TILE_WIDTH if moving wall tiles around
        int a = 0;

        for (int i = end - 1; i >= start; i--)
        {
            float offset = shift * (a < 14 ? 1 : 2);

            if (player == player_seat)
                tiles[i].position.x -= offset;
            else if (player == 1)
                tiles[i].position.y += offset;
            else if (player == 2)
                tiles[i].position.x += offset;
            else
                tiles[i].position.y -= offset;

            if (a < 14)
            {
                dead_wall.add(tiles[i]);
                wall_tiles.remove(tiles[i]);
            }
            a++;
        }

        start = (start - (7 - number) * 2 + 136) % 136;
        end = start + (7 - number) * 2;

        for (int i = end - 1; i >= start; i--)
        {
            if (player == 0)
                tiles[i].position.y += shift;
            else if (player == 1)
                tiles[i].position.x += shift;
            else if (player == 2)
                tiles[i].position.y -= shift;
            else
                tiles[i].position.x -= shift;

            dead_wall.add(tiles[i]);
            wall_tiles.remove(tiles[i]);
        }
    }

    public void render()
    {
        glRotated(-(GLdouble)player_seat * 90, 0, 0, 1);
        board.render();
        foreach (Player p in players)
            p.render();
        foreach (Tile t in wall_tiles)
            t.render();
        foreach (Tile t in dead_wall)
            t.render();
    }

    public void render_selection()
    {
        glRotated(-(GLdouble)player_seat * 90, 0, 0, 1);
        foreach (Player p in players)
            p.render_selection();
    }

    public void render_interface()
    {
        ui.render();
    }

    public void render_interface_selection()
    {
        ui.render_selection();
    }

    private void toggle_interface(bool show)
    {
        if (!(ui.visible = show))
            return;

        Player p = players[player_seat];

        if (state == GameState.WAITING_CALLS)
        {
            ui.show_pon = !p.in_riichi && Logic.can_pon(last_played_tile, p.hand);
            ui.show_kan = !p.in_riichi && Logic.can_open_kan(last_played_tile, p.hand);
            ui.show_chi = !p.in_riichi && (p.position == (current_player + 1) % 4 && Logic.can_chi(last_played_tile, p.hand));
            ui.show_riichi = false;
            ui.show_tsumo = false;
            ui.show_ron = Logic.can_win_with(p.hand, last_played_tile);
        }
        else
        {
            ui.show_pon = false;
            if (p.in_riichi)
                ui.show_kan = Logic.can_riichi_closed_kan(p.hand);
            else
                ui.show_kan = Logic.can_closed_kan(p.hand) || Logic.can_late_kan(p.hand, p.pons);
            ui.show_chi = false;
            ui.show_riichi = !p.open_hand && !p.in_riichi && Logic.can_tenpai(p.hand).size != 0;
            ui.show_tsumo = Logic.winning_hand(p.hand);
            ui.show_ron = false;
        }
    }

    public void mouse_click(int x, int y, uint color_id, bool mouse_state)
    {
        Player player = players[player_seat];

        Button button = ui.click(x, y, color_id, mouse_state);

        if (button != null)
        {
            switch (button.name)
            {
            case "Continue":
                do_continue();
                toggle_interface(false);
                break;
            case "Pon":
                do_pon();
                toggle_interface(false);
                break;
            case "Kan":
                if (state == GameState.WAITING_CALLS)
                {
                    do_open_kan();
                    toggle_interface(false);
                }
                else
                    do_closed_or_late_kan();
                break;
            case "Chi":
                do_chi();
                break;
            case "Riichi":
                state = GameState.WAITING_RIICHI_DISCARD;
                break;
            case "Tsumo":
                if (Logic.has_yaku(player, null, wall_tiles.size - kan_count == 0, false))
                {
                    player.turn_action = new TurnAction.tsumo();
                    player.state = Player.PlayerState.READY;
                }
                else
                {

                }
                break;
            case "Ron":
                if (Logic.has_yaku(player, null, wall_tiles.size - kan_count == 0, false))
                {
                    player.call_action = new CallAction.ron(last_played_tile);
                    player.state = Player.PlayerState.READY;
                }
                break;
            }

            return;
        }

        if (!mouse_state)
            return;

        Tile t = player.tile_press(color_id);
        if (t == null)
            return;

        t.hovering = false;

        if (state == GameState.WAITING_TURN)
        {
            player.turn_action = new TurnAction.discard(t);
            player.state = Player.PlayerState.READY;
            toggle_interface(false);
        }
        else if (state == GameState.WAITING_CHI)
        {
            Tile? tile = Logic.chi_combination(last_played_tile, t, player.hand);

            if (tile != null)
            {
                player.call_action = new CallAction(CallAction.CallActionEnum.CHI, new Tile[] { t, tile });
                player.state = Player.PlayerState.READY;
                state = GameState.WAITING_CALLS;
                toggle_interface(false);
            }
        }
        else if (state == GameState.WAITING_CLOSED_OR_LATE_KAN)
        {
            foreach (Pon p in player.pons)
                if (t.tile_type == p.tiles[0].tile_type)
                {
                    player.turn_action = new TurnAction.late_kan(t, p);
                    player.state = Player.PlayerState.READY;
                    toggle_interface(false);
                }

            Tile[] tiles = new Tile[4];
            int count = 0;

            foreach (Tile tile in player.hand)
            {
                if (t.tile_type == tile.tile_type)
                {
                    tiles[count++] = tile;

                    if (count == 4)
                    {
                        player.turn_action = new TurnAction.closed_kan(tiles);
                        player.state = Player.PlayerState.READY;
                        toggle_interface(false);
                    }
                }
            }
        }
        else if (state == GameState.WAITING_RIICHI_DISCARD)
        {
            player.turn_action = new TurnAction.riichi(t);
            player.state = Player.PlayerState.READY;
            state = GameState.WAITING_TURN;
            toggle_interface(false);
        }
    }

    public void mouse_move(int x, int y, uint color_id)
    {
        // TODO: Only update cursor if needed
        Player player = players[player_seat];

        if (ui.hover(x, y, color_id))
        {
            Environment.set_cursor(Environment.CursorType.HOVER);
            player.clear_hover();
        }
        else if (player.hover(color_id))
            Environment.set_cursor(Environment.CursorType.HOVER);
        else
            Environment.set_cursor(Environment.CursorType.DEFAULT);
    }

    private void do_continue()
    {
        Player player = players[player_seat];

        if (state == GameState.WAITING_CLOSED_OR_LATE_KAN)
        {
            state = GameState.WAITING_TURN;
        }
        else if (state == GameState.WAITING_CHI || state == GameState.WAITING_CALLS || state == GameState.WAITING_RIICHI_DISCARD)
        {
            player.call_action = null;
            player.state = Player.PlayerState.READY;
            state = GameState.WAITING_CALLS;
        }

        toggle_interface(false);
    }

    private void do_open_kan()
    {
        Player player = players[player_seat];

        Tile[] tiles = new Tile[3];

        int a = 0;
        foreach (Tile t in player.hand)
        {
            if (t.tile_type == last_played_tile.tile_type)
                tiles[a++] = t;

            if (a == 3)
            {
                player.call_action = new CallAction(CallAction.CallActionEnum.OPEN_KAN, tiles);
                player.state = Player.PlayerState.READY;
            }
        }
    }

    private void do_closed_or_late_kan()
    {
        Player player = players[player_seat];

        Tile? tile = null;
        Pon? pon = null;

        foreach (Pon p in player.pons)
            foreach (Tile t in player.hand)
                if (t.tile_type == p.tiles[0].tile_type)
                {
                    if (tile != null)
                    {
                        state = GameState.WAITING_CLOSED_OR_LATE_KAN;
                        return;
                    }

                    tile = t;
                    pon = p;
                    break;
                }

        Tile[]? tiles = null;
        foreach (Tile t1 in player.hand)
        {
            if (tiles != null && tiles[0].tile_type == t1.tile_type)
                continue;

            int count = 0;
            Tile[] temp = new Tile[4];

            foreach (Tile t2 in player.hand)
            {
                if (t1.tile_type == t2.tile_type)
                {
                    temp[count++] = t2;

                    if (count == 4)
                    {
                        if (tile != null || tiles != null)
                        {
                            state = GameState.WAITING_CLOSED_OR_LATE_KAN;
                            return;
                        }

                        tiles = temp;
                        break;
                    }
                }
            }
        }

        if (tile != null)
            player.turn_action = new TurnAction.late_kan(tile, pon);
        else
            player.turn_action = new TurnAction.closed_kan(tiles);

        player.state = Player.PlayerState.READY;
        toggle_interface(false);
    }

    private void do_pon()
    {
        Player player = players[player_seat];

        Tile[] tiles = new Tile[2];

        int a = 0;
        foreach (Tile t in player.hand)
        {
            if (t.tile_type == last_played_tile.tile_type)
                tiles[a++] = t;

            if (a == 2)
            {
                player.call_action = new CallAction(CallAction.CallActionEnum.PON, tiles);
                player.state = Player.PlayerState.READY;
            }
        }
    }

    private void do_chi()
    {
        Player player = players[player_seat];

        Tile[]? tiles = Logic.auto_chi(last_played_tile, player.hand);
        if (tiles == null)
        {
            state = GameState.WAITING_CHI;
            return;
        }

        player.call_action = new CallAction(CallAction.CallActionEnum.CHI, tiles);
        player.state = Player.PlayerState.READY;
        toggle_interface(false);
    }

    private enum GameState
    {
        WAITING_CALLS,
        WAITING_TURN,
        WAITING_CLOSED_OR_LATE_KAN,
        WAITING_CHI,
        WAITING_RIICHI_DISCARD,
        FINISHED
    }
}

public enum Direction
{
    LEFT = -1,
    FRONT = 0,
    RIGHT = 1
}
