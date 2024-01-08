import ./tool/logger
import ./tool/paths
import ./tool/shell
import ./tool/files
import ./tailwind
import ./htn
import ./nim

type SSGError = object of CatchableError
template err(msg:string)= raise newException(SSGError,msg)

proc loop=
  info "Waiting for changes to recompile files from "&cfg.srcDir
  while true:
    for file in cfg.srcDir.walkDirRec():
      if file.changed: run file

#_______________________________________
# @section Entry Point of μssg
proc run=
  info "Starting..."
  tailwind.init()
  info "Compiling project files at "&cfg.srcDir
  for file in cfg.srcDir.walkDirRec():
    if   htn.isValid(file): htn.build(file)
    elif nim.isValid(file): nim.build(file)
  tailwind.build()
  info "Done."
#___________________
when isMainModule: run()
