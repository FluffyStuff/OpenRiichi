public class Calculations
{
    private Calculations(){}

    public static uint8[] int_to_data(uint32 n)
    {
        uint8[] buffer = new uint8[4];
        buffer[0] = (uint8)(n >> 24);
        buffer[1] = (uint8)(n >> 16);
        buffer[2] = (uint8)(n >>  8);
        buffer[3] = (uint8)n;
        return buffer;
}


    public static Vec3 rotate(Vec3 origin, Vec3 rotation, Vec3 offset)
    {
        Vec3 point = offset;
        point = rotate_x(origin, rotation.x, point);
        point = rotate_y(origin, rotation.y, point);
        point = rotate_z(origin, rotation.z, point);
        return point;
    }

    public static Vec3 rotate_x(Vec3 origin, float rotation, Vec3 offset)
    {
        if (rotation == 0)
            return offset;

        float c = (float)Math.cos(rotation * Math.PI);
        float s = (float)Math.sin(rotation * Math.PI);

        Vec3 p = vec3_minus(offset, origin);

        p = Vec3()
        {
            x = p.x,
            y = p.y * c - p.z * s,
            z = p.y * s + p.z * c
        };

        return vec3_plus(p, origin);
    }

    public static Vec3 rotate_y(Vec3 origin, float rotation, Vec3 offset)
    {
        if (rotation == 0)
            return offset;

        float c = (float)Math.cos(rotation * Math.PI);
        float s = (float)Math.sin(rotation * Math.PI);

        Vec3 p = vec3_minus(offset, origin);

        p = Vec3()
        {
            x = p.z * s + p.x * c,
            y = p.y,
            z = p.z * c - p.x * s
        };

        return vec3_plus(p, origin);
    }

    public static Vec3 rotate_z(Vec3 origin, float rotation, Vec3 offset)
    {
        if (rotation == 0)
            return offset;

        float c = (float)Math.cos(rotation * Math.PI);
        float s = (float)Math.sin(rotation * Math.PI);

        Vec3 p = vec3_minus(offset, origin);

        p = Vec3()
        {
            x = p.x * c - p.y * s,
            y = p.x * s + p.y * c,
            z = p.z
        };

        return vec3_plus(p, origin);
    }

    public static Vec3 vec3_plus(Vec3 a, Vec3 b)
    {
        return Vec3() { x = a.x + b.x, y = a.y + b.y, z = a.z + b.z };
    }

    public static Vec3 vec3_minus(Vec3 a, Vec3 b)
    {
        return Vec3() { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z };
    }

    public static float vec3_dot(Vec3 a, Vec3 b)
    {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    public static float vec4_dot(Vec4 a, Vec4 b)
    {
        return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
    }

    // a - b
    public static Vec4 vec4_minus(Vec4 a, Vec4 b)
    {
        return Vec4() { x = a.x - b.x, y = a.y - b.y, z = a.z - b.z, w = a.w - b.w };
    }

    public static Vec3 vec3_norm(Vec3 vec)
    {
        float len = (float)Math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z);
        return Vec3() { x = vec.x / len, y = vec.y / len, z = vec.z / len };
    }

    public static Vec3 vec3_mul_scalar(Vec3 vec, float s)
    {
        return Vec3() { x = vec.x * s, y = vec.y * s, z = vec.z * s };
    }

    public static float vec3_dist_sq(Vec3 a, Vec3 b)
    {
        return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y) + (a.z - b.z) * (a.z - b.z);
    }

    public static Vec3 vec3_neg(Vec3 vec)
    {
        return Vec3() { x = -vec.x, y = -vec.y, z = -vec.z };
    }

    public static Vec3 get_ray(Mat4 projection_matrix, Mat4 view_matrix, float point_x, float point_y, float width, float height)
    {
        float aspect = width / height;
        float x = -(1 - point_x / width  * 2) * aspect;
        float y =  (1 - point_y / height * 2) * aspect;

        // TODO: Why is this the unview matrix?
        Mat4 unview_matrix = view_matrix.mul_mat(projection_matrix.inverse());
        Vec4 vec = {x, y, 0, 1};
        Vec4 ray_dir = unview_matrix.mul_vec(vec);

        return vec3_norm({ ray_dir.x, ray_dir.y, ray_dir.z });
    }

    public static float get_collision_distance(Render3DObject obj, Vec3 origin, Vec3 ray)
    {
        float x_size = obj.model.size.x / 2 * obj.scale.x;
        float y_size = obj.model.size.y / 2 * obj.scale.y;
        float z_size = obj.model.size.z / 2 * obj.scale.z;

        Vec3 rot = vec3_neg(obj.rotation);
        Vec3 xy_dir = rotate({}, rot, {0, 0, 1});
        Vec3 xz_dir = rotate({}, rot, {0, 1, 0});
        Vec3 yz_dir = rotate({}, rot, {1, 0, 0});

        Vec3 xy = vec3_mul_scalar(xy_dir, z_size);
        Vec3 xz = vec3_mul_scalar(xz_dir, y_size);
        Vec3 yz = vec3_mul_scalar(yz_dir, x_size);

        Vec3 xy_pos = vec3_plus (obj.position, xy);
        Vec3 xy_neg = vec3_minus(obj.position, xy);
        Vec3 xz_pos = vec3_plus (obj.position, xz);
        Vec3 xz_neg = vec3_minus(obj.position, xz);
        Vec3 yz_pos = vec3_plus (obj.position, yz);
        Vec3 yz_neg = vec3_minus(obj.position, yz);

        float dist = -1;

        dist = calc_dist(dist, collision_surface_distance(origin, ray, xy_pos, xy_dir, yz_dir, xz_dir, x_size, y_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, xy_neg, xy_dir, yz_dir, xz_dir, x_size, y_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, xz_pos, xz_dir, yz_dir, xy_dir, x_size, z_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, xz_neg, xz_dir, yz_dir, xy_dir, x_size, z_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, yz_pos, yz_dir, xy_dir, xz_dir, z_size, y_size));
        dist = calc_dist(dist, collision_surface_distance(origin, ray, yz_neg, yz_dir, xy_dir, xz_dir, z_size, y_size));
        return dist;
    }

    private static float calc_dist(float dist, float val)
    {
        if (val >= 0 && (dist < 0 || val < dist))
            dist = val;
        return dist;
    }

    private static float collision_surface_distance(Vec3 line_offset, Vec3 line_direction, Vec3 plane_offset, Vec3 plane_direction, Vec3 ortho1, Vec3 ortho2, float width, float height)
    {
        Vec3 point = collision(line_offset, line_direction, plane_offset, plane_direction);
        if (point.x.is_nan() || point.y.is_nan() || point.z.is_nan())
            return -1;

        Vec3 width_col = proj(point, ortho1, plane_offset);
        float width_dist = vec3_dist_sq(plane_offset, width_col);
        if (width * width < width_dist)
            return -1;

        float height_dist = vec3_dist_sq(point, width_col);
        if (height * height < height_dist)
            return -1;

        return vec3_dist_sq(point, line_offset);
    }

    public static Vec3 collision(Vec3 line_offset, Vec3 line_direction, Vec3 plane_offset, Vec3 plane_direction)
    {
        Vec3 n1 = line_offset;
        Vec3 n2 = vec3_plus(line_offset, line_direction);

        Vec3 nv = vec3_minus(plane_offset, n1);
        Vec3 dv = vec3_minus(          n2, n1);

        float n = vec3_dot(plane_direction, nv);
        float d = vec3_dot(plane_direction, dv);

        if (d == 0)
            return Vec3() { x = float.NAN, y = float.NAN, z = float.NAN };

        float u = n / d;

        Vec3 p = vec3_plus(n1, vec3_mul_scalar(dv, u));
        return p;
    }

    private static Vec3 proj(Vec3 plane_position, Vec3 normal, Vec3 point)
    {
        Vec3 p = plane_position;
        Vec3 n = vec3_norm(normal);
        Vec3 q = point;

        return vec3_minus(q, vec3_mul_scalar(n, vec3_dot(vec3_minus(q, p), n)));
    }

    public static Mat4 rotation_matrix(Vec3 axis, float angle)
    {
        axis = Calculations.vec3_norm(axis);
        float s = (float)Math.sin(angle);
        float c = (float)Math.cos(angle);
        float oc = 1 - c;

        float[] vals =
        {
            oc * axis.x * axis.x + c,          oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,  0,
            oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c,          oc * axis.y * axis.z - axis.x * s,  0,
            oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c,           0,
            0,                                 0,                                 0,                                  1
        };

        return new Mat4.with_array(vals);
    }

    public static Mat4 translation_matrix(Vec3 vec)
    {
        float[] vals =
        {
            1,     0,     0,     0,
            0,     1,     0,     0,
            0,     0,     1,     0,
            vec.x, vec.y, vec.z, 1
        };

        return new Mat4.with_array(vals);
    }

    public static Mat4 scale_matrix(Vec3 vec)
    {
        float[] vals =
        {
            vec.x, 0, 0, 0,
            0, vec.y, 0, 0,
            0, 0, vec.z, 0,
            0, 0,     0, 1
        };

        return new Mat4.with_array(vals);
    }

    public static Mat4 get_model_matrix(Vec3 position, Vec3 rotation, Vec3 scale)
    {
        float pi = (float)Math.PI;
        Mat4 x = rotation_matrix({1, 0, 0}, pi * rotation.x);
        Mat4 y = rotation_matrix({0, 1, 0}, pi * rotation.y);
        Mat4 z = rotation_matrix({0, 0, 1}, pi * rotation.z);
        Mat4 rotate = x.mul_mat(y).mul_mat(z);

        return scale_matrix(scale).mul_mat(rotate).mul_mat(translation_matrix(position));
    }
}
