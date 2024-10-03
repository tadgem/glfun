#include "tech/lighting.h"
#include <sstream>
#include "framebuffer.h"
#include "shape.h"
#include "texture.h"
#include "camera.h"
#include "utils.h"
void tech::lighting::dispatch_light_pass(shader& lighting_shader, framebuffer& lighting_buffer, framebuffer& gbuffer, framebuffer& dir_light_shadow_buffer, camera& cam, std::vector<point_light>& point_lights, dir_light& sun)
{
    lighting_buffer.bind();
    lighting_shader.use();
    shapes::s_screen_quad.use();

    lighting_shader.set_int("u_diffuse_map", 0);
    lighting_shader.set_int("u_position_map", 1);
    lighting_shader.set_int("u_normal_map", 2);
    lighting_shader.set_int("u_pbr_map", 3);
    lighting_shader.set_int("u_dir_light_shadow_map", 4);

    lighting_shader.set_vec3("u_cam_pos", cam.m_pos);

    lighting_shader.set_vec3("u_dir_light.direction", utils::get_forward(sun.direction));
    lighting_shader.set_vec3("u_dir_light.colour", sun.colour);
    lighting_shader.set_mat4("u_dir_light.light_space_matrix", sun.light_space_matrix);
    lighting_shader.set_float("u_dir_light.intensity", sun.intensity);

    int num_point_lights = std::min((int)point_lights.size(), 16);

    for (int i = 0; i < num_point_lights; i++)
    {
        std::stringstream pos_name;
        pos_name << "u_point_lights[" << i << "].position";
        std::stringstream col_name;
        col_name << "u_point_lights[" << i << "].colour";
        std::stringstream rad_name;
        rad_name << "u_point_lights[" << i << "].radius";
        std::stringstream int_name;
        int_name << "u_point_lights[" << i << "].intensity";

        lighting_shader.set_vec3(pos_name.str(), point_lights[i].position);
        lighting_shader.set_vec3(col_name.str(), point_lights[i].colour);
        lighting_shader.set_float(rad_name.str(), point_lights[i].radius);
        lighting_shader.set_float(int_name.str(), point_lights[i].intensity);
    }

    texture::bind_sampler_handle(gbuffer.m_colour_attachments[0], GL_TEXTURE0);
    texture::bind_sampler_handle(gbuffer.m_colour_attachments[1], GL_TEXTURE1);
    texture::bind_sampler_handle(gbuffer.m_colour_attachments[2], GL_TEXTURE2);
    texture::bind_sampler_handle(gbuffer.m_colour_attachments[3], GL_TEXTURE3);
    texture::bind_sampler_handle(dir_light_shadow_buffer.m_depth_attachment, GL_TEXTURE4);

    // bind all maps
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    lighting_buffer.unbind();

}
