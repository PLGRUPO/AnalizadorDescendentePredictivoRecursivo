
handleFileSelect = (evt) ->
  evt.stopPropagation()
  evt.preventDefault()
  files = evt.dataTransfer.files
  output = []
  i = 0
  f = undefined

  while f = files[i]
    if f
      r = new FileReader()
      r.onload = (e) ->
        contents = r.result
        document.getElementById("INPUT").innerHTML = contents
        return

      r.readAsText f
      output.push r
    else
      alert "Failed to load file"
    i++
  evt.target.style.opacity = ""
  evt.target.style.height = ""
  evt.target.style.backgroundColor = ""
  return
handleDragOver = (evt) ->
  evt.stopPropagation()
  evt.preventDefault()
  evt.target.style.opacity = 0.8
  evt.target.style.height = "125px"
  evt.target.style.backgroundColor = "rgb(32, 128, 32)"
  return
handleDragLeave = (evt) ->
  evt.stopPropagation()
  evt.preventDefault()
  evt.target.style.height = ""
  evt.target.style.backgroundColor = "rgb(128, 32, 32)"
  return
$(document).ready ->
  dropZone = document.getElementById("dragandrophandler")
  dropZone.addEventListener "drop", handleFileSelect, false
  dropZone.addEventListener "dragover", handleDragOver, false
  dropZone.addEventListener "dragleave", handleDragLeave, false
  return
