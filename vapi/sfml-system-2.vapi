
[CCode (cprefix = "sf", cheader_filename = "SFML/System.h")]
namespace SFML.System {
	/*
	 * Time -- TODO Merge struct and class
	 */
	
	[CCode (cname = "sfTime")]
	[SimpleType]
	public struct Time {
		[CCode (cname = "microseconds")]
		public int64 microseconds;
	}
	
	public class SFTime {
		[CCode (cname = "sfTime_asSeconds")]
		public static float as_seconds (Time time);
		
		[CCode (cname = "sfTime_asMilliseconds")]
		public static int32 as_milliseconds (Time time);
		
		[CCode (cname = "sfTime_asMicroseconds")]
		public static int64 as_microseconds (Time time);
		
		[CCode (cname = "sfSeconds")]
		public static Time from_seconds (float amount);
		
		[CCode (cname = "sfMilliseconds")]
		public static Time from_milliseconds (int32 amount);
		
		[CCode (cname = "sfMicroseconds")]
		public static Time from_microseconds (int64 amount);
	}
	
	[CCode (cname = "sfTime_Zero")]
	public Time _time_zero;
	
	
	
	
	/*
	 * Clock
	 */
	
	[CCode (cname = "sfClock", copy_function = "sfClock_copy", free_function = "sfClock_destroy")]
	[Compact]
	public class Clock {
		[CCode (cname = "sfClock_create")]
		public Clock ();
		
		[CCode (cname = "sfClock_getElapsedTime")]
		public Time get_elapsed_time ();
		
		[CCode (cname = "sfClock_restart")]
		public Time restart ();
	}
	
	
	
	
	/*
	 * Input Stream
	 */
	
	[CCode (cname = "sfInputStreamReadFunc")]
	public delegate int64 ReadDeleg (void* data, int64 size, void* userData);
	
	[CCode (cname = "sfInputStreamSeekFunc")]
	public delegate int64 SeekDeleg (int64 position, void* userData);
	
	[CCode (cname = "sfInputStreamTellFunc")]
	public delegate int64 TellDeleg (void* userData);
	
	[CCode (cname = "sfInputStreamGetSizeFunc")]
	public delegate int64 GetSizeDeleg (void* userData);
	
	[CCode (cname = "sfInputStream")]
	[SimpleType]
	public struct InputStream {
		[CCode (cname = "read")]
		public ReadDeleg read;
		
		[CCode (cname = "seek")]
		public SeekDeleg seek;
		
		[CCode (cname = "tell")]
		public TellDeleg tell;
		
		[CCode (cname = "userData")]
		public void* userData;
	}
	
	
	
	
	/*
	 * Mutex
	 */
	
	[CCode (cname = "sfMutex", copy_function = "sfMutex_copy", free_function = "sfMutex_destroy")]
	[Compact]
	public class Mutex {
		[CCode (cname = "sfMutex_create")]
		public Mutex ();
		
		[CCode (cname = "sfMutex_lock")]
		public void lock ();
		
		[CCode (cname = "sfMutex_unlock")]
		public void unlock ();
	}
	
	
	
	
	/*
	 * Thread
	 */
	
	/* DISABLED & NOTWORKING - Use GLib.Thread
	public delegate void ThreadDeleg (void* arg);
	
	[CCode (cname = "sfThread", copy_function = "sfThread_copy", free_function = "sfThread_destroy")]
	[Compact]
	public class Thread {		
		[CCode (cname = "sfThread_create")]
		public Thread (ThreadDeleg deleg, void* userData);
		
		[CCode (cname = "sfThread_launch")]
		public void launch ();
		
		[CCode (cname = "sfThread_waits")]
		public void waits ();
		
		[CCode (cname = "sfThread_terminate")]
		public void terminate ();
	}
	*/
	
	
	
	
	/*
	 * Sleep
	 */
	 
	/* Should use Thread.usleep */
	[CCode (cname = "sfSleep")]
	public void sleep (Time duration);
	
	
	
	
	/*
	 * Vector2
	 */
	
	[CCode (cname = "sfVector2i")]
	[SimpleType]
	public struct Vector2i {
		[CCode (cname = "x")]
		public int x;
		[CCode (cname = "y")]
		public int y;
	}
	
	[CCode (cname = "sfVector2u")]
	[SimpleType]
	public struct Vector2u {
		[CCode (cname = "x")]
		public uint x;
		[CCode (cname = "y")]
		public uint y;
	}
	
	[CCode (cname = "sfVector2f")]
	[SimpleType]
	public struct Vector2f {
		[CCode (cname = "x")]
		public float x;
		[CCode (cname = "y")]
		public float y;
		public Vector2f add (Vector2f vector)
		{
			return {this.x + vector.x, this.y + vector.y};
		}
		public Vector2f multiply(float scalar)
		{
			return {this.x * scalar, this.y * scalar};
		}
	}
	
	
	
	
	/*
	 * Vector3
	 */
	 
	[CCode (cname = "sfVector3f")]
	[SimpleType]
	public struct Vector3f {
		[CCode (cname = "x")]
		public float x;
		[CCode (cname = "y")]
		public float y;
		[CCode (cname = "z")]
		public float z;
	}
}
