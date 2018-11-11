import htmlgen, jester, db_sqlite, strutils, parseutils, marshal, md5, utils, markdown, httpclient, times, json
import re
import ../models/comment
let
  UsernameIdent* = IdentChars
  commentMaxLength = 6000
  commentMinLength = 3


let db = open("comments.db", "", "", "comments")

type
  Domain = object
    id: int
    name: string


settings:
  staticDir = "../demo"
  
routes:
  get "/":
    setStaticDir(request, "../demo")
    resp "Derp"

  get "/api/domains/":
    var domains: seq[Domain]
    var owner = 1
    for d in db.fastRows(sql"SELECT id, domain, owner, comment FROM domain WHERE owner = ?", owner):
      domains.add(
        Domain(
          id: d[0].parseInt(),
          name: d[1],
        )
      )
    if domains.len > 0:
        resp $$domains, "application/json"
    else:
        resp Http404, "No Domains"

  get "/api/register/":
    resp Http400, "Not Implemented Yet"

  get "/api/login/":
    resp Http400, "Not Implemented Yet"

  get "/api/@page/comments":
    var list = CommentList(
        comments: @[]
    )
    for c in db.fastRows(sql"SELECT id, name, email, comment, strftime('%s', creation) FROM comment WHERE page = ?", @"page"):
      
      list.comments.add(
        Comment(
          id: c[0].parseInt(),
          name: c[1],
          avatar: utils.getAvatarUrl(c[2]),
          comment: markdown(c[3]),
          date: c[4].parseInt()
        )
      )
    if list.comments.len > 0:
        resp $(%list), "application/json"
    else:
        resp Http404, "No Comments"
  
  post "/api/comment":
    let
      formData = request.formData
      name = formData["name"].body
      comment = formData["comment"].body
      page = formData["page"].body
      domain = formData["domain"].body
      key = formData["key"].body
      ip = request.ip

    if (toUnix(getTime()) - parseInt(key)) < 10:
      resp Http400, "You posted this comment too quick!"
    
    var email = formData["email"].body
    echo db.getValue(sql"SELECT page FROM comment WHERE page = ?", page)
    if db.getValue(sql"SELECT page FROM comment WHERE page = ?", page) != "":
      var client = newHttpClient()
      let source = "$1/$2" % [domain, page]
      if client.get(source).code != Http200:
            resp Http404, "Thread not found!"

    if comment.len > commentMaxLength:
          resp Http400, "Comment too long (max length: $1)" % [$commentMaxLength]
    if comment.len < commentMinLength:
      resp Http400, "Comment text is too short (min length: $1)" % [$commentMinLength]
    if not allCharsInSet(name, UsernameIdent) or name.len > 40:
      resp Http400, "Invalid Name"

    if not ('@' in email and '.' in email):
      email = ""
    db.exec(sql"INSERT INTO comment(name, email, page, comment,ip,key) values (?,?,?,?,?,?)", name, email, page, comment, ip, key)
    resp "Comment Submitted"
