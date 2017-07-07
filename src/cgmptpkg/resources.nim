# AUTO GENERATED FILE - DO NOT EDIT
import glm
import resource/resource

#[
resources:
  "shader/":
    "core.prog":
      "../frag/core.vert"
      "../vert/core.frag"
    "frag/core.vert":
      ins:
        vertex: ivec2
        texture: vec2
        color: vec4
      uniforms:
        projection: array[mat4, 5]
        modelview: mat4
    "vert/core.frag":
      uniforms:
        use_texture: bool
]#

