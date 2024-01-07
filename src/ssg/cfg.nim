import ./tool/paths
const thisDir :Path= when defined(nimscript): Path thisDir() else: paths.parentDir( currentSourcePath() )

# @section Folders Configuration
const rootDir  *:Path=  thisDir/".."/".."
const ssgDir   *:Path=  rootDir/"src"
const srcSub   *:Path=  "web".Path
const srcDir   *:Path=  rootDir/srcSub
const binDir   *:Path=  rootDir/"bin"
const trgSub   *:Path=  "public".Path
const trgDir   *:Path=  rootDir/trgSub
const cacheDir *:Path=  binDir/".cache/ssg"
const prefix   *{.strdefine.}= "nimssg  "
const nimBin   *{.strdefine.}=  string rootDir/".."/".."/"bin"/".nim"/"bin"/"nim"
const verbose  *{.booldefine.}= not (defined(release) or defined(danger)) or defined(debug)
const ValidExtensions * = [".htn"]
