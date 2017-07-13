#version 330 core

in vec3 vertex;
in vec2 texture;
in vec4 color;

out vec2 frag_texture;
out vec4 frag_color;

uniform mat4 projection;
uniform mat4 modelview = mat4(1.0);

void main() {
	gl_Position = projection * modelview * vec4(vertex, 1.0);

	frag_texture = texture;
	frag_color = color;
}