using Aubio;
using Gee;

public class AubioAnalysis
{
    public AubioAnalysis(string name, int sample_rate, int buffer_size, int hop_size)
    {
        this.name = name;
        this.sample_rate = sample_rate;
        this.buffer_size = buffer_size;
        this.hop_size = hop_size;
    }

    public void analyse()
    {
        Aubio.Source source = new Aubio.Source(name, sample_rate, hop_size);
        FVector ibuf = new FVector(hop_size);
        CVector fftgrain = new CVector(hop_size);
        FFT fft = new FFT(hop_size);

        print("Start reading audio samples.\n");

        float[] list = new float[0];
        uint read = 0;
        uint total_read = 0;

        do
        {
            source.do(ibuf, ref read);
            fft.do(ibuf, fftgrain);

            for (int i = 0; i < read; i++)
            {
                // Can only read lower half due to a bug in libaubio...
                if (i < 256)
                    list += fftgrain.norm_get_sample(i) * (float)Math.cos(fftgrain.phase_get_sample(i));
                else
                    list += 0;
            }

            if (read < buffer_size && read != 0)
                for (int i = (int)read; i < buffer_size; i++)
                    list += 0;

            total_read += read;
        }
        while (read == hop_size);

        samples = list;
        length = total_read;

        print("Finished reading samples.\n");
    }

    public float get_amplitude(double time, int range_position, int sampling_length, int sampling_breadth)
    {
        float sum = 0;

        for (int i = 0; i < sampling_length; i++)
        {
            float val = 0;

            for (int j = 0; j < sampling_breadth; j++)
            {
                int pos = (int)((time * sample_rate / hop_size) - i + 3) * hop_size + range_position * sampling_breadth + j + (sampling_breadth + 1) / 2;
                pos = (int)Math.fmax(pos, 0);
                float sq = samples[pos];
                val += sq*sq;
            }
            val /= sampling_breadth;
            val = (float)Math.sqrt(val);
            sum += val;
        }

        sum /= sampling_length;

        return sum;
    }

    private string name { get; private set; }
    private int sample_rate { get; private set; }
    private int buffer_size { get; private set; }
    private int hop_size { get; private set; }
    private float[] samples { get; private set; }

    public uint length { get; private set; }
}
