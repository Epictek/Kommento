include karax/prelude
import karax / [vstyles, kajax, kdom]
import options
import httpcore
import json
import dom except Event
import times
import strutils
import sugar
import config, utils, error

type
    CommentForm* = ref object
        shown: bool
        loading: bool
        key: int64
        error: Option[PostError]

proc newCommentForm*(): CommentForm =
    CommentForm(
        shown: true,
        key: toUnix(getTime())
    )

proc onCommentPost(httpStatus:int, response:kstring, state: CommentForm) =
    postFinished:
        state.shown = false

proc onCommentClick(ev: kdom.Event, n: VNode, state: CommentForm) =
    state.loading = true
    state.error = none[PostError]()

    ev.preventDefault()
    let form = dom.document.getElementById("comment-form")
    let formData = newFormData(form)
    formdata.append("domain", kdom.window.location.protocol & "//" & kdom.window.location.host)
    formData.append("page", currentPage())
    formData.append("key", $state.key)
    ajaxPost("$1/comment" % [ API_ROOT ], @[], cast[cstring](formData), (s: int, r: kstring) => onCommentPost(s, r, state))


proc render*(state: CommentForm): VNode =
  result = buildHtml(tdiv):
    if state.loading:
        tdiv(class="loading")
    else:
        form(id="comment-form"):
            label(class="form-label", `for`="name"):
                text "Name"
            input(class="form-input", name="name", id="name", type="text", placeholder="Name")
            label(class="form-label", `for`="email"):
                text "Email"
            input(class="form-input", name="email", id="email", type="text", placeholder="Email", pattern="[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$")
            label(class="form-label", `for`="comment"):
                text "Comment"
            textarea(class="form-input", name="comment", id="comment", type="text", placeholder="Comment", rows="3")
            button(class=class({"loading": state.loading}, "btn btn-primary"),
                   onclick=(e: Event, n: VNode) => onCommentClick(e, n, state)):
                text "Submit!"
        if state.error.isSome():
            span(class="text-error",
                 style=style(StyleAttr.marginTop, "0.4rem")):
                text state.error.get().message
