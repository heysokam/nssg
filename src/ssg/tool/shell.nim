from std/os import execShellCmd
from std/strutils import join
from std/strformat import `&`
import ../cfg
import ./paths
import ./logger
type ShellError = object of CatchableError
template err(msg:string)= raise newException(ShellError,msg)
proc sh *(cmd :string; args :varargs[string, `$`]) :void=
  let command = cmd & " " & args.join(" ")
  if os.execShellCmd(command) != 0: err "Failed to run: "&command
proc run *(trg :Path; msg :string= "Running nimscript file: "; report :bool= on) :void=
  if trg.splitFile.ext notin ValidExtensions: return
  if report: info msg, trg.string
  if not cacheDir.dirExists(): createDir(cacheDir)
  sh cfg.nimBin, "e -d:minissg --hints:off", &"-d:rootDir:{string rootDir} --path:{string ssgDir}", trg.string
