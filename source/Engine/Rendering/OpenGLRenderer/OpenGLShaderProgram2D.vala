using GL;

class OpenGLShaderProgram2D
{
    private uint program;
    private OpenGLShader vertex_shader;
    private OpenGLShader fragment_shader;

    private uint vertice_handle;
    private uint array_handle;

    private int vert_position_attribute;
    private int model_transform_attrib = -1;
    private int alpha_attrib = -1;
    private int use_texture_attrib = -1;
    private int diffuse_color_attrib = -1;

    public OpenGLShaderProgram2D(string name)
    {
        vert_position_attribute = 0;

        vertex_shader = new OpenGLShader(name + ".vert", OpenGLShader.ShaderType.VERTEX_SHADER);
        fragment_shader = new OpenGLShader(name + ".frag", OpenGLShader.ShaderType.FRAGMENT_SHADER);
    }

    public bool init()
    {
        if (!vertex_shader.init())
            return false;
        if (!fragment_shader.init())
            return false;

        program = glCreateProgram();

        glAttachShader(program, vertex_shader.handle);
        glAttachShader(program, fragment_shader.handle);

		//pp_texture_location = glGetUniformLocation(post_processing_shader_program, "textures");
		//bloom_attrib = glGetUniformLocation(post_processing_shader_program,"bloom");
		//vertical_attrib = glGetUniformLocation(post_processing_shader_program,"vertical");

        glBindFragDataLocation(program, 0, "out_color");
        glBindAttribLocation(program, vert_position_attribute, "position");

        glLinkProgram(program);

        float[] vertices =
        {
            -1, -1,
             1, -1,
            -1,  1,
             1,  1
        };

        uint vert[1];
        glGenBuffers(1, vert);
        vertice_handle = vert[0];

        glBindBuffer(GL_ARRAY_BUFFER, vertice_handle);
        glBufferData(GL_ARRAY_BUFFER, 8 * sizeof(float), (GLvoid[])vertices, GL_STATIC_DRAW);

        uint vao[1];
        glGenVertexArrays (1, vao);
        array_handle = vao[0];

        glBindVertexArray(array_handle);
        glEnableVertexAttribArray(vert_position_attribute);
        glBindBuffer(GL_ARRAY_BUFFER, vertice_handle);
        glVertexAttribPointer(vert_position_attribute, 2, GL_FLOAT, false, 0, (GLvoid[])0);

        model_transform_attrib = glGetUniformLocation(program, "model_transform");
        alpha_attrib = glGetUniformLocation(program, "alpha");
        use_texture_attrib = glGetUniformLocation(program, "use_texture");
        diffuse_color_attrib = glGetUniformLocation(program, "diffuse_color");

        if (glGetError() != 0)
        {
            print("GL shader program linkage failure!\n");
            return false;
        }

        return true;
    }

    public void apply_scene()
    {
        glUseProgram(program);
        glBindVertexArray(array_handle);
    }

    public void render_object(Mat3 model_transform, float alpha, Vec3 diffuse_color, bool use_texture)
    {
        glUniformMatrix3fv(model_transform_attrib, 1, false, model_transform.get_data());
        glUniform1f(alpha_attrib, alpha);
        glUniform1i(use_texture_attrib, use_texture ? 1 : 0);
        glUniform3f(diffuse_color_attrib, diffuse_color.x, diffuse_color.y, diffuse_color.z);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
}
