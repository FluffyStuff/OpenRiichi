using SDLMixer;

public class SDLMusicHook
{

    private static int pos = 0;
    private static float[] samples;
    private static float mean = 0;
    private static Chunk chunk;

    public SDLMusicHook(float[] data)
    {
        int ye = open(44100, 0x8010, 2, 1024);
        print(": " + ye.to_string() + "\n");
        samples = data;

        float min = 10000, max = -10000;
        for (int i = 0; i < data.length; i++)
        {
            mean += data[i];
            min = data[i] < min ? data[i] : min;
            max = data[i] > max ? data[i] : max;
        }
        mean /= data.length;

        //Chunk chunk = new Chunk.WAV("Standerwick - Valyrian - test.wav");
        //Music music = new Music("Standerwick - Valyrian - test.wav");
        //music.play(1);

        derp();
        //Music.hook_mixer((void*)myMusicPlayer, (void*)0);
        print("Mean: " + mean.to_string() + "\n");
        print("Min : " + min.to_string() + "\n");
        print("Max : " + max.to_string() + "\n");
    }

    private static void derp()
    {
        chunk = new Chunk.WAV("Standerwick - Valyrian - test.wav");
        Channel.play_channel(DEFAULT_CHANNEL, chunk, 0);
    }

    private static void myMusicPlayer(void *udata, uint8 *stream, int len)
    {
        //print("Len: " + samples.length.to_string() + "\n");
        //print("Pos: " + pos.to_string() + "\n");

        // fill buffer with...uh...music...
        for (int i = 0; i < len; i++)
        {
            int index = (pos+i) / 4;
            //print(": " + samples[index].to_string() + "\n");
            float val = samples[index];// + (samples[index+1] - samples[index+0]) * ((pos+i) % 4) / 4;
            val = val * 64 + 64;
            stream[i] = (uint8)val;//(uint8)(Math.cos((double)(pos+i) / 3) * 128 + 128);//(i + pos)&ff;
        }

        // set udata for next time
        pos += len;
    }
}
