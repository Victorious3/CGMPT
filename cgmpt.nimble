# Package
version     = "0.1"
author      = "copy x Vi"
description = "City Gen Manager Project Thing"
license     = "MIT"

srcDir = "src"
binDir = "bin"
bin    = @["cgmpt"]

requires "nim >= 0.17.0"
requires "sdl2 >= 1.1"
requires "opengl >= 1.1.0"

# Tasks
import strutils

let executable = "cgmpt"
task run, "Runs the application":
  exec "./$1/$2.exe" % [binDir, executable]
