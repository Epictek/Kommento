import karax / [kdom]

proc currentPage*(): string =
    var page = $kdom.window.location.pathname
    if page[0] == '/':
       return page[1..^1]
    else:
       return page
