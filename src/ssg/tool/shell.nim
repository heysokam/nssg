from std/os import execShellCmd
from std/strutils import join
from std/strformat import `&`
import ../cfg
import ./paths
import ./logger
proc sh *(cmd :string; args :varargs[string, `$`]) :void=  discard os.execShellCmd(cmd & " " & args.join(" "))
proc run *(trg :Path) :void=
  if trg.splitFile.ext notin ValidExtensions: return
  dbg "Compiling file: ", trg.string
  if not cacheDir.dirExists(): createDir(cacheDir)
  sh cfg.nimBin, "e -d:minissg --hints:off", &"-d:rootDir:{string rootDir} --path:{string ssgDir}", trg.string
