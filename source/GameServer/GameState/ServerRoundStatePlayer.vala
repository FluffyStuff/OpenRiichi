using Gee;

namespace GameServer
{
    class ServerRoundStatePlayer
    {
        public ServerRoundStatePlayer(RoundStatePlayer player)
        {
            this.player = player;
            call_decision = null;
            state = PlayerState.DONE;
        }

        public ArrayList<Tile>? get_open_kan_tiles(Tile tile)
        {
            ArrayList<Tile> kan = new ArrayList<Tile>();

            foreach (Tile t in hand)
                if (t.tile_type == tile.tile_type)
                {
                    kan.add(t);
                    if (kan.size == 3)
                        return kan;
                }

            return null;
        }

        public ArrayList<Tile>? get_pon_tiles(Tile tile)
        {
            ArrayList<Tile> pon = new ArrayList<Tile>();

            foreach (Tile t in hand)
                if (t.tile_type == tile.tile_type)
                {
                    pon.add(t);
                    if (pon.size == 2)
                        return pon;
                }

            return null;
        }

        public RoundStateCallDecision? call_decision { get; set; }
        public PlayerState state { get; set; }
        public RoundStatePlayer player { get; private set; }
        public int index { get { return player.index; } }
        public bool in_riichi { get { return player.in_riichi; } }
        public Tile newest_tile { owned get { return player.newest_tile; } }
        public Tile default_discard_tile { owned get { return player.get_default_discard_tile(); } }
        public ArrayList<Tile> hand { get { return player.hand; } }
        public bool open { get { return player.open; } }
        public bool disconnected { get; set; }
    }

    public enum PlayerState
    {
        DONE,
        WAITING_CALL,
        WAITING_RIICHI_DISCARD
    }

    class RoundStateCallDecision
    {
        public RoundStateCallDecision(CallDecisionType type, ArrayList<Tile>? tiles)
        {
            call_type = type;
            this.tiles = tiles;
        }

        public CallDecisionType call_type { get; private set; }
        public ArrayList<Tile>? tiles { get; private set; }
    }

    public enum CallDecisionType
    {
        RON,
        KAN,
        PON,
        CHII
    }
}
