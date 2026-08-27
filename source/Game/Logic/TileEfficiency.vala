using Gee;
using Engine;

/*
 * Tile-efficiency calculations ported from Riichi-Trainer's
 * ShantenCalculator.js, UkeireCalculator.js, and Evaluations.js (GPL-3.0).
 * https://github.com/FluffyStuff/riichi-trainer
 *
 * The 38-slot representation is intentionally retained so the results match
 * Riichi-Trainer: 1-9m, 11-19p, 21-29s, and 31-37z.
 */
public class TileEfficiencyResult : Object
{
    public TileEfficiencyResult(int tile_index, int shanten, int ukeire, ArrayList<int> improving_tiles)
    {
        this.tile_index = tile_index;
        this.shanten = shanten;
        this.ukeire = ukeire;
        this.improving_tiles = improving_tiles;
    }

    public int tile_index { get; private set; }
    public int shanten { get; private set; }
    public int ukeire { get; private set; }
    public ArrayList<int> improving_tiles { get; private set; }
}

internal class UkeireResult : Object
{
    public UkeireResult()
    {
        tiles = new ArrayList<int>();
    }

    public int value { get; set; default = 0; }
    public ArrayList<int> tiles { get; private set; }
}

public class TileEfficiencyCalculator : Object
{
    private int[] work_hand = new int[38];
    private int complete_sets;
    private int pair;
    private int partial_sets;
    private int best_shanten;
    private int minimum_shanten;
    private bool has_given_minimum;

    public ArrayList<TileEfficiencyResult> calculate(int[] concealed_hand, int[] remaining_tiles)
    {
        int[] hand = copy_counts(concealed_hand);
        bool open_hand = count_tiles(hand) < 14;

        // Riichi-Trainer pads each open meld with a completed honor triplet.
        int shanten_offset = ((14 - count_tiles(hand)) / 3) * 2;
        for (int i = 0; i < shanten_offset; i += 2)
            hand[31] += 3;

        int base_shanten = shanten(hand, open_hand);
        ArrayList<TileEfficiencyResult> results = new ArrayList<TileEfficiencyResult>();

        for (int discard = 1; discard < hand.length; discard++)
        {
            if (discard % 10 == 0 || concealed_hand[discard] == 0)
                continue;

            hand[discard]--;
            int resulting_shanten = shanten(hand, open_hand);
            UkeireResult ukeire = calculate_ukeire(hand, remaining_tiles, open_hand, base_shanten);
            hand[discard]++;

            results.add(new TileEfficiencyResult(discard, resulting_shanten, ukeire.value, ukeire.tiles));
        }

        return results;
    }

    private UkeireResult calculate_ukeire(int[] hand, int[] remaining_tiles, bool open_hand, int base_shanten)
    {
        UkeireResult result = new UkeireResult();

        for (int added = 1; added < hand.length; added++)
        {
            if (added % 10 == 0 || remaining_tiles[added] == 0)
                continue;

            hand[added]++;
            if (shanten(hand, open_hand, base_shanten - 1) < base_shanten)
            {
                result.value += remaining_tiles[added];
                result.tiles.add(added);
            }
            hand[added]--;
        }

        return result;
    }

    private int shanten(int[] hand, bool open_hand, int known_minimum = -2)
    {
        if (open_hand)
            return standard_shanten(hand, known_minimum);

        int chiitoitsu = chiitoitsu_shanten(hand);
        if (chiitoitsu < 0)
            return chiitoitsu;

        int kokushi = kokushi_shanten(hand);
        if (kokushi < 3)
            return kokushi;

        return int.min(standard_shanten(hand, known_minimum), int.min(chiitoitsu, kokushi));
    }

    private int chiitoitsu_shanten(int[] hand)
    {
        int pairs = 0;
        int unique = 0;
        for (int i = 1; i < hand.length; i++)
        {
            if (hand[i] == 0)
                continue;
            unique++;
            if (hand[i] >= 2)
                pairs++;
        }

        int result = 6 - pairs;
        if (unique < 7)
            result += 7 - unique;
        return result;
    }

    private int kokushi_shanten(int[] hand)
    {
        int unique = 0;
        int has_pair = 0;
        for (int i = 1; i < hand.length; i++)
        {
            if (i % 10 != 1 && i % 10 != 9 && i <= 30)
                continue;
            if (hand[i] == 0)
                continue;
            unique++;
            if (hand[i] >= 2)
                has_pair = 1;
        }
        return 13 - unique - has_pair;
    }

    private int standard_shanten(int[] hand, int known_minimum = -2)
    {
        work_hand = copy_counts(hand);
        complete_sets = 0;
        pair = 0;
        partial_sets = 0;
        best_shanten = 8;
        has_given_minimum = known_minimum != -2;
        minimum_shanten = has_given_minimum ? known_minimum : -1;

        for (int i = 1; i < work_hand.length; i++)
        {
            if (work_hand[i] < 2)
                continue;
            pair++;
            work_hand[i] -= 2;
            remove_completed_sets(1);
            work_hand[i] += 2;
            pair--;
        }

        remove_completed_sets(1);
        return best_shanten;
    }

    private void remove_completed_sets(int start)
    {
        if (best_shanten <= minimum_shanten)
            return;

        int i = start;
        while (i < work_hand.length && work_hand[i] == 0)
            i++;

        if (i >= work_hand.length)
        {
            remove_potential_sets(1);
            return;
        }

        if (work_hand[i] >= 3)
        {
            complete_sets++;
            work_hand[i] -= 3;
            remove_completed_sets(i);
            work_hand[i] += 3;
            complete_sets--;
        }

        if (i < 30 && work_hand[i + 1] != 0 && work_hand[i + 2] != 0)
        {
            complete_sets++;
            work_hand[i]--;
            work_hand[i + 1]--;
            work_hand[i + 2]--;
            remove_completed_sets(i);
            work_hand[i]++;
            work_hand[i + 1]++;
            work_hand[i + 2]++;
            complete_sets--;
        }

        remove_completed_sets(i + 1);
    }

    private void remove_potential_sets(int start)
    {
        if (best_shanten <= minimum_shanten)
            return;
        if (has_given_minimum && complete_sets < 3 - minimum_shanten)
            return;

        int i = start;
        while (i < work_hand.length && work_hand[i] == 0)
            i++;

        if (i >= work_hand.length)
        {
            int current = 8 - complete_sets * 2 - partial_sets - pair;
            if (current < best_shanten)
                best_shanten = current;
            return;
        }

        if (complete_sets + partial_sets < 4)
        {
            if (work_hand[i] == 2)
            {
                partial_sets++;
                work_hand[i] -= 2;
                remove_potential_sets(i);
                work_hand[i] += 2;
                partial_sets--;
            }

            if (i < 30 && work_hand[i + 1] != 0)
            {
                partial_sets++;
                work_hand[i]--;
                work_hand[i + 1]--;
                remove_potential_sets(i);
                work_hand[i]++;
                work_hand[i + 1]++;
                partial_sets--;
            }

            if (i < 30 && i % 10 <= 8 && work_hand[i + 2] != 0)
            {
                partial_sets++;
                work_hand[i]--;
                work_hand[i + 2]--;
                remove_potential_sets(i);
                work_hand[i]++;
                work_hand[i + 2]++;
                partial_sets--;
            }
        }

        remove_potential_sets(i + 1);
    }

    private static int count_tiles(int[] hand)
    {
        int count = 0;
        foreach (int value in hand)
            count += value;
        return count;
    }

    private static int[] copy_counts(int[] source)
    {
        int[] copy = new int[source.length];
        for (int i = 0; i < source.length; i++)
            copy[i] = source[i];
        return copy;
    }
}

public class EfficiencyLogging : Object
{
    private static ArrayList<TileEfficiencyResult>? last_results;
    private static double[]? last_safety;
    private static double last_best_safety;

    public static bool enabled { get; set; default = false; }
    public static bool singleplayer_session { get; set; default = false; }

    public static string? log_turn(RoundState state)
    {
        if (!enabled || !singleplayer_session || state.self.index != state.current_player.index)
            return null;

        int[] hand = new int[38];
        foreach (Tile tile in state.self.hand)
            hand[to_trainer_index(tile.tile_type)]++;

        int[] remaining = new int[38];
        for (int i = 1; i < remaining.length; i++)
            if (i % 10 != 0)
                remaining[i] = 4;

        foreach (Tile tile in state.get_tiles())
        {
            if (tile.tile_type == TileType.BLANK)
                continue;
            int index = to_trainer_index(tile.tile_type);
            remaining[index] = int.max(0, remaining[index] - 1);
        }

        TileEfficiencyCalculator calculator = new TileEfficiencyCalculator();
        last_results = calculator.calculate(hand, remaining);
        if (last_results.size == 0)
            return null;

        int best_ukeire = 0;
        foreach (TileEfficiencyResult result in last_results)
            best_ukeire = int.max(best_ukeire, result.ukeire);

        StringBuilder message = new StringBuilder();
        StringBuilder overlay = new StringBuilder();
        message.append("Riichi-Trainer tile efficiency\n");
        message.append("Hand: ").append(format_counts(hand)).append("\n");
        overlay.append("TILE EFFICIENCY GUIDE\n");
        overlay.append("S = shanten, U = ukeire\n");
        overlay.append("Hand: ").append(format_counts_overlay(hand)).append("\n");
        foreach (TileEfficiencyResult result in last_results)
        {
            string best = result.ukeire == best_ukeire ? " BEST" : "";
            message.append_printf("Discard %-5s -> shanten %d, ukeire %d [%s]%s\n",
                format_tile(result.tile_index), result.shanten, result.ukeire,
                format_indexes(result.improving_tiles), best);
            overlay.append_printf("%s -> S%d / U%d [%s]%s\n",
                format_tile_overlay(result.tile_index), result.shanten, result.ukeire,
                format_indexes_overlay(result.improving_tiles), best);
        }
        append_defense_analysis(state, hand, remaining, message, overlay);
        Environment.log(LogType.GAME, "TileEfficiency", message.str);
        return overlay.str;
    }

    public static void log_discard(TileType tile_type)
    {
        if (!enabled || !singleplayer_session || last_results == null)
            return;

        int index = to_trainer_index(tile_type);
        int best_ukeire = 0;
        TileEfficiencyResult? chosen = null;
        foreach (TileEfficiencyResult result in last_results)
        {
            best_ukeire = int.max(best_ukeire, result.ukeire);
            if (result.tile_index == index)
                chosen = result;
        }

        if (chosen != null)
        {
            string verdict = chosen.ukeire == best_ukeire ? "optimal" : "suboptimal";
            Environment.log(LogType.GAME, "TileEfficiency",
                "Chosen discard %s: %s (shanten %d, ukeire %d; best ukeire %d)".printf(
                    format_tile(index), verdict, chosen.shanten, chosen.ukeire, best_ukeire));
        }
        if (last_safety != null)
        {
            double rating = last_safety[index];
            string verdict = rating == last_best_safety ? "safest" : "not the safest";
            Environment.log(LogType.GAME, "DefensivePlay",
                "Chosen discard %s: %s (safety %.1f, best %.1f; %s)".printf(
                    format_tile(index), verdict, rating, last_best_safety,
                    safety_explanation((int)Math.floor(rating))));
        }
        last_results = null;
        last_safety = null;
    }

    private static void append_defense_analysis(RoundState state, int[] hand, int[] remaining,
        StringBuilder log_message, StringBuilder window_message)
    {
        int riichi_count = 0;
        double[] safety = new double[38];

        for (int player_index = 0; player_index < 4; player_index++)
        {
            RoundStatePlayer opponent = state.get_player(player_index);
            if (opponent.index == state.self.index || !opponent.in_riichi || opponent.riichi_tile == null)
                continue;

            riichi_count++;
            ArrayList<int> discards = tile_indexes(opponent.pond);
            ArrayList<int> passed_tiles = tile_indexes(opponent.post_riichi_discards);
            int riichi_tile = to_trainer_index(opponent.riichi_tile.tile_type);
            int[] opponent_safety = evaluate_safety(hand, discards, remaining, passed_tiles, riichi_tile);
            for (int i = 1; i < safety.length; i++)
                safety[i] += opponent_safety[i];
        }

        window_message.append("\nDEFENSIVE PLAY\n");
        if (riichi_count == 0)
        {
            window_message.append("No opponent has declared riichi.\n");
            last_safety = null;
            return;
        }

        for (int i = 1; i < safety.length; i++)
            safety[i] /= riichi_count;

        double best = 0;
        for (int i = 1; i < hand.length; i++)
            if (hand[i] > 0)
                best = double.max(best, safety[i]);

        string opponents = riichi_count == 1 ? "opponent" : "opponents";
        window_message.append_printf("Average safety vs %d riichi %s (15 = safest)\n", riichi_count, opponents);
        log_message.append_printf("Defensive safety vs %d riichi %s\n", riichi_count, opponents);

        for (int i = 1; i < hand.length; i++)
        {
            if (hand[i] == 0 || i % 10 == 0)
                continue;
            string best_marker = safety[i] == best ? " SAFEST" : "";
            string explanation = safety_explanation((int)Math.floor(safety[i]));
            window_message.append_printf("%s -> %.1f (%s)%s\n",
                format_tile_overlay(i), safety[i], explanation, best_marker);
            log_message.append_printf("Discard %-5s -> safety %.1f (%s)%s\n",
                format_tile(i), safety[i], explanation, best_marker);
        }

        last_safety = safety;
        last_best_safety = best;
    }

    private static int[] evaluate_safety(int[] hand, ArrayList<int> opponent_discards, int[] remaining,
        ArrayList<int> passed_tiles, int riichi_tile)
    {
        int[] ratings = new int[38];

        for (int i = 1; i < hand.length; i++)
        {
            if (hand[i] <= 0 || i % 10 == 0)
                continue;

            if (opponent_discards.contains(i) || passed_tiles.contains(i))
            {
                ratings[i] = 15;
                continue;
            }

            if (i < 30 && (i % 10 == 1 || i % 10 == 9))
            {
                ratings[i] = is_suji(i, opponent_discards, remaining, riichi_tile) ? 14 - remaining[i] : 5;
                continue;
            }

            if (i > 30)
            {
                switch (remaining[i])
                {
                case 0: ratings[i] = 14; break;
                case 1: ratings[i] = 13; break;
                case 2: ratings[i] = 10; break;
                default: ratings[i] = 6; break;
                }
                continue;
            }

            bool suji = is_suji(i, opponent_discards, remaining, riichi_tile);
            switch (i % 10)
            {
            case 4:
            case 5:
            case 6:
                ratings[i] = suji ? 9 : 1;
                break;
            case 2:
            case 8:
                ratings[i] = suji ? 8 : 3;
                break;
            default:
                ratings[i] = suji ? 7 : 2;
                break;
            }
        }

        return ratings;
    }

    private static bool is_suji(int tile, ArrayList<int> discards, int[] remaining, int riichi_tile)
    {
        int suit_start = (tile / 10) * 10;
        int lower = tile - 3;
        int upper = tile + 3;
        bool lower_passed = lower < suit_start + 1;
        bool upper_passed = upper > suit_start + 9;

        if (!lower_passed)
        {
            if (lower == riichi_tile)
                return false;
            lower_passed = discards.contains(lower) || remaining[lower + 1] == 0 || remaining[lower + 2] == 0;
        }

        if (!upper_passed)
        {
            if (upper == riichi_tile)
                return false;
            upper_passed = discards.contains(upper) || remaining[upper - 1] == 0 || remaining[upper - 2] == 0;
        }

        return lower_passed && upper_passed;
    }

    private static ArrayList<int> tile_indexes(ArrayList<Tile> tiles)
    {
        ArrayList<int> indexes = new ArrayList<int>();
        foreach (Tile tile in tiles)
            indexes.add(to_trainer_index(tile.tile_type));
        return indexes;
    }

    private static string safety_explanation(int rating)
    {
        switch (rating)
        {
        case 1: return "non-suji 4/5/6";
        case 2: return "non-suji 3/7";
        case 3: return "non-suji 2/8";
        case 4: return "one-chance";
        case 5: return "non-suji terminal";
        case 6: return "first honor";
        case 7: return "suji 3/7";
        case 8: return "suji 2/8";
        case 9: return "suji 4/5/6";
        case 10: return "second honor";
        case 11: return "first suji terminal";
        case 12: return "second suji terminal";
        case 13: return "third terminal / honor";
        case 14: return "fourth terminal / honor";
        case 15: return "genbutsu";
        default: return "unknown";
        }
    }

    private static int to_trainer_index(TileType type)
    {
        int value = (int)type;
        if (value <= 9)
            return value;
        if (value <= 18)
            return value + 1;
        if (value <= 27)
            return value + 2;
        return value + 3;
    }

    private static string format_tile(int index)
    {
        if (index < 10)
            return "%dm".printf(index);
        if (index < 20)
            return "%dp".printf(index - 10);
        if (index < 30)
            return "%ds".printf(index - 20);
        return "%dz".printf(index - 30);
    }

    private static string format_tile_overlay(int index)
    {
        return "%s %s".printf(tile_emoji(index), format_tile(index));
    }

    private static string tile_emoji(int index)
    {
        string[] manzu = { "🀇", "🀈", "🀉", "🀊", "🀋", "🀌", "🀍", "🀎", "🀏" };
        string[] pinzu = { "🀙", "🀚", "🀛", "🀜", "🀝", "🀞", "🀟", "🀠", "🀡" };
        string[] souzu = { "🀐", "🀑", "🀒", "🀓", "🀔", "🀕", "🀖", "🀗", "🀘" };
        // MPSZ honor order: east, south, west, north, white, green, red.
        string[] honors = { "🀀", "🀁", "🀂", "🀃", "🀆", "🀅", "🀄" };

        if (index >= 1 && index <= 9)
            return manzu[index - 1];
        if (index >= 11 && index <= 19)
            return pinzu[index - 11];
        if (index >= 21 && index <= 29)
            return souzu[index - 21];
        if (index >= 31 && index <= 37)
            return honors[index - 31];
        return "?";
    }

    private static string format_indexes(ArrayList<int> indexes)
    {
        if (indexes.size == 0)
            return "none";
        StringBuilder text = new StringBuilder();
        foreach (int index in indexes)
        {
            if (text.len > 0)
                text.append(" ");
            text.append(format_tile(index));
        }
        return text.str;
    }

    private static string format_indexes_overlay(ArrayList<int> indexes)
    {
        if (indexes.size == 0)
            return "-";

        StringBuilder text = new StringBuilder();
        foreach (int index in indexes)
        {
            if (text.len > 0)
                text.append(" ");
            text.append(format_tile_overlay(index));
        }
        return text.str;
    }

    private static string format_counts_overlay(int[] counts)
    {
        StringBuilder text = new StringBuilder();
        for (int i = 1; i < counts.length; i++)
        {
            if (i % 10 == 0)
                continue;
            for (int count = 0; count < counts[i]; count++)
            {
                if (text.len > 0)
                    text.append(" ");
                text.append(format_tile_overlay(i));
            }
        }
        return text.str;
    }

    private static string format_counts(int[] counts)
    {
        StringBuilder text = new StringBuilder();
        for (int suit = 0; suit < 4; suit++)
        {
            StringBuilder values = new StringBuilder();
            int start = suit < 3 ? suit * 10 + 1 : 31;
            int end = suit < 3 ? start + 9 : 38;
            for (int i = start; i < end; i++)
                for (int count = 0; count < counts[i]; count++)
                    values.append_printf("%d", i % 10);
            if (values.len > 0)
            {
                text.append(values.str);
                text.append(suit == 0 ? "m" : suit == 1 ? "p" : suit == 2 ? "s" : "z");
            }
        }
        return text.str;
    }
}
