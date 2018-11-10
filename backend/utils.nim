import md5, strutils

proc getAvatarUrl*(email: string, size = 80): string =
  let emailMD5 = email.toLowerAscii.toMD5
  return ("https://api.adorable.io/avatars/" & $size & "/" & $emailMD5 & ".png")
