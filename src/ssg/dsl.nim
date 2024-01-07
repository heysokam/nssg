## Reformatted and extended version of: https://github.com/juancarlospaco/nim-html-dsl
# @deps std
import std/[ strutils,strformat,sequtils ]
import std/macros except body

func firstUpper *(s :string) :string=  result = s; result[0] = result[0].toUpperAscii()
  ## Returns the string with its first character converted to Uppercase
template minifyHtml *(htmlstr :string) :string=
  when not defined(release): htmlstr.multiReplace(("\t",""), ("\n",""), ("\r","")).split(">").mapIt( it.strip() ).join(">") else: htmlstr
const nl :string= when defined(release): "" else: "\n"
const useClassDefaults :bool= off
const TabSize          :byte= 2

type nk *{.pure.}= enum  ## All HTML Tags, taken from Mozilla docs, +Comment.
  A = "a", Abbr = "abbr",  Address = "address", Area = "area", Article = "article", Aside = "aside", Audio = "audio", B = "b",
  Base = "base", Bdi = "bdi", Bdo = "bdo", Big = "big", Blockquote = "blockquote", Body = "body", Br = "br",
  Button = "button", Canvas = "canvas", Caption = "caption", Center = "center", Cite = "cite", Code = "code", Col = "col",
  Colgroup = "colgroup", Data = "data", Datalist = "datalist", Dd = "dd", Del = "del", Details = "details", Dfn = "dfn",
  Dialog = "dialog", Div = "div", Dl = "dl", Dt = "dt", Em = "em", Embed = "embed", Fieldset = "fieldset", Figure = "figure",
  Figcaption = "figcaption", Footer = "footer", Form = "form", H1 = "h1", H2 = "h2", H3 = "h3", H4 = "h4", H5 = "h5", H6 = "h6",
  Head = "head", Header = "header", Html = "html", Hr = "hr", I = "i", Iframe = "iframe", Img = "img", Input = "input",
  Ins = "ins", Kbd = "kbd", Keygen = "keygen", Label = "label", Legend = "legend", Li = "li", Link = "link", Main = "main",
  Map = "map", Mark = "mark", Marquee = "marquee", Meta = "meta", Meter = "meter", Nav = "nav", Noscript = "noscript",
  Ol = "ol", Optgroup = "optgroup", Option = "option", Output = "output", P = "p", Param = "param", Picture = "picture",
  Pre = "pre", Progress = "progress", Q = "q", Rb = "rb", Rp = "rp", Rt = "rt", Rtc = "rtc", Ruby = "ruby", S = "s", Samp = "samp",
  Script = "script", Section = "section", Select = "select", Slot = "slot", Small = "small", Source = "source", Span = "span",
  Strong = "strong", Style = "style", Sub = "sub", Summary = "summary", Sup = "sup", Table = "table", Tbody = "tbody", Td = "td",
  Textarea = "textarea", Tfoot = "tfoot", Th = "th", Thead = "thead", Time = "time", Title = "title", Tr = "tr", Track = "track",
  Tt = "tt", U = "u", Ul = "ul", Video = "video", Wbr = "wbr", Comment
type HtmlNode * = ref object  ## HTML Tag Object type, all possible attributes.
  contenteditable: bool
  width, height: Natural
  id, class, style, name, accessKey, src, tabIndex, translate, hidden :string
  httpEquiv, lang, role, spellCheck: string
  onAbort, onBlur, onCancel, onCanPlay, onCanPlayThrough, onChange :string
  onClick, onCueChange, onDblClick: string
  onDurationChange, onEmptied, onEnded, onError, onFocus, onInput :string
  onInvalid, onKeyDown, onKeyPress: string
  onKeyUp, onLoad, onLoadedData, onLoadedMetadata, onLoadStart :string
  onMouseDown, onMouseEnter, onMouseLeave: string
  onMouseMove, onMouseOut, onMouseOver, onMouseUp, onMouseWheel :string
  onPause, onPlay, onPlaying, onProgress: string
  onRateChange, onReset, onResize, onScroll, onSeeked, onSeeking :string
  onSelect, onShow, onStalled, onSubmit: string
  onSuspend, onTimeUpdate, onToggle, onVolumeChange, onWaiting :string
  disabled, crossOrigin, hrefLang, form: string
  maxLength, minLength, placeholder, readOnly, required, coords :string
  download, href, rel, shape, target: string
  preload, autoPlay, mediaGroup, loop, muted, controls, poster :string
  onAfterPrint, onBeforePrint, onBeforeUnload: string
  onHashChange, onMessage, onOffline, onOnline, onPageHide, onPageShow :string
  onPopState, onStorage, onUnload: string
  open, action, enctype, noValidate, srcDoc, sandBox, useMap, isMap :string
  accept, alt, autoComplete, autoFocus: string
  checked, dirName, formAction, formEncType, formMethod, formNoValidate :string
  formTarget, inputMode, list: string
  max, min, multiple, pattern, size, step, value, text, val, content :string
  behavior, bgColor, direction, hSpace: string
  scrollAmount, scrollDelay, trueSpeed, vSpace, onBounce, onFinish :string
  onStart, optimum, selected, colSpan: string
  rowSpan, headers, cols, rows, wrap, integrity, media, referrerPolicy :string
  sizes, `type`, `for`, `async`, `defer`: string
  case kind: nk  # Some tags have unique attributes.
  of Html: head, body: HtmlNode
  of Head:
    title: HtmlNode
    meta, link: seq[HtmlNode]
  else: children: seq[HtmlNode]

const basicHeadTags = when not useClassDefaults: "" else: """
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">"""
const procTemplate = """
func $1 *(text="", val="", contenteditable=false, width=0, height=0, id="", style="", class="", name="", accesskey="", src="", tabindex="",
    translate="", hidden="", httpequiv="", lang="", role="", spellcheck="", onabort="", onblur="", oncancel="", oncanplay="",
    oncanplaythrough="", onchange="", onclick="", oncuechange="", ondblclick="", ondurationchange="", onemptied="", onended="",
    onerror="", onfocus="", oninput="", oninvalid="", onkeydown="", onkeypress="", onkeyup="", onload="", onloadeddata="",
    onloadedmetadata="", onloadstart="", onmousedown="", onmouseenter="", onmouseleave="", onmousemove="", onmouseout="",
    onmouseover="", onmouseup="", onmousewheel="", onpause="", onplay="", onplaying="", onprogress="", onratechange="",
    onreset="", onresize="", onscroll="", onseeked="", onseeking="", onselect="", onshow="", onstalled="", onsubmit="", onsuspend="",
    ontimeupdate="", ontoggle="", onvolumechange="", onwaiting="", disabled="", crossorigin="", hreflang="", form="", maxlength="",
    minlength="", placeholder="", readonly="", required="", coords="", download="", href="", rel="", shape="", target="",
    preload="", autoplay="", mediagroup="", loop="", muted="", controls="", poster="", onafterprint="", onbeforeprint="",
    onbeforeunload="", onhashchange="", onmessage="", onoffline="", ononline="", onpagehide="", onpageshow="", onpopstate="",
    onstorage="", onunload="", open="", action="", enctype="", novalidate="", srcdoc="", sandbox="", usemap="", ismap="",
    accept="", alt="", autocomplete="", autofocus="", checked="", dirname="", formaction="", formenctype="", formmethod="",
    formnovalidate="", formtarget="", inputmode="", list="", max="", min="", multiple="", pattern="", size="", step="", value="",
    content="", behavior="", bgcolor="", direction="", hspace="", scrollamount="", scrolldelay="", truespeed="", vspace="", onbounce="",
    onfinish="", onstart="", optimum="", selected="", colspan="", rowspan="", headers="", cols="", rows="", wrap="", integrity="",
    media="", referrerpolicy="", sizes="", `type`="", `for`="", `async`="", `defer`="", children: varargs[HtmlNode]
  ) :HtmlNode {.inline.}=
  result = HtmlNode(kind: nk.$2, text: text, val: val, contenteditable: contenteditable, width: width, height: height,
    id: id, class: class, name: name, accesskey: accesskey, src: src, tabindex: tabindex, translate: translate, hidden: hidden, httpequiv: httpequiv, lang: lang, role: role,
    spellcheck: spellcheck, onabort: onabort, onblur: onblur, oncancel: oncancel, oncanplay: oncanplay, oncanplaythrough: oncanplaythrough, onchange: onchange, onclick: onclick, oncuechange: oncuechange,
    ondblclick: ondblclick, ondurationchange: ondurationchange, onemptied: onemptied, onended: onended, onerror: onerror, onfocus: onfocus, oninput: oninput, oninvalid: oninvalid, onkeydown: onkeydown,
    onkeypress: onkeypress, onkeyup: onkeyup, onload: onload, onloadeddata: onloadeddata, onloadedmetadata: onloadedmetadata, onloadstart: onloadstart, onmousedown: onmousedown,
    onmouseenter: onmouseenter, onmouseleave: onmouseleave, onmousemove: onmousemove, onmouseout: onmouseout, onmouseover: onmouseover, onmouseup: onmouseup, onmousewheel: onmousewheel, onpause: onpause,
    onplay: onplay, onplaying: onplaying, onprogress: onprogress, onratechange: onratechange, onreset: onreset, onresize: onresize, onscroll: onscroll, onseeked: onseeked, onseeking: onseeking,
    onselect: onselect, onshow: onshow, onstalled: onstalled, onsubmit: onsubmit, onsuspend: onsuspend, ontimeupdate: ontimeupdate, ontoggle: ontoggle, onvolumechange: onvolumechange, onwaiting: onwaiting,
    disabled: disabled, crossorigin: crossorigin, hreflang: hreflang, form: form, maxlength: maxlength, minlength: minlength, placeholder: placeholder, readonly: readonly, required: required,
    coords: coords, download: download, href: href, rel: rel, shape: shape, target: target, preload: preload, autoplay: autoplay, mediagroup: mediagroup, loop: loop, muted: muted,
    controls: controls, poster: poster, onafterprint: onafterprint, onbeforeprint: onbeforeprint, onbeforeunload: onbeforeunload, onhashchange: onhashchange, onmessage: onmessage, onoffline: onoffline,
    ononline: ononline, onpagehide: onpagehide, onpageshow: onpageshow, onpopstate: onpopstate, onstorage: onstorage, onunload: onunload, open: open, action: action, enctype: enctype,
    novalidate: novalidate, srcdoc: srcdoc, sandbox: sandbox, usemap: usemap, ismap: ismap, accept: accept, alt: alt, autocomplete: autocomplete, autofocus: autofocus, checked: checked,
    dirname: dirname, formaction: formaction, formenctype: formenctype, formmethod: formmethod, formnovalidate: formnovalidate, formtarget: formtarget, inputmode: inputmode, list: list, max: max,
    min: min, multiple: multiple, pattern: pattern, size: size, step: step, value: value, content: content, behavior: behavior, bgcolor: bgcolor, direction: direction,
    hspace: hspace, scrollamount: scrollamount, scrolldelay: scrolldelay, truespeed: truespeed, vspace: vspace, onbounce: onbounce, onfinish: onfinish,
    onstart: onstart, optimum: optimum, selected: selected, colspan: colspan, rowspan: rowspan, headers: headers, cols: cols, rows: rows, wrap: wrap,
    integrity: integrity, media: media, referrerpolicy: referrerpolicy, sizes: sizes, `type`: `type`, `for`: `for`, `async`: `async`, `defer`: `defer`, children: @children)"""

func setAttributes(t: HtmlNode): string =
  if t.hidden.len > 0:              result.add " hidden" # Just adds HTML attributes for tags.
  if t.spellcheck.len > 0:          result.add " spellcheck"
  if unlikely(t.disabled.len > 0):  result.add " disabled"
  if t.readonly.len > 0:            result.add " readonly"
  if t.required.len > 0:            result.add " required"
  if t.autoplay.len > 0:            result.add " autoplay"
  if unlikely(t.controls.len > 0):  result.add " controls"
  if t.autocomplete.len > 0:        result.add " autocomplete"
  if t.autofocus.len > 0:           result.add " autofocus"
  if t.checked.len > 0:             result.add " checked"
  if t.open.len > 0:                result.add " open"
  if t.`async`.len > 0:             result.add " async"
  if t.`defer`.len > 0:             result.add " defer"
  if t.selected.len > 0:            result.add " selected"
  if unlikely(t.width != 0):        result.add " width=\""            & $t.width           & "\""
  if unlikely(t.height != 0):       result.add " width=\""            & $t.height          & "\""
  if t.id.len > 0:                  result.add " id=\""               & t.id               & "\""
  if t.class.len > 0:               result.add " class=\""            & t.class            & "\""
  if t.name.len > 0:                result.add " name=\""             & t.name             & "\""
  if unlikely(t.accesskey.len > 0): result.add " accesskey=\""        & t.accesskey        & "\""
  if t.src.len > 0:                 result.add " src=\""              & t.src              & "\""
  if unlikely(t.tabindex.len > 0):  result.add " tabindex=\""         & t.tabindex         & "\""
  if unlikely(t.translate.len > 0): result.add " translate=\""        & t.translate        & "\""
  if unlikely(t.lang.len > 0):      result.add " lang=\""             & t.lang             & "\""
  if t.role.len > 0:                result.add " role=\""             & t.role             & "\""
  if t.onabort.len > 0:             result.add " onabort=\""          & t.onabort          & "\""
  if t.onblur.len > 0:              result.add " onblur=\""           & t.onblur           & "\""
  if t.oncancel.len > 0:            result.add " oncancel=\""         & t.oncancel         & "\""
  if unlikely(t.oncanplay.len > 0): result.add " oncanplay=\""        & t.oncanplay        & "\""
  if t.oncanplaythrough.len > 0:    result.add " oncanplaythrough=\"" & t.oncanplaythrough & "\""
  if t.onchange.len > 0:            result.add " onchange=\""         & t.onchange         & "\""
  if t.onclick.len > 0:             result.add " onclick=\""          & t.onclick          & "\""
  if t.oncuechange.len > 0:         result.add " oncuechange=\""      & t.oncuechange      & "\""
  if t.ondblclick.len > 0:          result.add " ondblclick=\""       & t.ondblclick       & "\""
  if t.ondurationchange.len > 0:    result.add " ondurationchange=\"" & t.ondurationchange & "\""
  if unlikely(t.onemptied.len > 0): result.add " onemptied=\""        & t.onemptied        & "\""
  if t.onended.len > 0:             result.add " onended=\""          & t.onended          & "\""
  if t.onerror.len > 0:             result.add " onerror=\""          & t.onerror          & "\""
  if t.onfocus.len > 0:             result.add " onfocus=\""          & t.onfocus          & "\""
  if t.oninput.len > 0:             result.add " oninput=\""          & t.oninput          & "\""
  if t.oninvalid.len > 0:           result.add " oninvalid=\""        & t.oninvalid        & "\""
  if t.onkeydown.len > 0:           result.add " onkeydown=\""        & t.onkeydown        & "\""
  if t.onkeypress.len > 0:          result.add " onkeypress=\""       & t.onkeypress       & "\""
  if t.onkeyup.len > 0:             result.add " onkeyup=\""          & t.onkeyup          & "\""
  if t.onload.len > 0:              result.add " onload=\""           & t.onload           & "\""
  if t.onloadeddata.len > 0:        result.add " onloadeddata=\""     & t.onloadeddata     & "\""
  if t.onloadedmetadata.len > 0:    result.add " onloadedmetadata=\"" & t.onloadedmetadata & "\""
  if t.onloadstart.len > 0:         result.add " onloadstart=\""      & t.onloadstart      & "\""
  if t.onmousedown.len > 0:         result.add " onmousedown=\""      & t.onmousedown      & "\""
  if t.onmouseenter.len > 0:        result.add " onmouseenter=\""     & t.onmouseenter     & "\""
  if t.onmouseleave.len > 0:        result.add " onmouseleave=\""     & t.onmouseleave     & "\""
  if t.onmousemove.len > 0:         result.add " onmousemove=\""      & t.onmousemove      & "\""
  if t.onmouseout.len > 0:          result.add " onmouseout=\""       & t.onmouseout       & "\""
  if t.onmouseover.len > 0:         result.add " onmouseover=\""      & t.onmouseover      & "\""
  if t.onmouseup.len > 0:           result.add " onmouseup=\""        & t.onmouseup        & "\""
  if t.onmousewheel.len > 0:        result.add " onmousewheel=\""     & t.onmousewheel     & "\""
  if t.onpause.len > 0:             result.add " onpause=\""          & t.onpause          & "\""
  if unlikely(t.onplay.len > 0):    result.add " onplay=\""           & t.onplay           & "\""
  if unlikely(t.onplaying.len > 0): result.add " onplaying=\""        & t.onplaying        & "\""
  if t.onprogress.len > 0:          result.add " onprogress=\""       & t.onprogress       & "\""
  if t.onratechange.len > 0:        result.add " onratechange=\""     & t.onratechange     & "\""
  if unlikely(t.onreset.len > 0):   result.add " onreset=\""          & t.onreset          & "\""
  if t.onresize.len > 0:            result.add " onresize=\""         & t.onresize         & "\""
  if t.onscroll.len > 0:            result.add " onscroll=\""         & t.onscroll         & "\""
  if unlikely(t.onseeked.len > 0):  result.add " onseeked=\""         & t.onseeked         & "\""
  if unlikely(t.onseeking.len > 0): result.add " onseeking=\""        & t.onseeking        & "\""
  if t.onselect.len > 0:            result.add " onselect=\""         & t.onselect         & "\""
  if t.onshow.len > 0:              result.add " onshow=\""           & t.onshow           & "\""
  if unlikely(t.onstalled.len > 0): result.add " onstalled=\""        & t.onstalled        & "\""
  if t.onsubmit.len > 0:            result.add " onsubmit=\""         & t.onsubmit         & "\""
  if t.onsuspend.len > 0:           result.add " onsuspend=\""        & t.onsuspend        & "\""
  if t.ontimeupdate.len > 0:        result.add " ontimeupdate=\""     & t.ontimeupdate     & "\""
  if t.ontoggle.len > 0:            result.add " ontoggle=\""         & t.ontoggle         & "\""
  if t.onvolumechange.len > 0:      result.add " onvolumechange=\""   & t.onvolumechange   & "\""
  if t.onwaiting.len > 0:           result.add " onwaiting=\""        & t.onwaiting        & "\""
  if t.onafterprint.len > 0:        result.add " onafterprint=\""     & t.onafterprint     & "\""
  if t.onbeforeprint.len > 0:       result.add " onbeforeprint=\""    & t.onbeforeprint    & "\""
  if t.onbeforeunload.len > 0:      result.add " onbeforeunload=\""   & t.onbeforeunload   & "\""
  if t.onhashchange.len > 0:        result.add " onhashchange=\""     & t.onhashchange     & "\""
  if t.onmessage.len > 0:           result.add " onmessage=\""        & t.onmessage        & "\""
  if t.onoffline.len > 0:           result.add " onoffline=\""        & t.onoffline        & "\""
  if t.ononline.len > 0:            result.add " ononline=\""         & t.ononline         & "\""
  if t.onpagehide.len > 0:          result.add " onpagehide=\""       & t.onpagehide       & "\""
  if t.onpageshow.len > 0:          result.add " onpageshow=\""       & t.onpageshow       & "\""
  if t.onpopstate.len > 0:          result.add " onpopstate=\""       & t.onpopstate       & "\""
  if unlikely(t.onstorage.len > 0): result.add " onstorage=\""        & t.onstorage        & "\""
  if t.onunload.len > 0:            result.add " onunload=\""         & t.onunload         & "\""
  if unlikely(t.onbounce.len > 0):  result.add " onbounce=\""         & t.onbounce         & "\""
  if t.onfinish.len > 0:            result.add " onfinish=\""         & t.onfinish         & "\""
  if t.onstart.len > 0:             result.add " onstart=\""          & t.onstart          & "\""
  if t.crossorigin.len > 0:         result.add " crossorigin=\""      & t.crossorigin      & "\""
  if unlikely(t.hreflang.len > 0):  result.add " hreflang=\""         & t.hreflang         & "\""
  if t.form.len > 0:                result.add " form=\""             & t.form             & "\""
  if t.maxlength.len > 0:           result.add " maxlength=\""        & t.maxlength        & "\""
  if t.minlength.len > 0:           result.add " minlength=\""        & t.minlength        & "\""
  if t.placeholder.len > 0:         result.add " placeholder=\""      & t.placeholder      & "\""
  if unlikely(t.coords.len > 0):    result.add " coords=\""           & t.coords           & "\""
  if unlikely(t.download.len > 0):  result.add " download=\""         & t.download         & "\""
  if t.href.len > 0:                result.add " href=\""             & t.href             & "\""
  if t.rel.len > 0:                 result.add " rel=\""              & t.rel              & "\""
  if unlikely(t.shape.len > 0):     result.add " shape=\""            & t.shape            & "\""
  if t.target.len > 0:              result.add " target=\""           & t.target           & "\""
  if t.preload.len > 0:             result.add " preload=\""          & t.preload          & "\""
  if t.mediagroup.len > 0:          result.add " mediagroup=\""       & t.mediagroup       & "\""
  if unlikely(t.loop.len > 0):      result.add " loop=\""             & t.loop             & "\""
  if unlikely(t.muted.len > 0):     result.add " muted=\""            & t.muted            & "\""
  if unlikely(t.poster.len > 0):    result.add " poster=\""           & t.poster           & "\""
  if t.action.len > 0:              result.add " action=\""           & t.action           & "\""
  if unlikely(t.enctype.len > 0):   result.add " enctype=\""          & t.enctype          & "\""
  if t.novalidate.len > 0:          result.add " novalidate=\""       & t.novalidate       & "\""
  if unlikely(t.srcdoc.len > 0):    result.add " srcdoc=\""           & t.srcdoc           & "\""
  if unlikely(t.sandbox.len > 0):   result.add " sandbox=\""          & t.sandbox          & "\""
  if unlikely(t.usemap.len > 0):    result.add " usemap=\""           & t.usemap           & "\""
  if unlikely(t.ismap.len > 0):     result.add " ismap=\""            & t.ismap            & "\""
  if t.accept.len > 0:              result.add " accept=\""           & t.accept           & "\""
  if t.alt.len > 0:                 result.add " alt=\""              & t.alt              & "\""
  if t.dirname.len > 0:             result.add " dirname=\""          & t.dirname          & "\""
  if t.formaction.len > 0:          result.add " formaction=\""       & t.formaction       & "\""
  if t.formenctype.len > 0:         result.add " formenctype=\""      & t.formenctype      & "\""
  if t.formmethod.len > 0:          result.add " formmethod=\""       & t.formmethod       & "\""
  if t.formnovalidate.len > 0:      result.add " formnovalidate=\""   & t.formnovalidate   & "\""
  if t.formtarget.len > 0:          result.add " formtarget=\""       & t.formtarget       & "\""
  if t.inputmode.len > 0:           result.add " inputmode=\""        & t.inputmode        & "\""
  if unlikely(t.list.len > 0):      result.add " list=\""             & t.list             & "\""
  if unlikely(t.max.len > 0):       result.add " max=\""              & t.max              & "\""
  if unlikely(t.min.len > 0):       result.add " min=\""              & t.min              & "\""
  if unlikely(t.multiple.len > 0):  result.add " multiple=\""         & t.multiple         & "\""
  if unlikely(t.pattern.len > 0):   result.add " pattern=\""          & t.pattern          & "\""
  if t.size.len > 0:                result.add " size=\""             & t.size             & "\""
  if t.step.len > 0:                result.add " step=\""             & t.step             & "\""
  if t.`type`.len > 0:              result.add " type=\""             & t.`type`           & "\""
  if t.value.len > 0:               result.add " value=\""            & t.value            & "\""
  if t.`for`.len > 0:               result.add " for=\""              & t.`for`            & "\""
  if unlikely(t.behavior.len > 0):  result.add " behavior=\""         & t.behavior         & "\""
  if unlikely(t.bgcolor.len > 0):   result.add " bgcolor=\""          & t.bgcolor          & "\""
  if unlikely(t.direction.len > 0): result.add " direction=\""        & t.direction        & "\""
  if unlikely(t.hspace.len > 0):    result.add " hspace=\""           & t.hspace           & "\""
  if t.scrollamount.len > 0:        result.add " scrollamount=\""     & t.scrollamount     & "\""
  if t.scrolldelay.len > 0:         result.add " scrolldelay=\""      & t.scrolldelay      & "\""
  if unlikely(t.truespeed.len > 0): result.add " truespeed=\""        & t.truespeed        & "\""
  if unlikely(t.vspace.len > 0):    result.add " vspace=\""           & t.vspace           & "\""
  if unlikely(t.optimum.len > 0):   result.add " optimum=\""          & t.optimum          & "\""
  if t.colspan.len > 0:             result.add " colspan=\""          & t.colspan          & "\""
  if t.rowspan.len > 0:             result.add " rowspan=\""          & t.rowspan          & "\""
  if t.headers.len > 0:             result.add " headers=\""          & t.headers          & "\""
  if t.cols.len > 0:                result.add " cols=\""             & t.cols             & "\""
  if t.rows.len > 0:                result.add " rows=\""             & t.rows             & "\""
  if t.wrap.len > 0:                result.add " wrap=\""             & t.wrap             & "\""
  if t.httpequiv.len > 0:           result.add " http-equiv=\""       & t.httpequiv        & "\""
  if t.content.len > 0:             result.add " content=\""          & t.content          & "\""
  if t.integrity.len > 0:           result.add " integrity=\""        & t.integrity        & "\""
  if t.media.len > 0:               result.add " media=\""            & t.media            & "\""
  if t.referrerpolicy.len > 0:      result.add " referrerpolicy=\""   & t.referrerpolicy   & "\""
  if t.sizes.len > 0:               result.add " sizes=\""            & t.sizes            & "\""
  if unlikely(t.contenteditable):   result.add """ contenteditable="true""""

func openTag (node :HtmlNode) :string=
  let classDefaults :string= if not useClassDefaults: "" else:
    case node.kind
    of Html     : "has-navbar-fixed-top"
    of Body     : "has-navbar-fixed-top"
    of Article  : "message"
    of Button   : "button is-light is-rounded btn tooltip"
    of Details  : "message is-dark"
    of Summary  : "message-header is-dark"
    of Dialog   : "notification is-rounded modal"
    of Footer   : "footer is-fullwidth"
    of H1       : "title"
    of Img      : "image img-responsive"
    of Label    : "label form-label"
    of Meter    : "progress is-small bar-item"
    of Progress : "progress is-small bar-item"
    of Section  : "section"
    of Select   : "select is-primary is-rounded is-small form-select"
    of Table    : "table is-bordered is-striped is-hoverable table-striped table-hover"
    of Figure   : "figure figure-caption text-center"
    of Pre      : "code"
    of Video    : "video-responsive"
    of Center   : "is-centered"
    of Input    : "input is-primary form-input"
    of Textarea : "textarea is-primary form-input"
    of Nav      : "navbar is-fixed-top is-light"
    else        : ""
  let classAttr :string=
    if   classDefaults != "" and node.class != "" : &" class='{classDefaults}{node.class}' "
    elif node.class != ""                         : &" class='{node.class}' "
    else                                          : ""
  let styleAttr :string= if node.style != "": &" style='{node.style}'" else: ""
  result = case node.kind
    of Html            : &"<!DOCTYPE html>{nl}<{$node.kind}{classAttr}>{nl}"
    of Head            : &"<{$node.kind}>{nl}{basicHeadTags}"
    of Title           : &"<{$node.kind}>{node.text}</{$node.kind}>{nl}"
    of Meta, Link      : &"<{$node.kind}{setAttributes(node)}>{nl}"
    of Body            : &"<{$node.kind}{styleAttr}{classAttr}>{nl}"
    of Meter, Progress : &"<{$node.kind}{classAttr} role='progressbar'{setAttributes(node)}>{nl}"
    of Nav             : &"<{$node.kind}{classAttr} role='navigation'{setAttributes(node)}>{nl}"
    of Input, Textarea : &"<{$node.kind}{classAttr} dir='auto'{setAttributes(node)}>{nl}"
    of Hr, Br          : &"{$node.kind}>{nl}"
    of Comment         :
      when defined(release): "" else: indent(&"<!-- {node.text} -->", 2) & nl
    of Article, Details, Dialog, Footer, H1, Img, Label, Section, Select, Table, Video:
      &"<{$node.kind}{classAttr}{setAttributes(node)}>{nl}"
    of Button, Summary, Figure, Pre, Center:
      &"<{$node.kind}{classAttr}{setAttributes(node)}>{nl}{node.text}"
    else: &"<{$node.kind}{setAttributes(node)}>{nl}{node.text}"

func closeTag (node: HtmlNode): string {.inline.} =
  if node.kind notin [Title, Meta, Link, Img, Input, Br, Hr, Comment]:
    result = &"</{$node.kind}>{nl}"

macro autogenAllTheProcs() =
  var allTheProcs: string
  for item in nk: # Comment, Body, Head, Div, Html are special case.
    if item notin {Comment, Body, Head, Div, Html}:
      allTheProcs.add procTemplate.format($item, firstUpper($item)) & "\n"
    else: continue
  parseStmt allTheProcs # Generates a truckload of code.

autogenAllTheProcs()

template indentIfNeeded(thing, indentationLevel: untyped): untyped =
  when defined(release) or defined(danger): thing else: indent(thing, indentationLevel)

func render *(node :HtmlNode) :string=
  var indentationLevel: byte   # indent level, 0 ~ 255.
  result &= openTag node
  indentationLevel.inc(TabSize)
  case node.kind
  of Html:  # <html>
    result &= indentIfNeeded(render(node.head), indentationLevel)
    result &= indentIfNeeded(render(node.body), indentationLevel)
  of Head:  # <head>
    if node.meta.len > 0:
      for meta_tag in node.meta: result &= indentIfNeeded(render(meta_tag), indentationLevel)  # <meta ... >
    if node.link.len > 0:
      for link_tag in node.link: result &= indentIfNeeded(render(link_tag), indentationLevel) # <link ... >
    result &= indentIfNeeded(openTag(node.title), indentationLevel)
  of Body:  # <body>
    if node.children.len > 0:
      for tag in node.children: result &= indentIfNeeded(render(tag), indentationLevel)
  else:
    if node.children.len > 0:
      for tag in node.children: result &= indentIfNeeded(render(tag), indentationLevel)
  indentationLevel.dec(TabSize)
  result &= closeTag node

#_________________________________________________
func `<!--`*(text :string) :HtmlNode {.inline.}=
  ## HTML Comment
  HtmlNode(kind: Comment, text: text)

#_________________________________________________
func newDiv *(children :varargs[HtmlNode]) :HtmlNode {.inline.}=
  HtmlNode(kind: Div, children: @children)
macro divs *(inner :untyped) :HtmlNode=
  result = newCall("newDiv")
  if inner.len == 1: result.add inner
  inner.copyChildrenTo(result)

#_________________________________________________
func newHead *(title :HtmlNode; meta :varargs[HtmlNode]; link :varargs[HtmlNode]) :HtmlNode {.inline.}=
  ## Create a new ``<head>`` tag Node with meta, link and title tag nodes.
  HtmlNode(kind: Head, title: title, meta: @meta, link: @link)
macro heads *(inner :untyped) :HtmlNode=
  result = newCall("newHead")
  if inner.len == 1: result.add inner
  inner.copyChildrenTo(result)

#_________________________________________________
func newBody *(style,class :string; children :varargs[HtmlNode]) :HtmlNode {.inline.}=
  HtmlNode(kind: Body, style: style, class: class, children: @children) ## Create a new ``<body>`` tag Node, containing all children tags.
macro bodys *(style :static string; inner :untyped) :HtmlNode=
  result = newCall("newBody", newStrLitNode(style), newStrLitNode("")) # Result is a call to newBody()
  if inner.len == 1: result.add inner               # if just 1 children just pass it as arg
  inner.copyChildrenTo(result)                      # if several children copy them all, AST level.
macro bodys *(class :static string; inner :untyped) :HtmlNode=
  result = newCall("newBody", newStrLitNode(""), newStrLitNode(class)) # Result is a call to newBody()
  if inner.len == 1: result.add inner               # if just 1 children just pass it as arg
  inner.copyChildrenTo(result)                      # if several children copy them all, AST level.
macro bodys *(inner :untyped) :HtmlNode=
  result = newCall("newBody", newStrLitNode(""), newStrLitNode(""))  # Result is a call to newBody()
  if inner.len == 1: result.add inner             # if just 1 children just pass it as arg
  inner.copyChildrenTo(result)                    # if several children copy them all, AST level.

#_________________________________________________
func newHtml *(head,body :HtmlNode) :HtmlNode {.inline.}=
  HtmlNode(kind: Html, head: head, body: body)
macro html *(inner :untyped) :string=
  newCall("minifyHtml", newCall("render", newCall("newHtml", inner[0], inner[1])))

