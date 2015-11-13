using GL;
using Gee;

public class OpenGLShaderProgram3D
{
    private uint program;
    private OpenGLShader vertex_shader;
    private OpenGLShader fragment_shader;

    private OpenGLLightSource[] lights;

    private int vert_position_attribute;
    private int vert_texture_attribute;
    private int vert_normal_attribute;

    //private int texture_attrib = -1;
    private int projection_transform_attrib = -1;
    private int view_transform_attrib = -1;
    private int model_transform_attrib = -1;
    private int un_projection_transform_attrib = -1;
    private int un_view_transform_attrib = -1;
    private int un_model_transform_attrib = -1;
    private int light_count_attrib = -1;
    private int light_multi_attrib = -1;
    private int diffuse_color_attrib = -1;

    public OpenGLShaderProgram3D(string name, int max_lights, int vert_position_attribute, int vert_texture_attribute, int vert_normal_attribute)
    {
        this.vert_position_attribute = vert_position_attribute;
        this.vert_texture_attribute = vert_texture_attribute;
        this.vert_normal_attribute = vert_normal_attribute;

        vertex_shader = new OpenGLShader(name + ".vert", OpenGLShader.ShaderType.VERTEX_SHADER);
        fragment_shader = new OpenGLShader(name + ".frag", OpenGLShader.ShaderType.FRAGMENT_SHADER);

        lights = new OpenGLLightSource[max_lights];

        for (int i = 0; i < lights.length; i++)
            lights[i] = new OpenGLLightSource(i);
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

        glBindAttribLocation(program, vert_position_attribute, "position");
        glBindAttribLocation(program, vert_texture_attribute, "texture_coord");
        glBindAttribLocation(program, vert_normal_attribute, "normal");
        glBindFragDataLocation(program, 0, "out_color");

        glLinkProgram(program);

        //texture_attrib = glGetUniformLocation(program, "tex");
        projection_transform_attrib = glGetUniformLocation(program, "projection_transform");
        view_transform_attrib = glGetUniformLocation(program, "view_transform");
        model_transform_attrib = glGetUniformLocation(program, "model_transform");
        un_projection_transform_attrib = glGetUniformLocation(program, "un_projection_transform");
        un_view_transform_attrib = glGetUniformLocation(program, "un_view_transform");
        un_model_transform_attrib = glGetUniformLocation(program, "un_model_transform");
        light_count_attrib = glGetUniformLocation(program, "light_count");
        light_multi_attrib = glGetUniformLocation(program, "light_multiplier");
        diffuse_color_attrib = glGetUniformLocation(program, "diffuse_color");

        for (int i = 0; i < lights.length; i++)
            lights[i].init(program);

        uint err = glGetError();
        if (err != 0 && err != 0x500)
        {
            print("GL shader program linkage failure!\n");
            return false;
        }

        return true;
    }

    public void use_program()
    {
        glUseProgram(program);
    }

    public void apply_scene(Mat4 projection_transform, Mat4 view_transform, ArrayList<LightSource> lights)
    {
        use_program();

        glUniformMatrix4fv(projection_transform_attrib, 1, false, projection_transform.get_data());
        glUniformMatrix4fv(view_transform_attrib, 1, false, view_transform.get_data());
        glUniformMatrix4fv(un_projection_transform_attrib, 1, false, projection_transform.inverse().get_data());
        glUniformMatrix4fv(un_view_transform_attrib, 1, false, view_transform.inverse().get_data());
        glUniform1i(light_count_attrib, lights.size);

        for (int i = 0; i < lights.size; i++)
            this.lights[i].apply(lights[i].position, lights[i].color, lights[i].intensity);
    }

    public void render_object(int triangle_count, Mat4 model_transform, float light_multiplier, Color diffuse_color)
    {
        glUniformMatrix4fv(model_transform_attrib, 1, false, model_transform.get_data());
        glUniformMatrix4fv(un_model_transform_attrib, 1, false, model_transform.inverse().get_data());
        glUniform1f(light_multi_attrib, light_multiplier);
        glUniform4f(diffuse_color_attrib, diffuse_color.r, diffuse_color.g, diffuse_color.b, diffuse_color.a);

        glDrawArrays(GL_TRIANGLES, 0, triangle_count);
    }
}

private class OpenGLLightSource
{
    private int position_attrib;
    private int color_attrib;
    private int intensity_attrib;

    public OpenGLLightSource(int index)
    {
        this.index = index;
    }

    public void init(uint program)
    {
        position_attrib = glGetUniformLocation(program, "light_source[" + index.to_string() + "].position");
        color_attrib = glGetUniformLocation(program, "light_source[" + index.to_string() + "].color");
        intensity_attrib = glGetUniformLocation(program, "light_source[" + index.to_string() + "].intensity");
    }

    public void apply(Vec3 position, Color color, float intensity)
    {
        glUniform3f(position_attrib, position.x, position.y, position.z);
        glUniform3f(color_attrib, color.r, color.g, color.b);
        glUniform1f(intensity_attrib, intensity);
    }

    public int index { get; private set; }
}
