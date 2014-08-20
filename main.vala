extern void exit(int exit_code);

public static int main(string[] args)
{
    /*var list = new Gee.ArrayList<Tile>();
    int man = -1, pin = 8, sou = 17, higashi = 27, minami = 28, nishi = 29, kita = 30, haku = 31, hatsu = 32, chun = 33;

    int[] tiles = new int[]
    {
        man + 3,
        man + 3,
        sou + 3,
        sou + 5
    };

    foreach (int i in tiles)
        list.add(new Tile(0, 0, i));

    Tile tile = new Tile(0, 0, sou + 4);

    if (Logic.can_win_with(list, tile))
        stdout.printf("Winning hand!\n");
    else
        stdout.printf("NO winning hand!\n");

    Gee.ArrayList<Tile> tenpais = Logic.can_tenpai(list);
    if (tenpais.size != 0)
        foreach (Tile t in tenpais)
            stdout.printf("Tenpai without: " + t.name + "!\n");
    else
        stdout.printf("NO tenpai hand!\n");

    return 0;*/

    if (!Environment.init())
        exit(-1);

    while (true)
    {
        Mahjong m = new Mahjong();
        m.init(Environment.window);
        if (!m.loop())
            break;
    }

    return 0;
}
