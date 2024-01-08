from std/strutils import `%`, join
import ./cfg as ssg
import ./tool/paths
import ./tool/dl
import ./tool/files
import ./tool/logger
import ./tool/shell

const DefaultConfigTempl = """
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["$1/**/*.{html,js}"],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
"""
const DefaultCSSTempl = """
@tailwind base;        /* Tailwind’s base style. Basically Normalize.css plus some additional styling.  */
@tailwind components;  /* Component classes registered by the plugins found in tailwind.config.js file. */
@tailwind utilities;   /* Utility classes provided by Tailwind CSS. Generated based on the config file. */
"""

proc runWith (bin :Path; args :varargs[string, `$`]):void {.inline.}=  sh bin.string, args.join(" ")
type Opts = object
  file         : Path = ssg.srcDir/ssg.tailwindCfg
  minify       : bool = true
  watch        : bool = false
  autoprefixer : bool = false
proc buildWith (bin,src,trg :Path; opt :Opts) :void=
  if not trg.parentDir.dirExists: trg.parentDir.createDir
  runWith bin,
    "-i", src.string, "-o", trg.string,
    if opt.minify            : "--minify"            else: "",
    if opt.watch             : "--watch"             else: "",
    if opt.file.string != "" : "-c "&opt.file.string else: "",
    if not opt.autoprefixer  : "--no-autoprefixer"   else: ""

type TailwindError = object of CatchableError
template err(msg:string)= raise newException(TailwindError,msg)

template URL :string=
  "https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-$1-$2" % [
    hostOS,
    when hostCPU == "amd64": "x64" else: hostCPU
    ] # << result = ...


template shouldInit (bin,cfg,css :Path; force:bool):bool= force or (not bin.fileExists or not bin.isExec or not cfg.fileExists or not css.fileExists)
proc init *(
    cssDir : Path = ssg.cssDir;
    outDir : Path = ssg.binDir;
    srcDir : Path = ssg.srcDir;
    cfgDir : Path = ssg.srcDir;
    trgDir : Path = ssg.trgDir;
    force  : bool = off
  ) :void=
  let bin :Path= outDir/ssg.tailwindBin
  let css :Path= cssDir/ssg.tailwindCSS
  let trg :Path= outDir/ssg.tailwindCSS
  let cfg :Path= cfgDir/ssg.tailwindCfg
  if force: dbg "Force-initializing Tailwind..."
  if force and bin.fileExists:
    dbg "Removing Tailwind binary at "&bin
    removeFile(bin)
  if not shouldInit(bin,cfg,css, force):
    dbg "Conditions for initializing Tailwind were not matched. Skipping."
    return
  info "Starting Tailwind initialization..."
  # @section Tailwind Download
  if not bin.fileExists:
    try    : dl.file( URL, bin ); dbg "Finished downloading Tailwind."
    except : err "Failed to download Tailwind."
  if not bin.isExec:
    try    : files.setExec(bin); dbg "Marked the Tailwind binary as executable."
    except : err "Failed to flag the Tailwind binary as executable."
  # @section Tailwind Config Generation
  if not cfg.fileExists:
    try    : cfg.writeFile( DefaultConfigTempl % [trgDir.relativePath(srcDir).string] ); dbg "Initialized Tailwind configuration."
    except : err "Failed to Initialize Tailwind configuration."
  # @section Tailwind CSS file setup
  if not cssDir.dirExists or not css.fileExists:
    try    : cssDir.createDir(); dbg "Created the default CSS folder."
    except : err "Failed to create the default CSS folder."
    try    : css.writeFile( DefaultCSSTempl ); dbg "Initialized Tailwind CSS default input file."
    except : err "Failed to Initialize Tailwind CSS default input file."
  info "Done initializing Tailwind."

proc build *(
    cssDir : Path = ssg.cssDir;
    trgDir : Path = ssg.trgDir;
    srcDir : Path = ssg.srcDir;
    cfgDir : Path = ssg.srcDir;
    opts   : Opts = Opts();
  ) :void=
  info "Building Tailwind stylesheets..."
  let bin :Path= binDir/ssg.tailwindBin
  let css :Path= cssDir/ssg.tailwindCSS
  let trg :Path= trgDir/ssg.cssSub/ssg.tailwindCSS
  try    : tailwind.buildWith bin, css, trg, opts
  except : err "Failed to build Tailwind stylesheets."
  info "Finished building Tailwind stylesheets."

