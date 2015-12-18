using SFML.System;

[CCode (cprefix = "sf", cheader_filename = "SFML/Audio.h")]
namespace SFML.Audio {
	/*
	 * Listener
	 */
	
	[Compact]
	public class Listener {
		[CCode (cname = "sfListener_setGlobalVolume")]
		public static void set_global_volume (float volume);
		
		[CCode (cname = "sfListener_getGlobalVolume")]
		public static float get_global_volume ();
		
		[CCode (cname = "sfListener_setPosition")]
		public static void set_position (Vector3f position);
		
		[CCode (cname = "sfListener_getPosition")]
		public static Vector3f get_position ();
		
		[CCode (cname = "sfListener_setDirection")]
		private static void set_direction (Vector3f orientation);
		
		[CCode (cname = "sfListener_getDirection")]
		public static Vector3f get_direction ();
	}
	
	
	
	
	/*
	 * Sound status
	 */
	
	public enum SoundStatus {
		[CCode (cname = "sfStopped")]
		STOPPED,
		[CCode (cname = "sfPaused")]
		PAUSED,
		[CCode (cname = "sfPlaying")]
		PLAYING
	}
	
	
	
	
	
	/*
	 * Music
	 */
	
	[CCode (cname = "sfMusic", free_function = "sfMusic_destroy")]
	[Compact]
	public class Music : Sound {
		[CCode (cname = "sfMusic_createFromFile")]
		public Music (string filename);
		
		[CCode (cname = "sfMusic_createFromMemory")]
		public Music.from_memory (void* data, size_t sizeInBytes);
		
		[CCode (cname = "sfMusic_createFromStream")]
		public Music.from_stream (InputStream stream);
		
		[CCode (cname = "sfMusic_setLoop")]
		public void set_loop (bool loop);
		
		[CCode (cname = "sfMusic_getLoop")]
		public bool get_loop ();
		
		[CCode (cname = "sfMusic_getDuration")]
		public SFML.System.Time get_duration ();
		
		[CCode (cname = "sfMusic_play")]
		public void play ();
		
		[CCode (cname = "sfMusic_pause")]
		public void pause ();
		
		[CCode (cname = "sfMusic_stop")]
		public void stop ();
		
		[CCode (cname = "sfMusic_getChannelsCount")]
		public uint get_channels_count ();
		
		[CCode (cname = "sfMusic_getSampleRate")]
		public uint get_sample_rate ();
		
		[CCode (cname = "sfMusic_getStatus")]
		public SoundStatus get_status ();
		
		[CCode (cname = "sfMusic_getPlayingOffset")]
		public SFML.System.Time get_playing_offset ();
		
		[CCode (cname = "sfMusic_setPitch")]
		public void set_pitch (float pitch);
		
		[CCode (cname = "sfMusic_setVolume")]
		public void set_volume (float volume);
		
		[CCode (cname = "sfMusic_setPosition")]
		public void set_position (Vector3f position);
		
		[CCode (cname = "sfMusic_setRelativeToListener")]
		public void set_relative_to_listener (bool relative);
		
		[CCode (cname = "sfMusic_setMinDistance")]
		public void set_min_distance (float distance);
		
		[CCode (cname = "sfMusic_setAttenuation")]
		public void set_attenuation (float attenuation);
		
		[CCode (cname = "sfMusic_setPlayingOffset")]
		public void set_playing_offset (SFML.System.Time time);
		
		[CCode (cname = "sfMusic_getPitch")]
		public float get_pitch ();
		
		[CCode (cname = "sfMusic_getVolume")]
		public float get_volume ();
		
		[CCode (cname = "sfMusic_getPosition")]
		public Vector3f get_position ();
		
		[CCode (cname = "sfMusic_isRelativeToListener")]
		public bool is_relative_to_listener ();
		
		[CCode (cname = "sfMusic_getMinDistance")]
		public float get_min_distance ();
		
		[CCode (cname = "sfMusic_getAttenuation")]
		public float get_attenuation ();
	}
	
	
	
	
	/*
	 * Sound
	 */
	
	[CCode (cname = "sfSound", copy_function = "sfSound_copy", free_function = "sfSound_destroy")]
	[Compact]
	public class Sound {
		[CCode (cname = "sfSound_create")]
		public Sound ();
		
		[CCode (cname = "sfSound_play")]
		public void play ();
		
		[CCode (cname = "sfSound_pause")]
		public void pause ();
		
		[CCode (cname = "sfSound_stop")]
		public void stop ();
		
		[CCode (cname = "sfSound_setBuffer")]
		public void set_buffer (SoundBuffer buffer);
		
		[CCode (cname = "sfSound_getBuffer")]
		public SoundBuffer get_buffer ();
		
		[CCode (cname = "sfSound_setLoop")]
		public void set_loop (bool loop);
		
		[CCode (cname = "sfSound_getLoop")]
		public bool get_loop ();
		
		[CCode (cname = "sfSound_getStatus")]
		public SoundStatus get_status ();
		
		[CCode (cname = "sfSound_setPitch")]
		public void set_pitch (float pitch);
		
		[CCode (cname = "sfSound_setVolume")]
		public void set_volume (float volume);
		
		[CCode (cname = "sfSound_setPosition")]
		public void set_position (Vector3f position);
		
		[CCode (cname = "sfSound_setRelativeToListener")]
		public void set_relative_to_listener (bool relative);
		
		[CCode (cname = "sfSound_setMinDistance")]
		public void set_min_distance (float distance);
		
		[CCode (cname = "sfSound_setAttenuation")]
		public void set_attenuation (float attenuation);
		
		[CCode (cname = "sfSound_setPlayingOffset")]
		public void set_playing_offset (SFML.System.Time time);
		
		[CCode (cname = "sfSound_getPitch")]
		public float get_pitch ();
		
		[CCode (cname = "sfSound_getVolume")]
		public float get_volume ();
		
		[CCode (cname = "sfSound_getPosition")]
		public Vector3f get_position ();
		
		[CCode (cname = "sfSound_isRelativeToListener")]
		public bool is_relative_to_listener ();
		
		[CCode (cname = "sfSound_getMinDistance")]
		public float get_min_distance ();
		
		[CCode (cname = "sfSound_getAttenuation")]
		public float get_attenuation ();
		
		[CCode (cname = "sfSound_getPlayingOffset")]
		public SFML.System.Time get_playing_offset ();
	}
	
	
	
	
	/*
	 * Sound buffer
	 */
	
	[CCode (cname = "sfSoundBuffer", copy_function = "sfSoundBuffer_copy", free_function = "sfSoundBuffer_destroy")]
	[Compact]
	public class SoundBuffer {
		[CCode (cname = "sfSoundBuffer_createFromFile")]
		public SoundBuffer (string filename);
		
		[CCode (cname = "sfSoundBuffer_createFromMemory")]
		public SoundBuffer.from_memory (void* data, size_t sizeInBytes);
		
		[CCode (cname = "sfSoundBuffer_createFromStream")]
		public SoundBuffer.from_stream (InputStream stream);
		
		[CCode (cname = "sfSoundBuffer_saveToFile")]
		public bool save_to_file (string filename);
		
		[CCode (cname = "sfSoundBuffer_getSamples")]
		public int16* get_samples ();
		
		[CCode (cname = "sfSoundBuffer_getSamplesCount")]
		public size_t get_samples_count ();
		
		[CCode (cname = "sfSoundBuffer_getSampleRate")]
		public uint get_sample_rate ();
		
		[CCode (cname = "sfSoundBuffer_getChannelsCount")]
		public uint get_channels_count ();
		
		[CCode (cname = "sfSoundBuffer_getDuration")]
		public float get_duration ();
	}
	
	
	
	
	/*
	 * Sound buffer recorder
	 */
	
	[CCode (cname = "sfSoundBufferRecorder", free_function = "sfSoundBufferRecorder_destroy")]
	[Compact]
	public class SoundBufferRecorder {
		[CCode (cname = "sfSoundBufferRecorder_create")]
		public SoundBufferRecorder ();
		
		[CCode (cname = "sfSoundBufferRecorder_start")]
		public void start (uint sample_rate);
		
		[Ccode (cname = "sfSoundBufferRecorder_stop")]
		public void stop ();
		
		[CCode (cname = "sfSoundBufferRecorder_getSampleRate")]
		public uint get_sample_rate ();
		
		[CCode (cname = "sfSoundBufferRecorder_getBuffer")]
		public SoundBuffer get_buffer ();
	}
	
	
	
	
	/*
	 * SoundRecorder
	 */
	
	public delegate bool StartCallback (void* arg0);
	public delegate bool ProcessCallback (out int16* arg0, size_t arg1, void* arg2);
	public delegate void StopCallback (void* arg0);
	
	[CCode (cname = "sfSoundRecorder", free_function = "sfSoundRecorder_destroy")]
	[Compact]
	public class SoundRecorder {
		[CCode (cname = "sfSoundRecorder_create")]
		public SoundRecorder (StartCallback on_start,
						ProcessCallback on_process,
						StopCallback on_stop,
						void* user_data);
		
		[CCode (cname = "sfSoundRecorder_start")]
		public void start (uint sample_rate);
		
		[Ccode (cname = "sfSoundRecorder_stop")]
		public void stop ();
		
		[CCode (cname = "sfSoundRecorder_getSampleRate")]
		public uint get_sample_rate ();
		
		[CCode (cname = "sfSoundRecorder_isAvailable")]
		public bool is_available ();
	}
	
	
	
	
	/*
	 * SoundStream
	 */
	
	[SimpleType]
	public struct SoundStreamChunk {
		[CCode (cname = "samples")]
		int16* samples;
		
		[CCode (cname = "sampleCount")]
		uint sample_count;
	}
	
	public delegate bool GetDataCallback (out SoundStreamChunk arg0, SoundStream arg1);
	public delegate void SeekCallback (SFML.System.Time arg0, SoundStream arg1);
	
	[CCode (cname = "sfSoundStream", free_function = "sfSoundStream_destroy")]
	[Compact]
	public class SoundStream {
		[CCode (cname = "sfSoundStream_create")]
		public SoundStream (GetDataCallback on_get_data,
					SeekCallback on_seek,
					uint channel_count,
					uint sample_rate,
					void* user_data);
		
		[CCode (cname = "sfSoundStream_play")]
		public void play ();
		
		[CCode (cname = "sfSoundStream_pause")]
		public void pause ();
		
		[CCode (cname = "sfSoundStream_stop")]
		public void stop ();
		
		[CCode (cname = "sfSoundStream_getStatus")]
		public SoundStatus get_status ();
		
		[CCode (cname = "sfSoundStream_getSampleRate")]
		public uint get_sample_rate ();
		
		[CCode (cname = "sfSoundStream_getChannelsCount")]
		public uint get_channels_count ();
		
		[CCode (cname = "sfSoundStream_setPitch")]
		public void set_pitch (float pitch);
		
		[CCode (cname = "sfSoundStream_setVolume")]
		public void set_volume (float volume);
		
		[CCode (cname = "sfSoundStream_setPosition")]
		public void set_position (Vector3f position);
		
		[CCode (cname = "sfSoundStream_setRelativeToListener")]
		public void set_relative_to_listener (bool relative);
		
		[CCode (cname = "sfSoundStream_setMinDistance")]
		public void set_min_distance (float distance);
		
		[CCode (cname = "sfSoundStream_setAttenuation")]
		public void set_attenuation (float attenuation);
		
		[CCode (cname = "sfSoundStream_setPlayingOffset")]
		public void set_playing_offset (SFML.System.Time time);
		
		[CCode (cname = "sfSoundStream_getPitch")]
		public float get_pitch ();
		
		[CCode (cname = "sfSoundStream_getVolume")]
		public float get_volume ();
		
		[CCode (cname = "sfSoundStream_getPosition")]
		public Vector3f get_position ();
		
		[CCode (cname = "sfSoundStream_isRelativeToListener")]
		public bool is_relative_to_listener ();
		
		[CCode (cname = "sfSoundStream_getMinDistance")]
		public float get_min_distance ();
		
		[CCode (cname = "sfSoundStream_getAttenuation")]
		public float get_attenuation ();
		
		[CCode (cname = "sfSoundStream_setLoop")]
		public void set_loop (bool loop);
		
		[CCode (cname = "sfSoundStream_getPlayingOffset")]
		public SFML.System.Time get_playing_offset ();
	}
}
