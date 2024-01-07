when defined(nimscript):
  type Path * = string
  from std/os import parentDir
  export parentDir
else:
  from std/os import parentDir, splitFile
  from std/paths import Path, `/`, relativePath, absolutePath, changeFileExt
  from std/dirs import dirExists, createDir, walkDirRec
  from std/files import fileExists
  export dirExists, fileExists, createDir, relativePath, absolutePath, changeFileExt, walkDirRec
export Path

# @section Tools and Extensions
when not defined(nimscript):
  func `/` *(A,B :Path|string) :Path=  (when A is string: A.Path else: A)/(when B is string: B.Path else: A)
  func splitFile *(trg :Path) :tuple[dir,name :Path; ext :string]= (Path trg.string.splitFile.dir, Path trg.string.splitFile.name, trg.string.splitFile.ext) 
  proc parentDir *(trg :Path|string) :Path= Path os.parentDir( when trg is Path: trg.string else: trg)
  proc writeFile *(trg :Path; data :string) :void=  writeFile(when trg is Path: trg.string else: trg, data)
  proc readFile *(trg :Path) :string= readFile(when trg is Path: trg.string else: trg)
  from std/strutils import endsWith
  proc endsWith *(trg :Path; exts :openArray[string]) :bool=
    for ext in exts:
      if trg.string.endsWith(ext): return true
  proc endsWith *(trg :Path; ext :string) :bool=
    if trg.endsWith([ext]): return true
