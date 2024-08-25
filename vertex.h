#pragma once
#include <vector>
#include "GL/glew.h"

using gl_handle = unsigned int;

struct VAO
{
	gl_handle m_vao_id;

	void	use();
};

class vao_builder
{
public:

	vao_builder() = default;

	void begin();

	template<typename _Ty>
	void add_vertex_buffer(_Ty* data, uint32_t count)
	{		
		gl_handle vbo;
		glGenBuffers(1, &vbo);

		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, sizeof(_Ty) * count, data, GL_STATIC_DRAW);
		m_vbos.push_back(vbo);
	}

	template<typename _Ty>
	void add_vertex_buffer(std::vector<_Ty> data)
	{
		add_vertex_buffer<_Ty>(data.data(), data.size());
	}

	void add_index_buffer(uint32_t* data, uint32_t data_count);
	void add_index_buffer(std::vector<uint32_t> data);

	void add_vertex_attribute(uint32_t binding, uint32_t total_vertex_size, uint32_t num_elements, uint32_t element_size = 4, GLenum primitive_type = GL_FLOAT);

	VAO	 build();
private:

	gl_handle					m_vao;
	gl_handle					m_ibo;
	std::vector<gl_handle>		m_vbos;
	uint32_t					m_offset_counter;
};
