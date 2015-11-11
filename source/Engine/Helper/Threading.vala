public /*static*/ class Threading
{
    public delegate void Del0Arg();
    public delegate void Del1Arg(Object arg1);
    public delegate void Del2Arg(Object arg1, Object arg2);
    public delegate void Del3Arg(Object arg1, Object arg2, Object arg3);

    private static void start_thread(Thread thread)
    {
#if LINUX
        try
        {
            new GLib.Thread<int>.try(null, thread.start);
            //GLib.Thread.create<int>(thread.start, false);
        }
        catch (ThreadError e)
        {
            // TODO: Error handling?
        }
#else
        new GLib.Thread<Object?>(null, thread.start);
#endif
    }

    public static void start0(Del0Arg function)
    {
        start_thread(new Thread0(function));
    }

    public static void start1(Del1Arg function, Object arg1)
    {
        start_thread(new Thread1(function, arg1));
    }

    public static void start2(Del2Arg function, Object arg1, Object arg2)
    {
        start_thread(new Thread2(function, arg1, arg2));
    }

    public static void start3(Del3Arg function, Object arg1, Object arg2, Object arg3)
    {
        start_thread(new Thread3(function, arg1, arg2, arg3));
    }

    private abstract class Thread
    {
#if LINUX
        public abstract int start();
#else
        public abstract Object? start();
#endif
    }

    private class Thread0 : Thread
    {
        private Thread? self;
        private Threading.Del0Arg func;

        public Thread0(Del0Arg func)
        {
            self = this;
            this.func = func;
        }

#if LINUX
        public override int start()
        {
            func();
            self = null;
            return 0;
        }
#else
        public override Object? start()
        {
            func();
            self = null;
            return null;
        }
#endif
    }

    private class Thread1 : Thread
    {
        private Thread? self;
        private Threading.Del1Arg func;
        private Object arg1;

        public Thread1(Del1Arg func, Object arg1)
        {
            self = this;
            this.func = func;
            this.arg1 = arg1;
        }

#if LINUX
        public override int start()
        {
            func(arg1);
            self = null;
            return 0;
        }
#else
        public override Object? start()
        {
            func(arg1);
            self = null;
            return null;
        }
#endif
    }

    private class Thread2 : Thread
    {
        private Thread? self;
        private Threading.Del2Arg func;
        private Object arg1;
        private Object arg2;

        public Thread2(Del2Arg func, Object arg1, Object arg2)
        {
            self = this;
            this.func = func;
            this.arg1 = arg1;
            this.arg2 = arg2;
        }

#if LINUX
        public override int start()
        {
            func(arg1, arg2);
            self = null;
            return 0;
        }
#else
        public override Object? start()
        {
            func(arg1, arg2);
            self = null;
            return null;
        }
#endif
    }

    private class Thread3 : Thread
    {
        private Thread? self;
        private Threading.Del3Arg func;
        private Object arg1;
        private Object arg2;
        private Object arg3;

        public Thread3(Del3Arg func, Object arg1, Object arg2, Object arg3)
        {
            self = this;
            this.func = func;
            this.arg1 = arg1;
            this.arg2 = arg2;
            this.arg3 = arg3;
        }

#if LINUX
        public override int start()
        {
            func(arg1, arg2, arg3);
            self = null;
            return 0;
        }
#else
        public override Object? start()
        {
            func(arg1, arg2, arg3);
            self = null;
            return null;
        }
#endif
    }

    public static bool threading { get { return GLib.Thread.supported(); } }
}

// A class for storing primitives/structs as objects
public class Obj<T> : Serializable
{
    //Can't create property due to a bug in vala
    public T obj;
    public Obj(T t) { obj = (T)t; }
}
