import
  strutils,
  src/cgmptpkg/config
const name = "cgmpt"

# Package
version     = config.VERSION
author      = "copy x Vi"
description = "City Gen Manager Project Thing"
license     = "MIT"

# Dependencies
requires "nim >= 0.17.0"
requires "sdl2 >= 1.1"
requires "opengl >= 1.1.0"
requires "glm >= 0.1.1"

# Build options
srcDir = "src"
binDir = "bin"
skipFiles = @["process_assets.nim"]
bin    = @[name, "process_assets"]

# Tasks
task run, "Runs the application":
  exec "./$#/$#" % [binDir, name]
