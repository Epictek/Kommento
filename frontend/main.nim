include karax / prelude
import karax / [kajax, kdom]
import karaxutils
import dom, times, json, strutils
import commentform, comments
import utils

let API_ROOT ="http://0.0.0.0:5000/api"
let key = $toUnix(getTime())



type
   State = ref object
     loading: bool
     commentForm: CommentForm

proc newState(): State
var state = newState()

proc newState(): State =
    State(
      loading: false,
      commentForm: newCommentForm()
      )

proc createDom(): VNode =
  result = buildHtml(tdiv):
    render(state.commentForm)
    renderComments()

setRenderer createDom, "comments"
