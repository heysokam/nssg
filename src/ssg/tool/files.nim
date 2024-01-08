from std/strutils import join
from std/os import setFilePermissions, FilePermission
# @deps ssg
import ../cfg
import ./paths
import ./modtime

proc changed *(file :Path) :bool=
  ## @descr Returns true if the {@arg file} meets the conditions for being considered `changed`.
  ## @true There is no modification time registered for the file.
  ## @true Modification time of the file is more recent than the last registered time.
  ## @true The target file that will be output when compiling this file does not exist.
  let pub = file.relativePath(srcDir).absolutePath(trgDir).changeFileExt("html")
  let trg = Path( file.relativePath(srcDir).absolutePath(cacheDir).string & ".mod" )
  if not pub.fileExists() or not trg.fileExists():
    modtime.write( file, trg )
    return true
  let curr = modtime.get(file)
  let last = readLines(trg.string, 1).join()
  if curr != last:
    modtime.write( file, trg )
    return true
  return false

proc isExec *(trg :Path) :bool=
  let perms = os.getFilePermissions(trg.string)
  return os.FilePermission.fpUserExec in perms or os.FilePermission.fpGroupExec in perms or os.FilePermission.fpOthersExec in perms
proc setExec *(trg :Path) :void=  os.setFilePermissions(trg.string, {os.FilePermission.fpUserRead, os.FilePermission.fpUserWrite, os.FilePermission.fpUserExec}, followSymlinks = false)
  ## @descr Sets the given {@arg trg} binary flags to be executable for the current user.
