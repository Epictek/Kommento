include karax / prelude
import karax / [kajax, kdom]
import dom, times, json, strutils
import utils
import httpcore
import ../models/comment, error
import options, strformat, sequtils
import config

type
    State* = ref object
        loading: bool
        status: HttpCode
        list: Option[CommentList]

proc newState*(): State =
    State(
        loading: false,
        status: Http200,
        list: none[CommentList]()
    )

var state = newState()

proc onGetComments(httpStatus:int, response: kstring) =
    state.loading = false
    state.status = httpStatus.HttpCode
    if httpStatus != 200: return

    let parsed = parseJson($response)
    let list = to(parsed, CommentList)
    state.list = some(list)

proc renderComments*(): VNode =
    if state.status != Http200:
        return renderError("Couldn't retrieve comments.", state.status)

    if state.list.isNone:
      if not state.loading:
        state.loading = true
        ajaxGet("$1/$2/comments" % [ API_ROOT, currentPage()], @[], onGetComments)

      return buildHtml(tdiv(class="loading loading-lg"))

    let list = state.list.get()
    result = buildHtml(tdiv):
        for c in list.comments:
            tdiv(class="comment"):
              tdiv(class="comment-header"):
                img(class="comment-avatar",src=c.avatar)
                span(class="comment-username"):
                  text c.name
              tdiv(class="comment-body"):
                verbatim(c.comment)
