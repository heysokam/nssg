# @deps ssg
import ./ssg/cfg
import ./ssg/dsl
import ./ssg/tool/paths
import ./ssg/tool/shell

# @section Exports for the page scripts
export cfg, dsl
when defined(nimscript):
  include ./ssg/nims

when isMainModule:
  import ./ssg/tools
  proc loop=
    while true:
      for file in cfg.srcDir.walkDirRec():
        if file.changed: run file

  for file in cfg.srcDir.walkDirRec():
    if file.changed: run file
