when not defined(nimscript):
  from std/os import getLastModificationTime
from std/times import Time, `$`
import ./paths

proc getTime *(trg :Path) :times.Time=
  ## @descr Returns the last modification time of the {@arg trg} file, or empty if it cannot be found.
  try:    result = os.getLastModificationTime( trg.string )
  except: result = times.Time()
proc get *(trg :Path) :string= $getTime(trg)
  ## @descr Returns a string with the last modification time of the {@arg trg} file, or empty if it cannot be found.

proc write *(src,trg :Path) :void=
  ## @descr Writes the modification time of {@arg src} into {@arg trg}
  let dir = trg.splitFile.dir
  if not dir.dirExists: createDir dir
  trg.writeFile( $modtime.get(src) )

