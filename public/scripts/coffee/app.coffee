root = exports ? this
root.replacecode = (val) ->
  $("#INPUT").text val.substring(12, val.length - 2)
  return
