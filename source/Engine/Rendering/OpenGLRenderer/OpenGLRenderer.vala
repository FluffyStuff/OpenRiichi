using GL;
using SDL;
using Gee;

public class OpenGLRenderer : RenderTarget
{
    private const int MAX_LIGHTS = 2;

    private const int POSITION_ATTRIBUTE = 0;
    private const int TEXTURE_ATTRIBUTE = 1;
    private const int NORMAL_ATTRIBUTE = 2;

    private float anisotropic = 0;

    private OpenGLShaderProgram3D program_3D;
    private OpenGLShaderProgram2D program_2D;

	//private OpenGLShaderProgram2D post_processing_shader_program;

	//private OpenGLRenderBuffer render_buffer;
	//private OpenGLFrameBuffer primary_buffer;
	//private OpenGLFrameBuffer secondary_buffer;

    //private const int samplers[2] = {0, 1};

    private GLContext context;
    private unowned Window sdl_window;

    private Size2i view_size;

    public OpenGLRenderer(SDLWindowTarget window)
    {
        base(window);
        sdl_window = window.sdl_window;
        store = new OpenGLResourceStore(this);

    }

    ~OpenGLRenderer()
    {
        if (context != null)
        {
            SDL.GL.delete_context(context);
        }
    }

    protected override bool init(Size2i size)
    {
        if ((context = SDL.GL.create_context(sdl_window)) == null)
            return false;

        SDL.GL.set_attribute(GLattr.CONTEXT_MAJOR_VERSION, 2);
        SDL.GL.set_attribute(GLattr.CONTEXT_MINOR_VERSION, 1);
        SDL.GL.set_attribute(GLattr.CONTEXT_PROFILE_MASK, 1); // Core Profile
        GLEW.experimental = true;
        GLEW.init();

        glEnable(GL_CULL_FACE);
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);

        glEnable(GL_LINE_SMOOTH);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_FRAMEBUFFER_SRGB);
        glEnable(GL_MULTISAMPLE);

        shader_3D = "open_gl_shader_3D_low";
        shader_2D = "open_gl_shader_2D";
        change_v_sync(v_sync);

        // TODO: Put this somewhere
        sdl_window.set_icon(SDLImage.load("./Data/Icon.png"));
        sdl_window.set_size(size.width, size.height);

        program_3D = new OpenGLShaderProgram3D("./Data/Shaders/" + shader_3D, MAX_LIGHTS, POSITION_ATTRIBUTE, TEXTURE_ATTRIBUTE, NORMAL_ATTRIBUTE);
        if (!program_3D.init())
            return false;

        program_2D = new OpenGLShaderProgram2D("./Data/Shaders/" + shader_2D);
        if (!program_2D.init())
            return false;

        float aniso[1];
        glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, aniso);
        anisotropic = aniso[0];

        return true;
    }

    /*private void init_frame_buffer(int width, int height)
    {
        render_buffer = new OpenGLRenderBuffer(width, height);

        float[] frame_buffer_vertices = {-1, -1, 1, -1, -1, 1, 1, 1};
        glGenBuffers(1, frame_buffer_object_vertices);
        glBindBuffer(GL_ARRAY_BUFFER, frame_buffer_object_vertices);
        glBufferData(GL_ARRAY_BUFFER, 8 * sizeof(float), frame_buffer_vertices, GL_STATIC_DRAW);
        glVertexAttribPointer(pp_tex_attrib, 2, GL_FLOAT, GL_FALSE, 0, (GLvoid[])0);
        //glBindBuffer(GL_ARRAY_BUFFER, 0);
    }*/

    public override void render(RenderState state)
    {
        setup_projection(state.screen_size);
        glClearColor(state.back_color.r, state.back_color.g, state.back_color.b, state.back_color.a);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        foreach (RenderScene scene in state.scenes)
        {
            //glBindFramebuffer(GL_FRAMEBUFFER, 0);
            glClear(GL_DEPTH_BUFFER_BIT);

            Type type = scene.get_type();
            if (type == typeof(RenderScene2D))
                render_scene_2D((RenderScene2D)scene);
            else if (type == typeof(RenderScene3D))
                render_scene_3D((RenderScene3D)scene);

            //post_process_draw(scene);
        }

        window.swap();
    }

    private void render_scene_3D(RenderScene3D scene)
    {
        OpenGLShaderProgram3D program = program_3D;

        Mat4 projection_transform = get_projection_matrix(scene.focal_length, (float)scene.screen_size.width / scene.screen_size.height);
        Mat4 view_transform = scene.view_transform;
        Mat4 scene_transform = scene.scene_transform;

        program.apply_scene(projection_transform.mul_mat(scene_transform), view_transform, scene.lights);

        int last_texture_handle = -1;
        int last_array_handle = -1;
        foreach (RenderObject3D obj in scene.objects)
            render_object_3D(obj, program, ref last_texture_handle, ref last_array_handle);
    }

    private void render_object_3D(RenderObject3D obj, OpenGLShaderProgram3D program, ref int last_texture_handle, ref int last_array_handle)
    {
        OpenGLTextureResourceHandle texture_handle = (OpenGLTextureResourceHandle)get_texture(obj.texture.handle);
        OpenGLModelResourceHandle model_handle = (OpenGLModelResourceHandle)get_model(obj.model.handle);

        if (last_texture_handle != texture_handle.handle)
        {
            last_texture_handle = (int)texture_handle.handle;
            glBindTexture(GL_TEXTURE_2D, texture_handle.handle);
        }

        if (last_array_handle != model_handle.array_handle)
        {
            last_array_handle = (int)model_handle.array_handle;
            glBindVertexArray(model_handle.array_handle);
        }

        Mat4 model_transform = Calculations.get_model_matrix(obj.position, obj.rotation, obj.scale);

        program.render_object(model_handle.triangle_count, model_transform, obj.light_multiplier, obj.diffuse_color);
    }

    private void render_scene_2D(RenderScene2D scene)
    {
        OpenGLShaderProgram2D program = program_2D;

        program.apply_scene();

        foreach (RenderObject2D obj in scene.objects)
        {
            Type type = obj.get_type();
            if (type == typeof(RenderImage2D))
                render_image_2D((RenderImage2D)obj, program);
            else if (type == typeof(RenderLabel2D))
                render_label_2D((RenderLabel2D)obj, program);
            else if (type == typeof(RenderRectangle2D))
                render_rectangle_2D((RenderRectangle2D)obj, program);
        }
    }

    private void render_image_2D(RenderImage2D obj, OpenGLShaderProgram2D program)
    {
        OpenGLTextureResourceHandle texture_handle = (OpenGLTextureResourceHandle)get_texture(obj.texture.handle);
        glBindTexture(GL_TEXTURE_2D, (GLuint)texture_handle.handle);

        Mat3 model_transform = Calculations.get_model_matrix_3(obj.position, obj.rotation, obj.scale);

        program.render_object(model_transform, obj.diffuse_color, true);
    }

    private void render_label_2D(RenderLabel2D label, OpenGLShaderProgram2D program)
    {
        OpenGLLabelResourceHandle label_handle = (OpenGLLabelResourceHandle)get_label(label.handle);
        glBindTexture(GL_TEXTURE_2D, label_handle.handle);

        Mat3 model_transform = Calculations.get_model_matrix_3(label.position, label.rotation, label.scale);

        program.render_object(model_transform, label.diffuse_color, true);
    }

    private void render_rectangle_2D(RenderRectangle2D rectangle, OpenGLShaderProgram2D program)
    {
        Mat3 model_transform = Calculations.get_model_matrix_3(rectangle.position, rectangle.rotation, rectangle.scale);
        program.render_object(model_transform, rectangle.diffuse_color, false);
    }

    /*private void post_process_draw(RenderState state)
    {
        glUseProgram(post_processing_shader_program);

        //1st pass
        glBindFramebuffer(GL_FRAMEBUFFER, second_pass_object[0]);
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        glBindTexture(GL_TEXTURE_2D, frame_buffer_object_texture[0]);

        glUniform1f(bloom_attrib, (GLfloat)state.bloom);
        glUniform1i(vertical_attrib, (GLboolean)1);

        glBindBuffer(GL_ARRAY_BUFFER, frame_buffer_object_vertices[0]);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        //2nd pass
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, second_pass_object_texture[0]);
        glActiveTexture(GL_TEXTURE0);
        glUniform1iv(pp_texture_location, 2, samplers);

        glUniform1i(vertical_attrib, (GLboolean)0);

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }*/

    ///////////////////////////

    protected override IModelResourceHandle do_load_model(ResourceModel model)
    {
        int len = 10 * (int)sizeof(float);
        uint triangles[1];

        glGenBuffers(1, triangles);
        glBindBuffer(GL_ARRAY_BUFFER, triangles[0]);
        glBufferData(GL_ARRAY_BUFFER, len * model.points.length, (GLvoid[])model.points, GL_STATIC_DRAW);

        uint vao[1];
        glGenVertexArrays (1, vao);
        glBindVertexArray(vao[0]);

        glEnableVertexAttribArray(POSITION_ATTRIBUTE);
        glVertexAttribPointer(POSITION_ATTRIBUTE, 4, GL_FLOAT, false, len, (GLvoid[])0);
        glEnableVertexAttribArray(TEXTURE_ATTRIBUTE);
        glVertexAttribPointer(TEXTURE_ATTRIBUTE, 3, GL_FLOAT, false, len, (GLvoid[])(4 * sizeof(float)));
        glEnableVertexAttribArray(NORMAL_ATTRIBUTE);
        glVertexAttribPointer(NORMAL_ATTRIBUTE, 3, GL_FLOAT, false, len, (GLvoid[])(7 * sizeof(float)));

        return new OpenGLModelResourceHandle(triangles[0], model.points.length, vao[0]);
    }

    protected override ITextureResourceHandle do_load_texture(ResourceTexture texture)
    {
        int width = texture.size.width;
        int height = texture.size.height;

        uint tex[1];
        glGenTextures(1, tex);

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, tex[0]);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_SRGB_ALPHA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid[])texture.data);

        if (!texture.tile)
        {
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        if (anisotropic > 0)
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, anisotropic);

        return new OpenGLTextureResourceHandle(tex[0]);
    }

    protected override void do_load_label(ILabelResourceHandle label_handle, LabelBitmap label)
    {
        OpenGLLabelResourceHandle handle = (OpenGLLabelResourceHandle)label_handle;

        uint del[1] = { handle.handle };
        if (handle.created)
            glDeleteTextures(1, del);

        int width = label.size.width;
        int height = label.size.height;

        uint tex[1];
        glGenTextures(1, tex);

        float aniso[1];
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, tex[0]);
        glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, aniso);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, aniso[0]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, (GLvoid[])label.data);

        handle.handle = tex[0];
    }

    protected override ILabelResourceHandle create_label(ResourceLabel label)
    {
        return new OpenGLLabelResourceHandle();
    }

    protected override void change_v_sync(bool v_sync)
    {
        SDL.GL.set_swapinterval(v_sync ? 1 : 0);
    }

    protected override bool change_shader_3D(string name)
    {
        OpenGLShaderProgram3D program = new OpenGLShaderProgram3D("./Data/Shaders/" + name, MAX_LIGHTS, POSITION_ATTRIBUTE, TEXTURE_ATTRIBUTE, NORMAL_ATTRIBUTE);
        if (!program.init())
            return false;

        program_3D = program;
        return true;
    }

    protected override bool change_shader_2D(string name)
    {
        OpenGLShaderProgram2D program = new OpenGLShaderProgram2D("./Data/Shaders/" + name);
        if (!program.init())
            return false;

        program_2D = program;
        return true;
    }

    private void setup_projection(Size2i size)
    {
        if (view_size.width == size.width && view_size.height == size.height)
            return;
        view_size = size;

        glViewport(0, 0, view_size.width, view_size.height);
        reshape();
    }

    private void reshape()
    {
        /*primary_buffer.resize(view_width, view_height);
        secondary_buffer.resize(view_width, view_height);
        render_buffer.resize(view_width, view_height);*/
    }
}
