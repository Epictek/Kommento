type
  Comment* = ref object
    id*: int
    name*: string
    avatar*: string
    page*: string
    comment*: string
    date*: int64

type
  CommentList* = ref object
    comments* : seq[Comment]

