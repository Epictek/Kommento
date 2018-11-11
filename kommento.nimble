# Package
version     = "0.0.1"
author      = "Kieran Coldron"
description = "Kommento"
license     = "GPL2"

# Deps
requires "nim >= 0.18.0"
requires "karax"
requires "nim-markdown"
requires "jester"

task backend, "Compiles and runs the backend":
    exec "nimble c backend/kommento.nim"
    exec "./backend/kommento"

task runbackend, "Runs the backend":
    exec "./backend/kommento"


task frontend, "Builds the JS frontend":
    exec "nimble js -d:release frontend/kommento.nim"
    mkDir "public/js"
    cpFile "frontend/nimcache/kommento.js", "public/js/kommento.js"


task blankdb, "Creates a blank DB":
    exec "nimble c backend/setup"
    exec "./backend/setup"

