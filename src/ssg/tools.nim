when defined(nimscript):
  import ./tool/nims ; export nims
else:
  import ./tool/opts    ; export opts
  import ./tool/shell   ; export shell
  import ./tool/modtime ; export modtime
  import ./tool/files   ; export files
  import ./tool/paths   ; export paths
  import ./tool/logger  ; export logger
