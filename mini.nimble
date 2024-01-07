# Package
packageName   = "minissg"
version       = "0.0.0"
author        = "Ivan Mar (sOkam!)"
description   = "Mini SSG in Nim"
license       = "LGPL-3.0-or-later"
srcDir        = "src"
binDir        = "bin"
bin           = @["ssg"]
# Dependencies
requires "nim >= 2.0.2"
requires "https://github.com/juancarlospaco/nim-html-dsl#head"
