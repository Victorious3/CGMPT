# Small glew wrapper, add new functions here as needed
import macros, opengl

proc init*: GLenum {.importc.}
proc getErrorString*(error: GLenum): cstring {.importc.}

macro getVar*(extension: untyped): GLboolean =
  let cIdent = newStrLitNode("__imp___GLEW_" & $extension)
  let cImportPragma = newNimNode(nnkPragma).add(newNimNode(nnkExprColonExpr).add(newIdentNode("importc")).add(cIdent))
  let cVarIdent = newNimNode(nnkPragmaExpr).add(ident("glewVar"), cImportPragma)

  result = quote do:
    block:
      var `cVarIdent`: GLboolean
      glewVar