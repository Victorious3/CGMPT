import os, parseopt2, macros, tables, strutils
import 
  cgmptpkg/config,
  cgmptpkg/render/shader

proc readProg(file: string): NimNode = discard
proc readShader(tpe: ShaderType): auto =
  proc impl(file: string): NimNode = discard
  impl

let FileTypes = {
  "prog": readProg,
  "vert": readShader(ShaderType.Vertex),
  "frag": readShader(ShaderType.Fragment),
  "geom": readShader(ShaderType.Geometry),
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

proc traverse(dir: string, extFilter: proc(ext: string): bool) = 
  for kind, path in walkDir dir:
    if kind == pcDir: traverse(path, extFilter)
    elif kind == pcFile:
      let ext = path.split(".")[1]
      if not extFilter(ext): continue
      # FIXME


traverse(RESOURCE_FOLDER, proc(e: string): bool = e notin skipExt)
traverse(RESOURCE_FOLDER, proc(e: string): bool = e in skipExt)