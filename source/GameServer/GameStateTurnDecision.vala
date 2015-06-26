namespace GameServer
{
    class GameStateTurnDecision
    {
        private TurnDecision _decision_type;
        private GameStateTile _tile;

        public GameStateTurnDecision()
        {

        }

        public TurnDecision DecisionType
        {
            get { return _decision_type; }
        }

        public GameStateTile Tile { get { return _tile; } }

        public enum TurnDecision
        {
            TSUMO,
            DISCARD
        }
    }
}
