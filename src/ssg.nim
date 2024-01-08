# @deps ssg
import ./ssg/cfg ; export cfg
import ./ssg/dsl ; export dsl
# @section Exports for the page scripts
when defined(nimscript):
  include ./ssg/tool/nims
# @section Main Entry Point of the standalone binary
when isMainModule:
  include ./ssg/entry
