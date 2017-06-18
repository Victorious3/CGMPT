# Package
version     = "0.1"
author      = "copy x Vi"
description = "City Gen Manager Project Thing"
license     = "MIT"

srcDir  = "src"
binDir  = "bin"

requires "nim >= 0.17.0"
requires "sdl2 >= 1.1"

let executable = "cgmpt.exe"
let main = "cgmpt.nim"

import strutils

task build_exe, "Compiles the application":
    exec "nim c --nimcache:$1/nimcache -o:$1/$2 $3/$4" % [binDir, executable, srcDir, main]