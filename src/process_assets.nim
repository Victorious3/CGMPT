import os, parseopt2, tables, strutils, yaml, streams
import sdl2 as sdl, opengl

import
  cgmptpkg/config,
  cgmptpkg/render/shader,
  cgmptpkg/glew

type Asset = ref object
  case kind: PathComponent
  of pcDir:
    dir: seq[Asset]
  else:
    ext: string
    data: YamlNode
  path: string

# Tree structure of finished resource entries
var assets = Asset(kind: pcDir)

type AssetProc = proc(file: FileStream): YamlNode

proc readProg(file: FileStream): YamlNode =
  let prog = loadDom(file).root
  assert prog.kind == ySequence, "Program file needs to be a list of shader references"
  return prog

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
    
    result = newYamlNode([])
    #if tpe == ShaderType.Fragment: # Attributes
  impl

let FileTypes = {
  "prog": AssetProc(readProg), # I didnt want to wrap all these. Bug report?
  "vert": AssetProc(readShader(ShaderType.Vertex)),
  "frag": AssetProc(readShader(ShaderType.Fragment)),
  "geom": AssetProc(readShader(ShaderType.Geometry))
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

if not dirExists RESOURCE_FOLDER:
  raise newException(IOError, "Resorce folder " & RESOURCE_FOLDER & " doesnt exist!")

proc traverse(dir: string, assets: Asset) =
  for kind, path in walkDir dir:
    if kind == pcDir:
      let res = Asset(
        kind: pcDir, 
        path: path
      )   
      traverse(path, res)
      assets.dir.add(res)
    elif kind == pcFile:
      let ext = path.split(".")[1]
      
      #if not extFilter(ext): continue # This has been postponed to the later stage
      if not FileTypes.hasKey(ext):
        echo "Skipping ", path, ", unknown filetype"
        continue
      
      let resProc = FileTypes[ext]
      let fs = newFileStream(path)
      let res = Asset(
        kind: pcFile, 
        path: path, 
        ext: ext, 
        data: resProc(fs)
      )
      fs.close()
      assets.dir.add(res)

# Load opengl, quick setup without error checking
sdl.init(0)
let window = sdl.createWindow("", 0, 0, 1, 1, SDL_WINDOW_HIDDEN)
# OpenGL flags
discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, int32(config.GL_VERSION.major))
discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, int32(config.GL_VERSION.minor))
discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)

let context = window.glCreateContext()
discard glewInit()

traverse(RESOURCE_FOLDER, assets)

# Cleanup
sdl.destroy(window)
sdl.glDeleteContext(context)
sdl.quit()