public class DelayTimer
{
    private bool time_set;
    private bool is_active = false;
    private float time;
    private float _delay;

    public bool active(float time)
    {
        if (!is_active)
            return false;

        if (!time_set)
        {
            this.time = time + delay;
            time_set = true;
        }

        if (time >= this.time)
        {
            is_active = false;
            return true;
        }

        return false;
    }

    public void set_time(float delay)
    {
        _delay = delay;
        time_set = false;
        is_active = true;
    }

    public float delay
    {
        get { return _delay; }
        set
        {
            set_time(delay);
        }
    }
}
