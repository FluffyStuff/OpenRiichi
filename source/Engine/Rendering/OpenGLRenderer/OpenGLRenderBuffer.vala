using GL;

// TODO: Error handling
// TODO: Insert into rendering pipeline
/*class OpenGLRenderBuffer
{
    public OpenGLRenderBuffer()
    {
        /*handle = 0;
        width = 0;
        height = 0;* /
    }

    public void init(int width, int height)
    {
        uint buffer[1];
        glGenRenderbuffers(1, buffer);
        handle = buffer[0];

        glBindRenderbuffer(GL_RENDERBUFFER, handle);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
        //glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }

    public void resize(int width, int height)
    {
        if (this.width == width && this.height == height)
            return;

        this.width = width;
        this.height = height;

        glBindRenderbuffer(GL_RENDERBUFFER, handle);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
        //glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }

    public uint handle { get; private set; }
    public int width { get; private set; }
    public int height { get; private set; }
}*/
