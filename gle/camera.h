#pragma once
#include "glm.hpp"

struct camera
{
	enum projection_type
	{
		orthographic,
		perspective
	};

	glm::mat4 m_view;
	glm::mat4 m_proj;

	glm::vec3	m_pos, m_euler, m_forward, m_right, m_up;
	float		m_fov = 60.0f, m_aspect = 1.666f, m_near = 0.01f, m_far = 3000.0f;

	projection_type m_projection_type = projection_type::perspective;

	void update(glm::vec2 screen_dim);
};

struct debug_camera_controller
{
	void update(glm::vec2 screen_dim, camera& cam);

	float movement_speed = 50.0f;
	float deadzone = 0.003f;
	float rotational_speed = 45.0f;
	static constexpr float rotational_factor = 360.0f;
};