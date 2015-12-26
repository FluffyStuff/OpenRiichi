using GL;

class OpenGLShader
{
    private string file;
    private ShaderType shader_type;

    public OpenGLShader(string file, ShaderType type)
    {
        this.file = file;
        shader_type = type;
    }

    public bool init()
    {
        uint type;

        switch (shader_type)
        {
        case ShaderType.VERTEX_SHADER:
            type = GL_VERTEX_SHADER;
            break;
        case ShaderType.FRAGMENT_SHADER:
            type = GL_FRAGMENT_SHADER;
            break;
        default:
            return false;
        }

        string[] source = FileLoader.load(file);
        if (source == null || source.length == 0)
        {
            print("OpenGLShader: Could not load shader file! (%s)\n", shader_type.to_string());
            return false;
        }

        handle = glCreateShader(type);

        for (int i = 0; i < source.length; i++)
            source[i] = source[i] + "\n"; // Pendantic due to bug in vala...

        glShaderSource(handle, source.length, source, null);
		glCompileShader(handle);

        int success[1];
        glGetShaderiv(handle, GL_COMPILE_STATUS, success);

        if (success[0] != 1)
        {
            print("OpenGLShader: %s shader compilation failure!\n", shader_type.to_string());

            int log_size[1];
            glGetShaderiv(handle, GL_INFO_LOG_LENGTH, log_size);
            uint8[] error_log = new uint8[log_size[0]];

            int actual_size[1];
            glGetShaderInfoLog(handle, log_size[0], actual_size, error_log);

            for (int i = 0; i < log_size[0]; i++)
                print("%c", (uchar)error_log[i]);

            return false;
        }

        return true;
    }

    public uint handle { get; private set; }

    public enum ShaderType
    {
        VERTEX_SHADER,
        FRAGMENT_SHADER
    }
}
