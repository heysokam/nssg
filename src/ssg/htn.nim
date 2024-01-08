import ./tool/paths
import ./tool/files
import ./tool/shell

proc isValid *(file :Path) :bool= file.fileExists and (file.endsWith(".htn") or file.endsWith(".nims"))
proc build *(file :Path) :void=
  if file.changed: run file, "Compiling file: "

