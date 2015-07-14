using GL;
using SDL;
using Gee;

public class OpenGLRenderer : RenderTarget
{
    private const int MAX_LIGHTS = 2;

    private const int POSITION_ATTRIBUTE = 0;
    private const int TEXTURE_ATTRIBUTE = 1;
    private const int NORMAL_ATTRIBUTE = 2;

    private OpenGLShaderProgram3D program_3D;
    private OpenGLShaderProgram2D program_2D;

	//private OpenGLShaderProgram2D post_processing_shader_program;

	//private OpenGLRenderBuffer render_buffer;
	//private OpenGLFrameBuffer primary_buffer;
	//private OpenGLFrameBuffer secondary_buffer;

	//private uint frame_buffer_object_vertices;

	//private uint vertex_array_ID;

    //private const int samplers[2] = {0, 1};

    private GLContext context;
    private unowned Window sdl_window;

    private int view_width = 0;
    private int view_height = 0;

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

    protected override bool init(int width, int height)
    {
        if ((context = SDL.GL.create_context(sdl_window)) == null)
            return false;

        SDL.GL.set_attribute(GLattr.CONTEXT_MAJOR_VERSION, 4);
        SDL.GL.set_attribute(GLattr.CONTEXT_MINOR_VERSION, 0);
        SDL.GL.set_attribute(GLattr.CONTEXT_PROFILE_MASK, 1); // Core Profile
        GLEW.init();

        glEnable(GL_CULL_FACE);
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);

        glEnable(GL_LINE_SMOOTH);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_FRAMEBUFFER_SRGB);
        glEnable(GL_MULTISAMPLE);

        change_v_sync(v_sync);

        // TODO: Put this somewhere
        sdl_window.set_icon(SDLImage.load("./Data/Icon.png"));
        sdl_window.set_size(width, height);

        // ??
        //glGenVertexArrays(1, vertex_array_ID);
        //glBindVertexArray(vertex_array_ID[0]);

        program_3D = new OpenGLShaderProgram3D("./Data/Shaders/open_gl_shader_3D", MAX_LIGHTS, POSITION_ATTRIBUTE, TEXTURE_ATTRIBUTE, NORMAL_ATTRIBUTE);
        if (!program_3D.init())
            return false;

        program_2D = new OpenGLShaderProgram2D("./Data/Shaders/open_gl_shader_2D");
        if (!program_2D.init())
            return false;

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
        setup_projection(state.screen_width, state.screen_height);
        glClearColor(state.back_color.r, state.back_color.g, state.back_color.b, state.back_color.a);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        foreach (RenderScene scene in state.scenes)
        {
            //glBindFramebuffer(GL_FRAMEBUFFER, 0);
            //glClear(GL_DEPTH_BUFFER_BIT);

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

        Mat4 projection_transform = get_projection_matrix(scene.focal_length, (float)scene.width / scene.height);
        Mat4 view_transform = scene.view_transform;

        program.apply_scene(projection_transform, view_transform, scene.lights);

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

        program.render_object(model_handle.triangle_count, model_transform, obj.alpha, obj.light_multiplier, obj.diffuse_color);
    }

    private void render_scene_2D(RenderScene2D scene)
    {
        OpenGLShaderProgram2D program = program_2D;

        program.apply_scene();

        foreach (RenderObject2D obj in scene.objects)
            render_object_2D(obj, program);
    }

    private void render_object_2D(RenderObject2D obj, OpenGLShaderProgram2D program)
    {
        OpenGLTextureResourceHandle texture_handle = (OpenGLTextureResourceHandle)get_texture(obj.texture.handle);
        glBindTexture(GL_TEXTURE_2D, (GLuint)texture_handle.handle);

        Mat3 model_transform = Calculations.get_model_matrix_3(obj.position, obj.rotation, obj.scale);

        program.render_object(model_transform, obj.alpha, obj.diffuse_color);
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

    ///////////////////////////

    protected override ITextureResourceHandle do_load_texture(ResourceTexture texture)
    {
        int width = texture.width;
        int height = texture.height;

        uint tex[1];
        glGenTextures(1, tex);

        float aniso[1];
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, tex[0]);
        glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, aniso);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, aniso[0]);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_SRGB_ALPHA, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, (GLvoid[])texture.data);

        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        return new OpenGLTextureResourceHandle(tex[0]);
    }

    protected override void change_v_sync(bool v_sync)
    {
        SDL.GL.set_swapinterval(v_sync ? 1 : 0);
    }

    private void setup_projection(int width, int height)
    {
        if (view_width == width && view_height == height)
            return;
        view_width = width;
        view_height = height;

        glViewport(0, 0, view_width, view_height);
        reshape();
    }

    private void reshape()
    {
        /*primary_buffer.resize(view_width, view_height);
        secondary_buffer.resize(view_width, view_height);
        render_buffer.resize(view_width, view_height);*/
    }
}
