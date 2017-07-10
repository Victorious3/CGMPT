import os, parseopt2, tables, strutils, yaml, streams, typetraits, ospaths
import sdl2 as sdl, opengl, glm

import
  cgmptpkg/config,
  cgmptpkg/render/shader,
  cgmptpkg/glew

# Might want to move these elsewhere, could be useful in other context
proc newYamlMap(fields = newTable[YamlNode, YamlNode](), tag = "?"): YamlNode = YamlNode(kind: yMapping, fields: newTable[YamlNode, YamlNode](), tag: tag)
proc newYamlSeq(elems = seq[YamlNode](@[]), tag = "?"): YamlNode = YamlNode(kind: ySequence, elems: elems, tag: tag)
proc newYamlScalar(content: string, tag = "?"): YamlNode = YamlNode(kind: yScalar, content: content, tag: tag)
converter toYamlScalar(content: string): YamlNode = newYamlScalar(content)

type AssetProc = proc(file: FileStream): YamlNode

proc readProg(file: FileStream): YamlNode =
  let prog = loadDom(file).root
  assert prog.kind == ySequence, "Program file needs to be a list of shader references"
  prog

#TODO Move this and create reverse mapping
proc mapType(glType: GLenum, arraySize: GLint): string =
  #echo int(glType), " ", arraySize

  var tpe: string
  case glType
  of cGL_FLOAT: tpe = float.name
  of GL_FLOAT_VEC2: tpe = Vec2.name
  of GL_FLOAT_VEC3: tpe = Vec3.name
  of GL_FLOAT_VEC4: tpe = Vec4.name
  of cGL_DOUBLE: tpe = float64.name
  of GL_DOUBLE_VEC2: tpe = Vec2d.name
  of GL_DOUBLE_VEC3: tpe = Vec3d.name
  of GL_DOUBLE_VEC4: tpe = Vec4d.name
  of cGL_INT: tpe = int.name
  of GL_INT_VEC2: tpe = Vec2i.name
  of GL_INT_VEC3: tpe = Vec3i.name
  of GL_INT_VEC4: tpe = Vec4i.name
  of GL_UNSIGNED_INT: tpe = uint.name
  of GL_UNSIGNED_INT_VEC2: tpe = Vec2ui.name
  of GL_UNSIGNED_INT_VEC3: tpe = Vec3ui.name
  of GL_UNSIGNED_INT_VEC4: tpe = Vec4ui.name
  of GL_BOOL: tpe = bool.name
  of GL_BOOL_VEC2: tpe = Vec2b.name
  of GL_BOOL_VEC3: tpe = Vec3b.name
  of GL_BOOL_VEC4: tpe = Vec4b.name
  of GL_FLOAT_MAT2: tpe = Mat2.name
  of GL_FLOAT_MAT3: tpe = Mat3.name
  of GL_FLOAT_MAT4: tpe = Mat4.name
  of GL_FLOAT_MAT2x3: tpe = Mat2x3.name
  of GL_FLOAT_MAT2x4: tpe = Mat2x4.name
  of GL_FLOAT_MAT3x2: tpe = Mat3x2.name
  of GL_FLOAT_MAT3x4: tpe = Mat3x4.name
  of GL_FLOAT_MAT4x2: tpe = Mat4x2.name
  of GL_FLOAT_MAT4x3: tpe = Mat4x3.name
  of GL_DOUBLE_MAT2: tpe = Mat2d.name
  of GL_DOUBLE_MAT3: tpe = Mat3d.name
  of GL_DOUBLE_MAT4: tpe = Mat4d.name
  of GL_DOUBLE_MAT2x3: tpe = Mat2x3d.name
  of GL_DOUBLE_MAT2x4: tpe = Mat2x4d.name
  of GL_DOUBLE_MAT3x2: tpe = Mat3x2d.name
  of GL_DOUBLE_MAT3x4: tpe = Mat3x4d.name
  of GL_DOUBLE_MAT4x2: tpe = Mat4x2d.name
  of GL_DOUBLE_MAT4x3: tpe = Mat4x3d.name
# TODO Sampler types map to textures, skipped by now
  of GL_SAMPLER_1D: tpe = "sampler1D"
  of GL_SAMPLER_2D: tpe = "sampler2D"
  of GL_SAMPLER_3D: tpe = "sampler3D"
  of GL_SAMPLER_CUBE: tpe = "samplerCube"
  of GL_SAMPLER_1D_SHADOW: tpe = "sampler1DShadow"
  of GL_SAMPLER_2D_SHADOW: tpe = "sampler2DShadow"
  of GL_SAMPLER_1D_ARRAY: tpe = "sampler1DArray"
  of GL_SAMPLER_2D_ARRAY: tpe = "sampler2DArray"
  of GL_SAMPLER_1D_ARRAY_SHADOW: tpe = "sampler1DArrayShadow"
  of GL_SAMPLER_2D_ARRAY_SHADOW: tpe = "sampler2DArrayShadow"
  of GL_SAMPLER_2D_MULTISAMPLE: tpe = "sampler2DMS"
  of GL_SAMPLER_2D_MULTISAMPLE_ARRAY: tpe = "sampler2DMSArray"
  of GL_SAMPLER_CUBE_SHADOW: tpe = "samplerCubeShadow"
  of GL_SAMPLER_BUFFER: tpe = "samplerBuffer"
  of GL_SAMPLER_2D_RECT: tpe = "sampler2DRect"
  of GL_SAMPLER_2D_RECT_SHADOW: tpe = "sampler2DRectShadow"
  of GL_INT_SAMPLER_1D: tpe = "isampler1D"
  of GL_INT_SAMPLER_2D: tpe = "isampler2D"
  of GL_INT_SAMPLER_3D: tpe = "isampler3D"
  of GL_INT_SAMPLER_CUBE: tpe = "isamplerCube"
  of GL_INT_SAMPLER_1D_ARRAY: tpe = "isampler1DArray"
  of GL_INT_SAMPLER_2D_ARRAY: tpe = "isampler2DArray"
  of GL_INT_SAMPLER_2D_MULTISAMPLE: tpe = "isampler2DMS"
  of GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY: tpe = "isampler2DMSArray"
  of GL_INT_SAMPLER_BUFFER: tpe = "isamplerBuffer"
  of GL_INT_SAMPLER_2D_RECT: tpe = "isampler2DRect"
  of GL_UNSIGNED_INT_SAMPLER_1D: tpe = "usampler1D"
  of GL_UNSIGNED_INT_SAMPLER_2D: tpe = "usampler2D"
  of GL_UNSIGNED_INT_SAMPLER_3D: tpe = "usampler3D"
  of GL_UNSIGNED_INT_SAMPLER_CUBE: tpe = "usamplerCube"
  of GL_UNSIGNED_INT_SAMPLER_1D_ARRAY: tpe = "usampler1DArray"
  of GL_UNSIGNED_INT_SAMPLER_2D_ARRAY: tpe = "usampler2DArray"
  of GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE: tpe = "usampler2DMS"
  of GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY: tpe = "usampler2DMSArray"
  of GL_UNSIGNED_INT_SAMPLER_BUFFER: tpe = "usamplerBuffer"
  of GL_UNSIGNED_INT_SAMPLER_2D_RECT: tpe = "usampler2DRec"
  else: raise newException(ValueError, "No known mapping for type " & $int(glType))
  #echo tpe

  if arraySize > 1:
    return "array[$#, $#]" % [$arraySize, tpe]
  else:
    return tpe

## Query the names and types for the specified interface
iterator interfaceProperties(program: GLuint, programInterface: GLenum): tuple[name: string, typeStr: string] =
  assert glIsProgram(program), "Program parameter must be an opengl program"
  var activeResources: GLint
  program.glGetProgramInterfaceiv(programInterface, GL_ACTIVE_RESOURCES, addr activeResources) # Number of active resources
  #echo "Active resources: ", activeResources
  
  for i in 0..<GLuint(activeResources):
    var propertyBuffer: array[3, GLint]
    var property = [GL_TYPE, GL_ARRAY_SIZE, GL_NAME_LENGTH]
    program.glGetProgramResourceiv(programInterface, i, GLsizei(3), addr property[0], GLsizei(3), nil, addr propertyBuffer[0])
    var name = newString(propertyBuffer[2])
    program.glGetProgramResourceName(programInterface, i, propertyBuffer[2], nil, name)
    
    let typeStr = mapType(GLenum(propertyBuffer[0]), propertyBuffer[1])
    yield (name[0..^2], typeStr) # We dont include the trailing \0


proc readShader(tpe: ShaderType): auto =
  proc impl(file: FileStream): YamlNode =
    let shader = newShader(tpe)
    shader.source(file.readAll())
    shader.compile()
    let program = newProgram()
    program.attach(shader)
    try:
      program.link()
    except ShaderException: discard # Successful linking is not required

    proc readProperties(programInterface: GLenum): YamlNode =
      result = newYamlMap()
      for name, tpe in interfaceProperties(program, programInterface):
        result[name] = tpe

    result = newYamlMap()
    result["in"]      = readProperties(GL_PROGRAM_INPUT)
    result["out"]     = readProperties(GL_PROGRAM_OUTPUT)
    result["uniform"] = readProperties(GL_UNIFORM) #TODO uniform blocks?
  impl

let FileTypes = {
  ".prog": AssetProc(readProg), # I didnt want to wrap all these. Bug report?
  ".vert": AssetProc(readShader(ShaderType.Vertex)),
  ".frag": AssetProc(readShader(ShaderType.Fragment)),
  ".geom": AssetProc(readShader(ShaderType.Geometry))
}.toTable

var deamon = false

# Command line arguments
for kind, key, val in getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "d", "deamon":
      deamon = true
  else: discard

if not dirExists ASSET_FOLDER:
  raise newException(IOError, "Resorce folder " & ASSET_FOLDER & " doesnt exist!")

proc traverse(dir: string, assets: YamlNode) =
  for kind, path in walkDir dir:
    if kind == pcDir:
      let asset = newYamlMap()
      traverse(path, asset)
      assets[path.split(DirSep)[^1] & DirSep] = asset
    elif kind == pcFile:
      let ext = splitFile(path).ext
      
      #if not extFilter(ext): continue # This has been postponed to the later stage
      if not FileTypes.hasKey(ext):
        echo "Skipping ", path, ", unknown filetype"
        continue
      
      let resProc = FileTypes[ext]
      let fs = newFileStream(path)
      let asset = resProc(fs)
      fs.close()
      assets[path.split(DirSep)[^1]] = asset

# Load opengl, quick setup with minimal error checking
sdl.init(0)
let window = sdl.createWindow("", 0, 0, 1, 1, SDL_WINDOW_HIDDEN or SDL_WINDOW_OPENGL)

# OpenGL flags
discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4) #4.2 required for extended api
discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2)
discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)

let context = window.glCreateContext()
discard glewInit()
checkGLerror()

let assets = newYamlMap()
traverse(ASSET_FOLDER, assets)
var _, assetStream = assets.initYamlDoc().serialize(serializationTagLibrary)
writeFile(ASSET_FILE, present(assetStream, serializationTagLibrary))

# Cleanup
sdl.destroy(window)
sdl.glDeleteContext(context)
sdl.quit()