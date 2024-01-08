import ./tool/paths
import ./tool/files
import ./tool/shell
import ./tool/logger
import ./cfg


proc init (binDir :Path= cfg.binDir) :void= discard

proc isValid *(file :Path) :bool= file.fileExists and file.endsWith(".nim")
proc build *(file :Path; srcDir :Path= cfg.srcDir/cfg.nimSub; trgDir :Path= cfg.trgDir/cfg.jsSub) :void=
  if file.changed: 
    info "Compiling file: ", file.string
    sh nimBin, "js --hints:off -d:release", "--outDir:"&trgDir.string, file.string
