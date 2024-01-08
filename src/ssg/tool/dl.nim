{.define: ssl.}
from std/strformat import `&`
when not defined(nimscript):
  from std/httpclient import newHttpClient, downloadFile
import ../cfg
import ./logger
import ./paths

proc file *(url :string; trg :Path; report :bool= cfg.verbose) :void=
  let client = newHttpClient()
  if report: info &"Downloading {url}\n{pfx.tab}as {trg.string} ..."
  client.downloadFile(url, trg.string)
