from std/strutils import join
import ../cfg
proc info *(args :varargs[string, `$`]) :void= echo cfg.prefix&args.join(" ")
proc dbg  *(args :varargs[string, `$`]) :void=
  if cfg.verbose: info args.join(" ")
