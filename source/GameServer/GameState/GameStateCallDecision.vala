namespace GameServer
{
    class GameStateCallDecision
    {
        private CallDecision _decision_type;
        public GameStateTile _tile;

        public CallDecision DecisionType { get { return _decision_type; } }

        public GameStateTile Tile { get { return _tile; } }

        public enum CallDecision
        {
            RON,
            NONE
        }
    }
}
