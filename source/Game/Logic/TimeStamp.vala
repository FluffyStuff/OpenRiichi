public class TimeStamp : Serializable
{
    public TimeStamp(DateTime timestamp)
    {
        init(timestamp);
    }

    public TimeStamp.now()
    {
        init(new DateTime.now_local());
    }

    private void init(DateTime timestamp)
    {
        year = timestamp.get_year();
        month = timestamp.get_month();
        day = timestamp.get_day_of_month();
        hour = timestamp.get_hour();
        minute = timestamp.get_minute();
        second = (float)timestamp.get_second();
    }

    public TimeSpan minus(TimeStamp other)
    {
        return new TimeSpan(timestamp.difference(other.timestamp));
    }

    public TimeStamp plus_seconds(float seconds)
    {
        return new TimeStamp(timestamp.add_seconds(seconds));
    }

    protected int year { get; protected set; }
    protected int month { get; protected set; }
    protected int day { get; protected set; }
    protected int hour { get; protected set; }
    protected int minute { get; protected set; }
    protected float second { get; protected set; }

    public DateTime timestamp { owned get { return new DateTime.utc(year, month, day, hour, minute, second); } }
}

public class TimeSpan : Serializable
{
    public TimeSpan(GLib.TimeSpan timespan)
    {
        this.timespan = timespan;
    }

    public float seconds { get { return timespan / 1000000.0f; } }
    public int64 microseconds { get { return timespan; } }

    protected GLib.TimeSpan timespan { get; protected set; }
}
