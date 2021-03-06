import karax / [kdom]
import strutils, options, strformat, parseutils, tables



proc currentPage*(): string =
    var page = $kdom.window.location.pathname
    page = page.strip(chars = {'/'})
    return page

proc class*(classes: varargs[tuple[name: string, present: bool]],
         defaultClasses: string = ""): string =
    result = defaultClasses & " "
    for class in classes:
      if class.present: result.add(class.name & " ")

proc parseIntSafe*(s: string, value: var int) {.noSideEffect.} =
  ## parses `s` into an integer in the range `validRange`. If successful,
  ## `value` is modified to contain the result. Otherwise no exception is
  ## raised and `value` is not touched; this way a reasonable default value
  ## won't be overwritten.
  try:
    discard parseutils.parseInt(s, value, 0)
  except OverflowError:
    discard

proc getInt*(s: string, default = 0): int =
  ## Safely parses an int and returns it.
  result = default
  parseIntSafe(s, result)

proc getInt64*(s: string, default = 0): int64 =
  ## Safely parses an int and returns it.
  result = default
  try:
    discard parseutils.parseBiggestInt(s, result, 0)
  except OverflowError:
    discard

when defined(js):
  include karax/prelude
  import karax / [kdom]

  from dom import nil

  type
    FormData* = ref object
  proc newFormData*(): FormData
    {.importcpp: "new FormData()", constructor.}
  proc newFormData*(form: dom.Element): FormData
    {.importcpp: "new FormData(@)", constructor.}
  proc get*(form: FormData, key: cstring): cstring
    {.importcpp: "#.get(@)".}
  proc append*(form: FormData, key, val: cstring)
    {.importcpp: "#.append(@)".}

 
