when not defined(nimscript) : {.error: "\n  [minissg:Error] ssg/nims is a nimscript-only module.".}
when not defined(minissg)   : {.error: "\n  [minissg:Error] -d:minissg must be declared to use this module from nimscript".}

from std/os import changeFileExt, relativePath, absolutePath
from std/strutils import replace

template write *(pageMarkup :proc():string) {.dirty.}=
  # Figure out the target folder
  const rootDir{.strdefine.}= "."
  const srcRoot  :string= rootDir/cfg.srcSub
  const trgRoot  :string= rootDir/cfg.trgSub
  const thisFile :string= instantiationInfo(fullPaths=true).fileName
  const trgFile  :string= thisFile.replace(srcRoot, trgRoot.string).changeFileExt(".html")
  const trgDir   :string= thisDir().relativePath(srcRoot).absolutePath(trgRoot)
  if not trgDir.dirExists(): mkDir(trgDir)
  trgFile.writeFile(pageMarkup())

