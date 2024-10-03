#version 450

layout(location = 0) in vec2 aUV;
out vec4 FragColor;

#define TSQRT2 2.828427
#define SQRT2 1.414213
#define ISQRT2 0.707106
#define DIST_FACTOR 1.1f /* Distance is multiplied by this when calculating attenuation. */
#define CONSTANT 1
#define LINEAR 0 /* Looks meh when using gamma correction. */
#define QUADRATIC 1


struct AABB
{
	vec3 min;
	vec3 max;
};


uniform sampler2D   u_position_map;
uniform sampler2D   u_normal_map;
uniform sampler3D   u_voxel_map; // x = metallic, y = roughness, z = AO
uniform AABB		u_aabb;
uniform vec3		u_voxel_resolution;
uniform vec3		u_cam_position;
uniform float		u_max_trace_distance;
#define VOXEL_SIZE (1/128.0)


vec3 orthogonal(vec3 u) {
	u = normalize(u);
	vec3 v = vec3(0.99146, 0.11664, 0.05832); // Pick any normalized vector.
	return abs(dot(u, v)) > 0.99999f ? cross(u, vec3(0, 1, 0)) : cross(u, v);
}

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

bool is_in_aabb(vec3 pos)
{
	if (pos.x < u_aabb.min.x) { return false; }
	if (pos.y < u_aabb.min.y) { return false; }
	if (pos.z < u_aabb.min.z) { return false; }
	if (pos.x > u_aabb.max.x) { return false; }
	if (pos.y > u_aabb.max.y) { return false; }
	if (pos.z > u_aabb.max.z) { return false; }
	return true;
}


vec3 get_texel_from_pos(vec3 position, vec3 unit)
{
	vec3 clip_pos = position - u_aabb.min;
	float x = clip_pos.x / unit.x;
	float y = clip_pos.y / unit.y;
	float z = clip_pos.z / unit.z;
	return vec3(x/ u_voxel_resolution.x, y / u_voxel_resolution.y, z / u_voxel_resolution.z);
}

ivec3 get_absolute_texel_from_pos(vec3 position, vec3 resolution)
{
	vec3 aabb_dim = u_aabb.max - u_aabb.min;
	vec3 unit = vec3((aabb_dim.x / resolution.x), (aabb_dim.y / resolution.y) , (aabb_dim.z / resolution.z));

	/// <summary>
	/// 0,0,0 is aabb.min
	/// </summary>
	vec3 new_pos = position - u_aabb.min;
	int x = int(new_pos.x / unit.x) ;
	int y = int(new_pos.y / unit.y) ;
	int z = int(new_pos.z / unit.z) ;

	return ivec3(x, y, z);

}


vec4 get_voxel_colour(vec3 position, vec3 unit, float lod)
{
	return textureLod(u_voxel_map, get_texel_from_pos(position, unit), lod);
}

vec3 trace_ray(vec3 from, vec3 dir, vec3 unit)
{
	vec4 accum = vec4(0.0);
	vec3 pos = from;
	const int MAX_STEPS = 512;
	int steps = 0;
	const int MAX_LOD = 5;
	int lod = 5;
	while (accum.w < 0.99 && is_in_aabb(pos) && steps < MAX_STEPS)
	{
		pos += unit * (lod + 1) * dir;
		vec4 result = get_voxel_colour(pos, unit, lod);
		if(result.w > 0.2 && lod > 0)
		{
			lod -= 1;
		}
		else if(result.w < 0.1)
		{
			lod += 1;
		}
		if(lod == 0)
		{
			accum += result;
		}
		steps += 1;
	}
	return accum.xyz;
}

float remap(float source, float sourceFrom, float sourceTo, float targetFrom, float targetTo)
{
	return targetFrom + (source-sourceFrom)*(targetTo-targetFrom)/(sourceTo-sourceFrom);
}

vec3 trace_cone(vec3 from, vec3 dir, vec3 unit)
{
	const int MAX_STEPS = int(u_voxel_resolution.x); // should probs be the longest axis of minimum mip dimension
	const int MAX_LOD	= 5;
	vec4 accum = vec4(0.0);
	vec3 pos = from;
	int steps = 0;
	float lod = 1.0;
	pos += dir * (length(unit));
	float cone_distance = distance(from, pos);

	while (accum.w < 1.0 && is_in_aabb(pos) && cone_distance < u_max_trace_distance && steps < MAX_STEPS)
	{
		vec4 result = get_voxel_colour(pos, unit, lod);
		cone_distance = distance(from, pos);
		accum += result * (1.0 - (cone_distance / u_max_trace_distance));
		lod = round(remap(cone_distance * 1.25, 0.0, u_max_trace_distance, 0.0, MAX_LOD));
		steps += 1;
		float factor = 1.0 - result.w;
		pos += dir * (unit * factor);
	}

	return accum.xyz;
}

const int 	DIFFUSE_CONE_COUNT_16 		= 16;
const float DIFFUSE_CONE_APERTURE_16 	= 0.872665;
const vec3 DIFFUSE_CONE_DIRECTIONS_16[16] = {
    vec3( 0.57735,   0.57735,   0.57735  ),
    vec3( 0.57735,  -0.57735,  -0.57735  ),
    vec3(-0.57735,   0.57735,  -0.57735  ),
    vec3(-0.57735,  -0.57735,   0.57735  ),
    vec3(-0.903007, -0.182696, -0.388844 ),
    vec3(-0.903007,  0.182696,  0.388844 ),
    vec3( 0.903007, -0.182696,  0.388844 ),
    vec3( 0.903007,  0.182696, -0.388844 ),
    vec3(-0.388844, -0.903007, -0.182696 ),
    vec3( 0.388844, -0.903007,  0.182696 ),
    vec3( 0.388844,  0.903007, -0.182696 ),
    vec3(-0.388844,  0.903007,  0.182696 ),
    vec3(-0.182696, -0.388844, -0.903007 ),
    vec3( 0.182696,  0.388844, -0.903007 ),
    vec3(-0.182696,  0.388844,  0.903007 ),
    vec3( 0.182696, -0.388844,  0.903007 )
};

vec3 trace_cones_v3(vec3 from, vec3 dir, vec3 unit)
{

	vec3 acc = vec3(0);

	for(int i = 0; i < DIFFUSE_CONE_COUNT_16; i++)
	{
	    float sDotN = max(dot(dir, DIFFUSE_CONE_DIRECTIONS_16[i]), 0.0);
		if(sDotN <= 0.001)
		//if(sDotN < 0.0)
		{
			continue;
		}
		vec3 final_dir = mix(dir, DIFFUSE_CONE_DIRECTIONS_16[i], 0.5);
		acc += trace_cone(from, final_dir, unit) * sDotN;
	}

	return acc / 2.0 ; // num traces to get a more usable output for now;
}



void main()
{
	vec3 aabb_dim = u_aabb.max - u_aabb.min;
	vec3 unit = vec3((aabb_dim.x / u_voxel_resolution.x), (aabb_dim.y / u_voxel_resolution.y), (aabb_dim.z / u_voxel_resolution.z));
	vec3 diffuse = vec3(1.0);
	vec3 position = texture(u_position_map, aUV).xyz;
	vec3 normal = texture(u_normal_map, aUV).xyz;
	vec3 normalized_n = normalize(normal);
	vec3 v_diffuse = trace_cones_v3(position, normalized_n, unit);
	vec3 view_dir = position - u_cam_position;
	vec3 v_spec = trace_ray(position, reflect(view_dir, normalized_n), unit);
	FragColor = vec4(mix(v_diffuse, v_spec, 0.1), 1.0);
}