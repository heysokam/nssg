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
const cssSub   *:Path=  "css".Path
const cssDir   *:Path=  srcDir/cssSub
const cacheDir *:Path=  binDir/".cache/nssg"
const pfx      * = (line: "μssg  ", tab: "     : ")
const nimBin   *{.strdefine.}=  string rootDir/".."/".."/"bin"/".nim"/"bin"/"nim"
const verbose  *{.booldefine.}= on  or defined(debug)
const ValidExtensions * = [".htn"]
const tailwindBin *:Path= Path"tailwindcss"
const tailwindCSS *:Path= Path"tailwind.css"
const tailwindCfg *:Path= Path"tailwind.config.js"
