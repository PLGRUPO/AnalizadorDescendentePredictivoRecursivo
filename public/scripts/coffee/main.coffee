
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

  tokens =
    WHITES: /\s+/g
    ONELINECOMMENT: /\/\/.*/g
    MULTIPLELINECOMMENT: /\/[*](.|\n)*?[*]\//g
    ID: /[a-zA-Z_]\w*/g
    NUM: /\b\d+(\.\d*)?([eE][+-]?\d+)?\b/g
    STRING: /('(\\.|[^'])*'|"(\\.|[^"])*")/g
    ASSIGNOPERATOR: /:=/g
    COMPARISONOPERATOR: /[<>]=|[<>=#]/g
    ADDSUBOPERATOR: /[+-]/g
    MULTDIVOPERATOR: /[*\/]/g
    ONECHAROPERATOR: /([()&|;:,<>{}[\]])/g

  RESERVED_WORD =
    const: "CONST"
    "var": "VAR"
    procedure: "PROCEDURE"
    call: "CALL"
    begin: "BEGIN"
    end: "END"
    "if": "IF"
    then: "THEN"
    "while": "WHILE"
    "do": "DO"
    odd: "ODD"

  make = (type, value) ->
    type: type
    value: value
    from: from
    to: i

  getTok = ->
    str = m[0]
    i += str.length
    str

  return unless this

  while i < @length
    for key, value of tokens
      value.lastIndex = i

    from = i

    # Espacios en blanco y comentarios se ignoran
    if m = tokens.WHITES.bexec(this) or (m = tokens.ONELINECOMMENT.bexec(this)) or (m = tokens.MULTIPLELINECOMMENT.bexec(this))
      getTok()

    # Identificadores y palabras reservadas
    else if m = tokens.ID.bexec(this)
      rw = RESERVED_WORD[m[0]]
      if rw
        result.push make(rw, getTok())
      else
        result.push make("ID", getTok())

    # Números
    else if m = tokens.NUM.bexec(this)
      n = +getTok()
      if isFinite(n)
        result.push make("NUM", n)
      else
        make("NUM", m[0]).error "Bad number"

    # Cadenas de literales
    else if m = tokens.STRING.bexec(this)
      result.push make("STRING", getTok().replace(/^["']|["']$/g, ""))

    # Operador de asignación
    else if m = tokens.ASSIGNOPERATOR.bexec(this)
      result.push make("ASSIGN", getTok())

    # Operador de comparación
    else if m = tokens.COMPARISONOPERATOR.bexec(this)
      result.push make("COMPARISON", getTok())

    # Operadores de adición y substracción
    else if m = tokens.ADDSUBOPERATOR.bexec(this)
      result.push make("ADDSUB", getTok())

    # Operadores de multiplicación y división
    else if m = tokens.MULTDIVOPERATOR.bexec(this)
      result.push make("MULTDIV", getTok())

    # Operadores de un solo símbolo
    else if m = tokens.ONECHAROPERATOR.bexec(this)
      result.push make(m[0], getTok())
    else
      throw "Syntax error near '" + (@substr(i)) + "'"
  result

parse = (input) ->
  tokens = input.tokens()
  lookahead = tokens.shift()
  match = (t) ->
    if lookahead.type is t
      lookahead = tokens.shift()
      lookahead = null  if typeof lookahead is "undefined"
    else
      throw ("Syntax Error. Expected " + t + " found '") + lookahead.value + "' near '" + input.substr(lookahead.from) + "'"
    return

  # PL/0
  program = ->
    result = block()
    if lookahead and lookahead.type is "."
      match "."
    else
      throw "Error. Expecting '.' to end program"
    result

  block = ->
    result = []
    if lookahead and lookahead.type is "CONST"
      match "CONST"

      if lookahead and lookahead.type is "ID"
        varname = lookahead.value
        match "ID"

        if lookahead and lookahead.type is "ASSIGN"
          match "ASSIGN"

          if lookahead and lookahead.type is "NUMBER"
            numval = lookahead.value
            match "NUMBER"
            result.push (
              type: "CONSTVAR"
              value: numval
            )
            match ";"
          else
            throw "Error. Expecting a number"
        else
          throw "Error. Constants must be initialized"
      else
        throw "Error. Expecting an identifier"


    if lookahead and lookahead.type is "VAR"
      match "VAR"

      if lookahead and lookahead.type is "ID"
        varname = lookahead.value
        match "ID"
        match ";"
        result.push (
          type: "VAR"
          name: varname
        )
      else
        throw "Error. Expecting ID"

    if lookahead and lookahead.type is "PROCEDURE"
      match "PROCEDURE"

      if lookahead and lookahead.type is "ID"
        nvalue = lookahead.value
        match "ID"
        match ";"
        result.push (
          type: "PROCEDURE"
          name: nvalue
          content: block()
        )
        match ";"
      else
        throw "Error. Expecting ID"

    statement()

  statement = ->
    result = []


  # Anterior
  #statements = ->
  #  result = [statement()]
  #  while lookahead and lookahead.type is ";"
  #    match ";"
  #    result.push statement()
  #  if result.length is 1
  #    result[0]
  #  else
  #    result

  #statement = ->
  #  result = null
  #  if lookahead and lookahead.type is "ID"
  #    left =
  #      type: "ID"
  #      value: lookahead.value

  #    match "ID"
  #    match "="
  #    right = expression()
  #    result =
  #      type: "="
  #      left: left
  #      right: right
  #  else if lookahead and lookahead.type is "P"
  #    match "P"
  #    right = expression()
  #    result =
  #      type: "P"
  #      value: right
  #  else if lookahead and lookahead.type is "IF"
  #    match "IF"
  #    left = condition()
  #    match "THEN"
  #    right = statement
  #    result =
  #      type: "IF"
  #      left: left
  #      right: right
  #  else
  #    throw "Syntax Error. Expected identifier but found " + ((if lookahead then lookahead.value else "end of input")) + (" near '" + (input.substr(lookahead.from)) + "'")
  #  result

  #condition = ->
  #  left = expression()
  #  type = lookahead.value
  #  match "COMPARISON"
  #  right = expression()
  #  result =
  #    left: left
  #    right: right
  #    type: type
  #  result

  #expression = ->
  #  result = term()
  #  if lookahead and lookahead.type is "+"
  #    match "+"
  #    right = expression()
  #    result =
  #      type: "+"
  #      left: result
  #      right: right
  #  else if lookahead and lookahead.type is "-"
  #    match "-"
  #    right = expression()
  #    result =
  #      type: "-"
  #      left: result
  #      right: right
  #  result

  #term = ->
  #  result = factor()
  #  if lookahead and lookahead.type is "*"
  #    match "*"
  #    right = term()
  #    result =
  #      type: "*"
  #      left: result
  #      right: right
  #  else if lookahead and lookahead.type is "/"
  #    match "/"
  #    right = term()
  #    result =
  #      type: "/"
  #      left: result
  #      right: right
  #  result

  #factor = ->
  #  result = null
  #  if lookahead.type is "NUM"
  #    result =
  #      type: "NUM"
  #      value: lookahead.value

  #    match "NUM"
  #  else if lookahead.type is "ID"
  #    result =
  #      type: "ID"
  #      value: lookahead.value

  #    match "ID"
  #  else if lookahead.type is "("
  #    match "("
  #    result = expression()
  #    match ")"
  #  else
  #    throw "Syntax Error. Expected number or identifier or '(' but found " + ((if lookahead then lookahead.value else "end of input")) + " near '" + input.substr(lookahead.from) + "'"
  #  result

  #tree = statements(input)
  #throw "Syntax Error parsing statements. " + "Expected 'end of input' and found '" + input.substr(lookahead.from) + "'"  if lookahead?
  #tree