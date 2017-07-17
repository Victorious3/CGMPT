# AUTO GENERATED FILE - DO NOT EDIT
import glm, yaml
import resource/resource

proc readProgram(tree: YamlNode, data: YamlNode): NimNode =
  discard

proc readShader(tree: YamlNode, data: YamlNode): NimNode =
  discard

macro readAssets: typed =
  discard

readAssets

#[
shader/:
  core.prog:
    - ../frag/core.vert
    - ../vert/core.frag
  frag/core.vert:
    in:
      vertex: ivec2
      texture: vec2
      color: vec4
    uniform:
      projection: array[mat4, 5]
      modelview: mat4
  vert/core.frag:
    uniform:
      use_texture: bool
]#

