import os, parseopt2, macros, tables, strutils
import
  cgmptpkg/config,
  cgmptpkg/render/shader

type Resource = ref object
  case kind: PathComponent
  of pcDir:
    dir: seq[Resource]
  else:
    ext: string
    ast: NimNode
  path: string

# Tree structure of finished resource entries
var resources = Resource(kind: pcDir)

type ResourceProc = proc(file: string): NimNode

proc readProg(file: string): NimNode = 
  discard

proc readShader(tpe: ShaderType): auto =
  proc impl(file: string): NimNode = 
    discard
  impl

const FileTypes = {
  "prog": readProg,
  "vert": readShader(ShaderType.Vertex),
  "frag": readShader(ShaderType.Fragment),
  "geom": readShader(ShaderType.Geometry)
}.toTable

var deamon = false
let skipExt = ["prog"] # Extensions that have to be processed seperately, after all others (order not guaranteed!)

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

proc traverse(dir: string, resources: Resource, extFilter: proc(ext: string): bool) = 
  for kind, path in walkDir dir:
    if kind == pcDir:
      let res = Resource(kind: pcDir, path: path)
      traverse(path, res, extFilter)
      resources.dir.add(res)
    elif kind == pcFile:
      let ext = path.split(".")[1]

      if not extFilter(ext): continue
      if not FileTypes.hasKey(ext):
        echo "Skipping ", path, ", unknown filetype"
        continue
      
      let resProc = FileTypes[ext]
      let res = Resource(kind: pcFile, path: path, ext: ext, ast: resProc(path))
      resources.dir.add(res)

#traverse(RESOURCE_FOLDER, resources, proc(e: string): bool = e notin skipExt)
#traverse(RESOURCE_FOLDER, resources, proc(e: string): bool = e in skipExt)
