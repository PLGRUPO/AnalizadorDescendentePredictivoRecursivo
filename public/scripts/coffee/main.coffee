main = ->
  $('#outputdiv').css "display", ""
  source = INPUT.value
  try
    result = JSON.stringify(parse(source), null, 2)
  catch result
    result = "<div class=\"error\">" + result + "</div>"
  OUTPUT.innerHTML = result

$(document).ready ->
  PARSE.onclick = main

Object.constructor::error = (message, t) ->
  t = t or this
  t.name = "SyntaxError"
  t.message = message
  throw treturn

RegExp::bexec = (str) ->
  i = @lastIndex
  m = @exec(str)
  return m  if m and m.index is i
  null

String::tokens = ->
  from = undefined
  i = 0
  n = undefined
  m = undefined
  result = []
  WHITES = /\s+/g
  ID = /[a-zA-Z_]\w*/g
  NUM = /\b\d+(\.\d*)?([eE][+-]?\d+)?\b/g
  STRING = /('(\\.|[^'])*'|"(\\.|[^"])*")/g
  ONELINECOMMENT = /\/\/.*/g
  MULTIPLELINECOMMENT = /\/[*](.|\n)*?[*]\//g
  COMPARISONOPERATOR = /[<>=!]=|[<>]/g
  ADDOP = /[+-]/g
  MULTOP = /[*\/]/g
  ONECHAROPERATORS = /([=()&|;:,\.<>{}[\]])/g
  tokens = [
    WHITES
    ID
    NUM
    STRING
    ONELINECOMMENT
    MULTIPLELINECOMMENT
    COMPARISONOPERATOR
    ADDOP
    MULTOP
    ONECHAROPERATORS
  ]
  RESERVED_WORDS =
    P: "P"
    CONST: "CONST"
    VAR: "VAR"
    PROCEDURE: "PROCEDURE"
    CALL: "CALL"
    BEGIN: "BEGIN"
    END: "END"
    IF: "IF"
    THEN: "THEN"
    WHILE: "WHILE"
    DO: "DO"
    ODD: "ODD"

  # Make a token object.
  make = (type, value) ->
    type: type
    value: value
    from: from
    to: i

  getTok = ->
    str = m[0]
    i += str.length # Warning! side effect on i
    str


  # Begin tokenization. If the source string is empty, return nothing.
  return  unless this

  # Loop through this text
  while i < @length
    tokens.forEach (t) ->
      t.lastIndex = i
      return

    from = i

    # Espacios en blanco y comentarios se ignoran
    if m = WHITES.bexec(this) or (m = ONELINECOMMENT.bexec(this)) or (m = MULTIPLELINECOMMENT.bexec(this))
      getTok()

    # Identificadores y palabras reservadas
    else if m = ID.bexec(this)
      rw = RESERVED_WORDS[m[0]]
      if rw
        result.push make(rw, getTok())
      else
        result.push make("ID", getTok())

    # Números
    else if m = NUM.bexec(this)
      n = +getTok()
      if isFinite(n)
        result.push make("NUM", n)
      else
        make("NUM", m[0]).error "Bad number"

    # Cadenas de literales
    else if m = STRING.bexec(this)
      result.push make("STRING", getTok().replace(/^["']|["']$/g, ""))

    # Operador de asignación
    else if m = COMPARISONOPERATOR.bexec(this)
      result.push make("COMPARISON", getTok())

    # Operadores de adición y substracción
    else if m = ADDOP.bexec(this)
      result.push make("ADDOP", getTok())

    # Operadores de multiplicación y división
    else if m = MULTOP.bexec(this)
      result.push make("MULTOP", getTok())

    # Operadores de un solo símbolo
    else if m = ONECHAROPERATORS.bexec(this)
      result.push make(m[0], getTok())
    else
      throw "Syntax error near '#{@substr(i)}'"

  result

parse = (input) ->
  tokens = input.tokens()
  lookahead = tokens.shift()
  match = (t) ->
    if lookahead.type is t
      lookahead = tokens.shift()
      lookahead = null  if typeof lookahead is "undefined"
    else
      throw "Syntax Error. Expected #{t} found '" + lookahead.value + "' near '" + input.substr(lookahead.from) + "'"
    return

  program = ->
    result = block()
    if lookahead and lookahead.type is "."
      match "."
    else
      throw "Syntax Error. Expected '.' at the end of file."
    result

  block = ->
    resultarr = []
    if lookahead and lookahead.type is "CONST"
      match "CONST"
      constante = ->
        result = null
        if lookahead and lookahead.type is "ID"
          left =
            type: "CONSTANT"
            value: lookahead.value
          match "ID"
          match "="
          if lookahead and lookahead.type is "NUM"
            right =
              type: "NUM"
              value: lookahead.value
            match "NUM"
          else
            throw "Syntax Error. Expected NUM but found " +
                  (if lookahead then lookahead.value else "end of input") +
                  " near '#{input.substr(lookahead.from)}'"
        else
          throw "Syntax Error. Expected ID but found " +
                (if lookahead then lookahead.value else "end of input") +
                " near '#{input.substr(lookahead.from)}'"
        result =
          type: "="
          left: left
          right: right
        result
      resultarr.push constante()

      while lookahead and lookahead.type is ","
        match ","
        resultarr.push constante()
      match ";"

    if lookahead and lookahead.type is "VAR"
      match "VAR"
      variable = ->
        result = null
        if lookahead and lookahead.type is "ID"
          result =
            type: "VARIABLE"
            value: lookahead.value
          match "ID"
        else
          throw "Syntax Error. Expected ID but found " +
                (if lookahead then lookahead.value else "end of input") +
                " near '#{input.substr(lookahead.from)}'"
        result
      resultarr.push variable()
      while lookahead and lookahead.type is ","
        match ","
        resultarr.push variable()
      match ";"

    proced = ->
      result = null
      match "PROCEDURE"
      if lookahead and lookahead.type is "ID"
        value = lookahead.value
        match "ID"
        match ";"
        result =
          type: "PROCEDURE"
          name: value
          oper: block()
        match ";"
      else
        throw "Syntax Error. Expected ID but found " +
              (if lookahead then lookahead.value else "end of input") +
              " near '#{input.substr(lookahead.from)}'"
      result
    while lookahead and lookahead.type is "PROCEDURE"
      resultarr.push proced()
    resultarr.push statement()
    resultarr

  statements = ->
    result = [statement()]
    while lookahead and lookahead.type is ";"
      match ";"
      result.push statement()
    (if result.length is 1 then result[0] else result)

  statement = ->
    result = null
    if lookahead and lookahead.type is "ID"
      left =
        type: "ID"
        value: lookahead.value
      match "ID"
      match "="
      right = expression()
      result =
        type: "="
        left: left
        right: right
    else if lookahead and lookahead.type is "P"
      match "P"
      right = expression()
      result =
        type: "PRINT"
        value: right
    else if lookahead and lookahead.type is "CALL"
      match "CALL"
      result =
        type: "CALL"
        value: lookahead.value
      match "ID"
    else if lookahead and lookahead.type is "BEGIN"
      match "BEGIN"
      result = [statement()]
      while lookahead and lookahead.type is ";"
        match ";"
        result.push statement()
      match "END"
    else if lookahead and lookahead.type is "IF"
      match "IF"
      left = condition()
      match "THEN"
      right = statement()
      result =
        type: "IF"
        cond: left
        oper: right
    else if lookahead and lookahead.type is "WHILE"
      match "WHILE"
      left = condition()
      match "DO"
      right = statement()
      result =
        type: "WHILE"
        cond: left
        oper: right
    else
      throw "Syntax Error. Expected identifier but found " +
            (if lookahead then lookahead.value else "end of input") +
            " near '#{input.substr(lookahead.from)}'"
    result

  condition = ->
    if lookahead and lookahead.type is "ODD"
      match "ODD"
      right = expression()
      result =
        type: "ODD"
        value: right
    else
        left = expression()
        type = lookahead.value
        match "COMPARISON"
        right = expression()
        result =
          type: type
          left: left
          right: right
    result

  expression = ->
    result = term()
    while lookahead and lookahead.type is "ADDOP"
      type = lookahead.value
      match "ADDOP"
      right = term()
      result =
        type: type
        left: result
        right: right
    result

  term = ->
    result = factor()
    while lookahead and lookahead.type is "MULTOP"
      type = lookahead.value
      match "MULTOP"
      right = factor()
      result =
        type: type
        left: result
        right: right
    result

  factor = ->
    result = null

    if lookahead.type is "NUM"
      result =
        type: "NUM"
        value: lookahead.value
      match "NUM"

    else if lookahead.type is "ID"
      result =
        type: "ID"
        value: lookahead.value
      match "ID"

    else if lookahead.type is "("
      match "("
      result = expression()
      match ")"

    else
      throw "Syntax Error. Expected number or identifier or '(' but found " +
            (if lookahead then lookahead.value else "end of input") +
            " near '" + input.substr(lookahead.from) + "'"
    result

  tree = program(input)
  if lookahead?
    throw "Syntax Error parsing statements. " +
          "Expected 'end of input' and found '" +
          input.substr(lookahead.from) + "'"
  tree

# Make a test_main function visible to tests
root = exports ? this
root.test_main = (text) ->
  source = text
  try
    result = JSON.stringify(parse(source), null, 2)
  catch result
    result = "<div class=\"error\">" + result + "</div>"
  return result.replace /\n/g,''
