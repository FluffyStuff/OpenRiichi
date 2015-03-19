using GL;
using SDL;
using Gee;

public class OpenGLRenderer : RenderTarget
{
    string[] vertex_source;
    string[] fragment_source;
	string[] post_processing_vertex_source;
	string[] post_processing_fragment_source;
    private GLuint shader_program;
	private GLuint post_processing_shader_program;
    private GLuint vertex_shader;
    private GLuint fragment_shader;
	private GLuint post_processing_vertex_shader;
	private GLuint post_processing_fragment_shader;
	private GLuint frame_buffer_object[1];
	private GLuint frame_buffer_object_texture[1];
	private GLuint color_buffer[1];
	private GLuint frame_buffer_object_vertices[1];
	private GLuint vertexbuffer[1];
	private GLuint VertexArrayID[1];
    private GLint pos_attrib = 0;
    private GLint tex_attrib = 1;
    private GLint nor_attrib = 2;
    private GLint pp_tex_attrib = 1;
    private GLint pp_texture_location = -1;
    private GLint texture_location = -1;
    private GLint rotation_attrib = -1;
    private GLint position_attrib = -1;
    private GLint scale_attrib = -1;
    private GLint alpha_attrib = -1;
    private GLint light_multi_attrib = -1;
    private GLint diffuse_color_attrib = -1;
    private GLint camera_rotation_attrib = -1;
    private GLint camera_position_attrib = -1;
    private GLint aspect_ratio_attrib = -1;
    private GLint light_count_attrib = -1;
    private GLint postproc_attrib = -1;

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

    protected override bool init()
    {
        if ((context = SDL.GL.create_context(sdl_window)) == null)
            return false;

        SDL.GL.set_attribute(GLattr.CONTEXT_MAJOR_VERSION, 4);
        SDL.GL.set_attribute(GLattr.CONTEXT_MINOR_VERSION, 0);
        SDL.GL.set_swapinterval(1);
        GLEW.init();

        glEnable(GL_CULL_FACE);
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);

        glEnable(GL_LINE_SMOOTH);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_FRAMEBUFFER_SRGB);
        glEnable(GL_MULTISAMPLE);

        // TODO: Put this somewhere
        sdl_window.set_icon(SDLImage.load("textures/Icon.png"));
        sdl_window.set_size(1280, 800);

        init_shader();
        init_frame_buffer();
        init_post_processing_shader();
        triangletest();
        return true;
    }
	private void build_shader(GLuint target_shader, string type)
	{
		glCompileShader(target_shader);

        GLint success[1] = {-1};
        glGetShaderiv(target_shader, GL_COMPILE_STATUS, success);

        if (success[0] == GL_FALSE)
        {
            print("%s Shader compilation failure!!!\n", type);

            GLsizei log_size[1];
            glGetShaderiv(target_shader, GL_INFO_LOG_LENGTH, log_size);
            GLubyte[] error_log = new GLubyte[log_size[0]];
            glGetShaderInfoLog(target_shader, log_size[0], log_size, error_log);

            for (int i = 0; i < log_size[0]; i++)
                print("%c", error_log[i]);
        }

	}
    private void init_shader()
    {
        vertex_source = FileLoader.load("./3d/vertex_shader.shader");
        fragment_source = FileLoader.load("./3d/fragment_shader.shader");

        vertex_shader = glCreateShader(GL_VERTEX_SHADER);
        fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);

        for (int i = 0; i < vertex_source.length; i++)
            vertex_source[i] = vertex_source[i] + "\n";
        for (int i = 0; i < fragment_source.length; i++)
            fragment_source[i] = fragment_source[i] + "\n";

        glShaderSource(vertex_shader, (GLsizei)vertex_source.length, vertex_source, (GLint[])0);
        glShaderSource(fragment_shader, (GLsizei)fragment_source.length, fragment_source, (GLint[])0);

        build_shader(vertex_shader, "vertex");

        build_shader(fragment_shader, "fragment");

        shader_program = glCreateProgram();

        glAttachShader(shader_program, vertex_shader);
        glAttachShader(shader_program, fragment_shader);
        glBindFragDataLocation(shader_program, 0, "outColor");

        glBindAttribLocation(shader_program, pos_attrib, "position");
        glBindAttribLocation(shader_program, tex_attrib, "texcoord");
        glBindAttribLocation(shader_program, nor_attrib, "normals");

        glLinkProgram(shader_program);
        glUseProgram(shader_program);

        texture_location = glGetUniformLocation(shader_program, "tex");
        rotation_attrib = glGetUniformLocation(shader_program, "rotation_vec");
        position_attrib = glGetUniformLocation(shader_program, "position_vec");
        scale_attrib = glGetUniformLocation(shader_program, "scale_vec");
        camera_rotation_attrib = glGetUniformLocation(shader_program, "camera_rotation");
        camera_position_attrib = glGetUniformLocation(shader_program, "camera_position");
        light_count_attrib = glGetUniformLocation(shader_program, "light_count");
        aspect_ratio_attrib = glGetUniformLocation(shader_program, "aspect_ratio");
        alpha_attrib = glGetUniformLocation(shader_program, "alpha");
        light_multi_attrib = glGetUniformLocation(shader_program, "light_multiplier");
        diffuse_color_attrib = glGetUniformLocation(shader_program, "diffuse_color");


        if (glGetError() != 0)
            print("GL shader program failure!!!\n");
    }
    private void on_reshape()
    {
        glBindTexture(GL_TEXTURE_2D, frame_buffer_object_texture[0]);
        glTexImage2D(GL_TEXTURE_2D, 0, (GLint)GL_RGBA, (GLsizei)view_width, (GLsizei)view_height, 0, (GLint)GL_RGBA, GL_UNSIGNED_BYTE, null);
        //glBindTexture(GL_TEXTURE_2D, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, color_buffer[0]);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, (GLsizei)view_width, (GLsizei)view_height);
        //glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }
    private void init_frame_buffer()
    {
        glActiveTexture(GL_TEXTURE0);
        glGenTextures(1, frame_buffer_object_texture);
        glBindTexture(GL_TEXTURE_2D, frame_buffer_object_texture[0]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        //print("width = %d, height = %d", state.screen_width, state.screen_height);
        glTexImage2D(GL_TEXTURE_2D, 0, (GLint)GL_RGBA, (GLsizei)1280, (GLsizei)800, 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid[]?)0);
        glBindTexture(GL_TEXTURE_2D, 0);

        glGenRenderbuffers(1, color_buffer);
        glBindRenderbuffer(GL_RENDERBUFFER, color_buffer[0]);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, (GLsizei)1280, (GLsizei)800);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);

        glGenFramebuffers(1, frame_buffer_object);
        glBindFramebuffer(GL_FRAMEBUFFER, frame_buffer_object[0]);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, frame_buffer_object_texture[0], 0);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, color_buffer[0]);
        GLenum status;
        if ((status = glCheckFramebufferStatus(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE) {
            print("glCheckFramebufferStatus: error %d", (int)status);
            //return;
        }
        glBindFramebuffer(GL_FRAMEBUFFER, 0);



        GLfloat[] frame_buffer_vertices = {-1,-1, 1, -1, -1,1, 1, 1};
        glGenBuffers(1, frame_buffer_object_vertices);
        glBindBuffer(GL_ARRAY_BUFFER, frame_buffer_object_vertices[0]);
        glBufferData(GL_ARRAY_BUFFER, 8, (GL.GLvoid[])frame_buffer_vertices, GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, 0);

    }

	private void init_post_processing_shader()
	{

		post_processing_vertex_source = FileLoader.load("./3d/bloom_vertex_shader.shader");
        post_processing_fragment_source = FileLoader.load("./3d/bloom_fragment_shader.shader");

        post_processing_vertex_shader = glCreateShader(GL_VERTEX_SHADER);
        post_processing_fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);

        for (int i = 0; i < post_processing_vertex_source.length; i++)
            post_processing_vertex_source[i] = post_processing_vertex_source[i] + "\n";
        for (int i = 0; i < post_processing_fragment_source.length; i++)
            post_processing_fragment_source[i] = post_processing_fragment_source[i] + "\n";

		glShaderSource(post_processing_vertex_shader, (GLsizei)post_processing_vertex_source.length, post_processing_vertex_source, (GLint[])0);
		glShaderSource(post_processing_fragment_shader, (GLsizei)post_processing_fragment_source.length, post_processing_fragment_source, (GLint[])0);


		build_shader(post_processing_vertex_shader, "post processing vertex");

		build_shader(post_processing_fragment_shader, "post processing fragment");

		post_processing_shader_program = glCreateProgram();
		glAttachShader(post_processing_shader_program, post_processing_vertex_shader);
		glAttachShader(post_processing_shader_program, post_processing_fragment_shader);
		glBindFragDataLocation(post_processing_shader_program, 0, "outColor");
        glBindAttribLocation(post_processing_shader_program, pp_tex_attrib, "iTexcoord");
		glLinkProgram(post_processing_shader_program);


		pp_texture_location = glGetUniformLocation(post_processing_shader_program, "texi");

		if (glGetError() != 0)
			print("GL shader program failure!!!\n");
	}

    public override void render(RenderState state)
    {
        glBindFramebuffer(GL_FRAMEBUFFER,frame_buffer_object[0]);
        render_scene(state);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        post_process_draw();
        glViewport(0,0,1280,800);
        window.swap();
    }

    protected override IObject3DResourceHandle do_load_3D_object(Resource3DObject obj)
    {
        GLsizei len = (GLsizei)(10 * sizeof(float));
        GLuint triangles[1];

        glGenBuffers(1, triangles);
        glBindBuffer(GL_ARRAY_BUFFER, triangles[0]);
        glBufferData(GL_ARRAY_BUFFER, (GLsizeiptr)(len * obj.points.length), (GL.GLvoid[])obj.points, GL_STATIC_DRAW);

        return new OpenGLObject3DResourceHandle(triangles[0], obj.points.length);
    }

    protected override ITextureResourceHandle do_load_texture(ResourceTexture texture)
    {
        GLint width = (GLint)texture.width;
        GLint height = (GLint)texture.height;

        GLuint tex[1];
        glGenTextures(1, tex);

        float aniso[1] = { 0.0f };
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, tex[0]);
        glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, (GLfloat[])aniso);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, (GLfloat)aniso[0]);
        glTexImage2D(GL_TEXTURE_2D, 0, (GLint)GL_SRGB_ALPHA, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, (GLvoid[])texture.data);

        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        return new OpenGLTextureResourceHandle(tex[0]);
    }
    private void triangletest()
    {
        GLfloat vbd[9] ={(GLfloat)(-1.0),(GLfloat)(-1.0),(GLfloat)(0.0),(GLfloat)(1.0),(GLfloat)(-1.0),(GLfloat)(0.0),(GLfloat)(0.0),(GLfloat)(1.0),(GLfloat)(0.0)};
        // This will identify our vertex buffer

        // Generate 1 buffer, put the resulting identifier in vertexbuffer
        glGenBuffers(1, vertexbuffer);
        // The following commands will talk about our 'vertexbuffer' buffer
        glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer[0]);
        // Give our vertices to OpenGL.
        glBufferData(GL_ARRAY_BUFFER, (GLsizeiptr)vbd.length*4, (GLvoid[]?)vbd, GL_STATIC_DRAW);
    }
    private void post_process_draw()
    {
        glClearColor((GLfloat)0.0, (GLfloat)0.0, (GLfloat)0.0, (GLfloat)1.0);
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

        glUseProgram(post_processing_shader_program);
        glBindTexture(GL_TEXTURE_2D, frame_buffer_object_texture[0]);
        glUniform1i(pp_texture_location, /*GL_TEXTURE*/1);
        glEnableVertexAttribArray(pp_tex_attrib);
        GLsizei len = (GLsizei)(10 * sizeof(float));
        glVertexAttribPointer(pp_tex_attrib, 2, GL_FLOAT, GL_FALSE, 0, (GLvoid[])0);
        glBindBuffer(GL_ARRAY_BUFFER, frame_buffer_object_vertices[0]);
        glDrawArrays(GL_TRIANGLES, 0, 4);
        glDisableVertexAttribArray(pp_tex_attrib);
    }
    private void render_scene(RenderState state)
    {

        setup_projection(state, true);
        glClearColor((GLfloat)state.back_color.r, (GLfloat)state.back_color.g, (GLfloat)state.back_color.b, (GLfloat)state.back_color.a);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glUniform3f(camera_position_attrib, (GLfloat)state.camera_position.x, (GLfloat)state.camera_position.y, (GLfloat)state.camera_position.z);
        glUniform3f(camera_rotation_attrib, (GLfloat)state.camera_rotation.x, (GLfloat)state.camera_rotation.y, (GLfloat)state.camera_rotation.z);
        glUniform1f(aspect_ratio_attrib, (GLfloat)state.screen_width / state.screen_height);
        glUniform1i(light_count_attrib, (GLint)state.lights.size);

        for (int i = 0; i < state.lights.size; i++)
        {
            GLint light_source_attrib = glGetUniformLocation(shader_program, "light_source[" + i.to_string() + "].position");
            GLint light_color_attrib = glGetUniformLocation(shader_program, "light_source[" + i.to_string() + "].color");
            GLint light_intensity_attrib = glGetUniformLocation(shader_program, "light_source[" + i.to_string() + "].intensity");
            glUniform3f(light_source_attrib, (GLfloat)state.lights[i].position.x, (GLfloat)state.lights[i].position.y, (GLfloat)state.lights[i].position.z);
            glUniform3f(light_color_attrib, (GLfloat)state.lights[i].color.x, (GLfloat)state.lights[i].color.y, (GLfloat)state.lights[i].color.z);
            glUniform1f(light_intensity_attrib, (GLfloat)state.lights[i].intensity);
        }

        Vec3 pos;

        foreach (Render3DObject obj in state.objects)
            pos = render_3D_object(obj);

        pos = Vec3() { x = pos.x + 1, y = pos.y + 1, z = pos.z + 1 };
        glUniform3f(camera_position_attrib, (GLfloat)pos.x, (GLfloat)pos.y, (GLfloat)pos.z);


    }

    private Vec3 render_3D_object(Render3DObject obj)
    {
        OpenGLTextureResourceHandle handle = (OpenGLTextureResourceHandle)get_texture(obj.texture.handle);
        glBindTexture(GL_TEXTURE_2D, (GLuint)handle.handle);

        OpenGLObject3DResourceHandle obj_handle = (OpenGLObject3DResourceHandle)get_3D_object(obj.handle);
        glBindBuffer(GL_ARRAY_BUFFER, (GLuint)obj_handle.handle);

        Vec3 pos = Vec3() { x = obj.position.x, y = obj.position.y, z = obj.position.z };

        glUniform3f(rotation_attrib, (GLfloat)obj.rotation.x, (GLfloat)obj.rotation.y, (GLfloat)obj.rotation.z);
        //glUniform3f(position_attrib, (GLfloat)obj.position.x, (GLfloat)obj.position.y, (GLfloat)obj.position.z);
        glUniform3f(position_attrib, (GLfloat)pos.x, (GLfloat)pos.y, (GLfloat)pos.z);
        glUniform3f(scale_attrib, (GLfloat)obj.scale.x, (GLfloat)obj.scale.y, (GLfloat)obj.scale.z);
        glUniform1f(alpha_attrib, (GLfloat)obj.alpha);
        glUniform1f(light_multi_attrib, (GLfloat)obj.light_multiplier);
        glUniform3f(diffuse_color_attrib, (GLfloat)obj.diffuse_color.x, (GLfloat)obj.diffuse_color.y, (GLfloat)obj.diffuse_color.z);

        GLsizei len = (GLsizei)(10 * sizeof(float));
        glEnableVertexAttribArray(pos_attrib);
        glVertexAttribPointer(pos_attrib, 4, GL_FLOAT, GL_FALSE, len, (GLvoid[])0);
        glEnableVertexAttribArray(tex_attrib);
        glVertexAttribPointer(tex_attrib, 3, GL_FLOAT, GL_FALSE, len, (GLvoid[])(4 * sizeof(GLfloat)));
        glEnableVertexAttribArray(nor_attrib);
        glVertexAttribPointer(nor_attrib, 3, GL_FLOAT, GL_FALSE, len, (GLvoid[])(7 * sizeof(GLfloat)));

        glDrawArrays(GL_TRIANGLES, 0, (GLsizei)obj_handle.triangle_count);

        return pos;
    }

    private void setup_projection(RenderState state, bool ortho)
    {
        if (view_width == state.screen_width && view_height == state.screen_height)
            return;
        view_width = state.screen_width;
        view_height = state.screen_height;

        glViewport(0, 0, (GLsizei)view_width, (GLsizei)view_height);
        //on_reshape();
    }
}
