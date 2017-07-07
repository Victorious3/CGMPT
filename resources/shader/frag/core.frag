#version 330 core

uniform sampler2D tex;

uniform bool use_texture = true;

in vec2 frag_texture;
in vec4 frag_color;

out vec4 color;

void main() {
	if (use_texture) {
		color = frag_color * texture(tex, frag_texture);
	} else {
		color = frag_color;
	}
} 