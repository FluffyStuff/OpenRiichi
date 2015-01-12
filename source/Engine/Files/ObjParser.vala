using Gee;

public static class ObjParser
{
    public static ModelData? parse(string[] file)
    {
        // TODO: Add curve/mtl/multi-object parsing
        try
        {
            ArrayList<string> v = new ArrayList<string>();
            ArrayList<string> vt = new ArrayList<string>();
            ArrayList<string> vn = new ArrayList<string>();
            //ArrayList<string> vp = new ArrayList<string>();
            ArrayList<string> f = new ArrayList<string>();

            foreach (string line in file)
            {
                string[] lines = line.split(" ", 2);
                if (lines[0] == "v")
                    v.add(lines[1]);
                else if (lines[0] == "vt")
                    vt.add(lines[1]);
                else if (lines[0] == "vn")
                    vn.add(lines[1]);
                //else if (lines[0] == "vp")
                //    vp.add(lines[1]);
                else if (lines[0] == "f")
                    f.add(lines[1]);
            }

            ModelVertex[] vertices = new ModelVertex[v.size];
            ModelUV[] uvs = new ModelUV[vt.size];
            ModelNormal[] normals = new ModelNormal[vn.size];
            //ModelParameter[] parameters = new ModelParameter[vp.size];

            for (int i = 0; i < v.size; i++)
                vertices[i] = parseVertex(v[i]);
            for (int i = 0; i < vt.size; i++)
                uvs[i] = parseUV(vt[i]);
            for (int i = 0; i < vn.size; i++)
                normals[i] = parseNormal(vn[i]);
            //for (int i = 0; i < vp.size; i++)
            //    parameters[i] = parseParameter(vp[i]);

            ModelData[] data = new ModelData[f.size];

            for (int n = 0; n < f.size; n++)
            {
                ModelDataIndex[] indices = parseFace(f[n]);
                ModelTriangle[] triangles = new ModelTriangle[indices.length - 2];

                for (int i = 2; i < indices.length; i++)
                {
                    bool has_uv = indices[0].has_uv;
                    bool has_normal = indices[0].has_normal;

                    // Can't declare this inline due to a bug in vala
                    ModelUV empty_uv = {};
                    ModelNormal empty_normal = {};
                    ModelUV uv_a = has_uv ? uvs[indices[  0].uv - 1] : empty_uv;
                    ModelUV uv_b = has_uv ? uvs[indices[i-1].uv - 1] : empty_uv;
                    ModelUV uv_c = has_uv ? uvs[indices[  i].uv - 1] : empty_uv;
                    ModelNormal normal_a = has_normal ? normals[indices[  0].normal - 1] : empty_normal;
                    ModelNormal normal_b = has_normal ? normals[indices[i-1].normal - 1] : empty_normal;
                    ModelNormal normal_c = has_normal ? normals[indices[  i].normal - 1] : empty_normal;

                    triangles[i-2] = ModelTriangle()
                    {
                        vertex_a = vertices[indices[  0].vertex - 1],
                        vertex_b = vertices[indices[i-1].vertex - 1],
                        vertex_c = vertices[indices[  i].vertex - 1],
                        uv_a = uv_a,
                        uv_b = uv_b,
                        uv_c = uv_c,
                        normal_a = normal_a,
                        normal_b = normal_b,
                        normal_c = normal_c,
                        has_uv = has_uv,
                        has_normal = has_normal
                    };
                }

                data[n] = new ModelData(triangles);
            }

            int count = 0;
            foreach (ModelData d in data)
                count += d.triangles.length;

            ModelTriangle[] triangles = new ModelTriangle[count];

            for (int i = 0, a = 0; i < data.length; i++)
                for (int t = 0; t < data[i].triangles.length; t++)
                    triangles[a++] = data[i].triangles[t];

            return new ModelData(triangles);
        }
        catch (ParsingError e)
        {
            return null;
        }
    }

    private static ModelVertex parseVertex(string line) throws ParsingError
    {
        string[] parts = line.split(" ");

        if (parts.length != 3 && parts.length != 4)
            throw new ParsingError.PARSING("Invalid number of vertex line args.");

        double x, y, z, w = 1;
        bool parsed = double.try_parse(parts[0], out x);
        parsed &= double.try_parse(parts[1], out y);
        parsed &= double.try_parse(parts[2], out z);

        if (parts.length >= 4)
            parsed &= double.try_parse(parts[3], out w);

        if (!parsed)
            throw new ParsingError.PARSING("Invalid double value in vertex line.");

        //x += 2.5f;
        //y -= 1.2f;
        //z = -z;
        //w = 2.0f;

        return ModelVertex() { x = (float)x, y = (float)y, z = (float)z, w = (float)w };
    }

    private static ModelUV parseUV(string line) throws ParsingError
    {
        string[] parts = line.split(" ");

        if (parts.length < 1 && parts.length > 3)
            throw new ParsingError.PARSING("Invalid number of UV line args.");

        double u, v = 0, w = 0;
        bool parsed = double.try_parse(parts[0], out u);

        if (parts.length >= 2)
            parsed &= double.try_parse(parts[1], out v);

        if (parts.length >= 3)
            parsed &= double.try_parse(parts[2], out w);

        if (!parsed)
            throw new ParsingError.PARSING("Invalid double value in UV line.");

        v = 1-v;

        return ModelUV() { u = (float)u, v = (float)v, w = (float)w };
    }

    private static ModelNormal parseNormal(string line) throws ParsingError
    {
        string[] parts = line.split(" ");

        if (parts.length != 3)
            throw new ParsingError.PARSING("Invalid number of normal line args.");

        double i, j, k;
        bool parsed = double.try_parse(parts[0], out i);
        parsed &= double.try_parse(parts[1], out j);
        parsed &= double.try_parse(parts[2], out k);

        if (!parsed)
            throw new ParsingError.PARSING("Invalid double value in normal line.");

        return ModelNormal() { i = (float)i, j = (float)j, k = (float)k };
    }

    /*private static ModelParameter parseParameter(string line) throws ParsingError
    {
        string[] parts = line.split(" ");

        if (parts.length != 2 && parts.length != 3)
            throw new ParsingError.PARSING("Invalid number of parameter line args.");

        double u, v, w = 1;
        bool parsed = double.try_parse(parts[0], out u);
        parsed &= double.try_parse(parts[1], out v);

        if (parts.length >= 3)
            parsed &= double.try_parse(parts[2], out w);

        if (!parsed)
            throw new ParsingError.PARSING("Invalid double value in parameter line.");

        return ModelParameter() { u = (float)u, v = (float)v, w = (float)w };
    }*/

    private static ModelDataIndex[] parseFace(string line) throws ParsingError
    {
        string[] parts = line.split(" ");

        if (parts.length < 3)
            throw new ParsingError.PARSING("Too few vertices in face.");

        ModelDataIndex[] index = new ModelDataIndex[parts.length];

        bool normal_only = parts[0].contains("//");
        bool has_uv = false, has_normal = false;

        for (int i = 0; i < parts.length; i++)
        {
            int64 v, t = -1, n = -1;

            string[] indices = parts[i].split(normal_only ? "//" : "/");
            if (indices.length < 1)
                throw new ParsingError.PARSING("Invalid number of face part args.");

            bool parsed = int64.try_parse(indices[0], out v);

            if (normal_only)
            {
                if (indices.length != 2)
                    throw new ParsingError.PARSING("Invalid number of face part args.");

                parsed &= int64.try_parse(indices[1], out n);
                has_normal = true;
            }
            else
            {
                if (indices.length > 3)
                    throw new ParsingError.PARSING("Invalid number of face part args.");

                if (indices.length >= 2)
                {
                    parsed &= int64.try_parse(indices[1], out t);
                    has_uv = true;
                }

                if (indices.length >= 3)
                {
                    parsed &= int64.try_parse(indices[2], out n);
                    has_normal = true;
                }
            }

            if (!parsed)
                throw new ParsingError.PARSING("Invalid double value in face line part.");

            index[i] = ModelDataIndex() { vertex = (int)v, uv = (int)t, normal = (int)n, has_uv = has_uv, has_normal = has_normal };
        }

        return index;
    }

    private struct ModelDataIndex
    {
        public int vertex;
        public int uv;
        public int normal;
        public bool has_uv;
        public bool has_normal;
    }
}

public struct ModelVertex
{
    float x;
    float y;
    float z;
    float w;
}

public struct ModelUV
{
    float u;
    float v;
    float w;
}

public struct ModelNormal
{
    float i;
    float j;
    float k;
}

/*public struct ModelParameter
{
    float u;
    float v;
    float w;
}*/

public class ModelData
{
    public ModelData(ModelTriangle[] triangles)
    {
        this.triangles = triangles;
    }

    public ModelPoint[] create_points()
    {
        ModelPoint[] points = new ModelPoint[triangles.length * 3];

        for (int i = 0; i < triangles.length; i++)
        {
            points[3*i+2] = ModelPoint() { vertex = triangles[i].vertex_a, uv = triangles[i].uv_a, normal = triangles[i].normal_a };
            points[3*i+1] = ModelPoint() { vertex = triangles[i].vertex_b, uv = triangles[i].uv_b, normal = triangles[i].normal_b };
            points[3*i+0] = ModelPoint() { vertex = triangles[i].vertex_c, uv = triangles[i].uv_c, normal = triangles[i].normal_c };
        }

        /*float[,] p =
        {
            {  -0.5f, -0.5f, 0.0f, 1.0f  },
            {  -0.5f,  0.5f, 0.0f, 1.0f  },
            {   0.5f,  0.5f, 0.0f, 1.0f  },
            {   0.5f, -0.5f, 0.0f, 1.0f  }
        };

        float[,] uv =
        {
            {  0.0f, 0.0f  },
            {  0.0f, 1.0f  },
            {  1.0f, 1.0f  },
            {  1.0f, 0.0f  }
        };

        ModelPoint a = ModelPoint() { vertex = ModelVertex() { x = p[0,0], y = p[0,1], z = p[0,2], w = p[0,3] }, uv = ModelUV() { u = uv[0,0], v = uv[0,1] } };
        ModelPoint b = ModelPoint() { vertex = ModelVertex() { x = p[1,0], y = p[1,1], z = p[1,2], w = p[1,3] }, uv = ModelUV() { u = uv[1,0], v = uv[1,1] } };
        ModelPoint c = ModelPoint() { vertex = ModelVertex() { x = p[2,0], y = p[2,1], z = p[2,2], w = p[2,3] }, uv = ModelUV() { u = uv[2,0], v = uv[2,1] } };
        ModelPoint d = ModelPoint() { vertex = ModelVertex() { x = p[3,0], y = p[3,1], z = p[3,2], w = p[3,3] }, uv = ModelUV() { u = uv[3,0], v = uv[3,1] } };

        points = new ModelPoint[] { a, d, c, a, c, b };

        for (int i = 0; i < points.length; i++)
        {
            for (int j = 0; j < 10; j++)
            {
                float f = *((float*)points + sizeof(ModelPoint) / 4 * i + j);
                print("%f ", f);
            }

            print("\n");
        }*/

        return points;
    }

    public ModelTriangle[] triangles { get; private set; }
}

public struct ModelPoint
{
    ModelVertex vertex;
    ModelUV uv;
    ModelNormal normal;
}

public struct ModelTriangle
{
    ModelVertex vertex_a;
    ModelVertex vertex_b;
    ModelVertex vertex_c;
    ModelUV uv_a;
    ModelUV uv_b;
    ModelUV uv_c;
    ModelNormal normal_a;
    ModelNormal normal_b;
    ModelNormal normal_c;
    bool has_uv;
    bool has_normal;
}

errordomain ParsingError { PARSING }
