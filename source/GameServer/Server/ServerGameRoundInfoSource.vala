namespace GameServer
{
    public abstract class ServerGameRoundInfoSource
    {
        public abstract ServerGameRoundInfoSourceRound get_round();
    }

    public class DefaultServerGameRoundInfoSource : ServerGameRoundInfoSource
    {
        private Random rnd;

        public DefaultServerGameRoundInfoSource(Random rnd)
        {
            this.rnd = rnd;
        }

        public override ServerGameRoundInfoSourceRound get_round()
        {
            int wall_index = rnd.int_range(1, 7) + rnd.int_range(1, 7); // Emulate dual die roll probability
            return new ServerGameRoundInfoSourceRound(new RoundStartInfo(wall_index), null);
        }
    }

    public class ServerGameRoundInfoSourceRound
    {
        public ServerGameRoundInfoSourceRound(RoundStartInfo info, Tile[]? tiles)
        {
            this.info = info;
            this.tiles = tiles;
        }

        public RoundStartInfo info { get; private set; }
        public Tile[]? tiles { get; private set; }
    }
}
