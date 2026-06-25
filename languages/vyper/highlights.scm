; Minimal Vyper highlighting for tree-sitter-vyper.

(comment) @comment

(identifier) @variable

((identifier) @type
  (#match? @type "^[A-Z].*[a-z]"))

((identifier) @constant
  (#match? @constant "^[A-Z][A-Z0-9_]*$"))

((identifier) @constant.builtin
  (#match? @constant.builtin "^__[a-zA-Z0-9_]*__$"))

[(true) (false)] @boolean
(none) @constant.builtin
(integer) @number
(float) @number
(string) @string
(escape_sequence) @string.escape
(interpolation) @none

(decorator) @attribute
(decorator (identifier) @attribute)
(decorator (call function: (identifier) @attribute))
(decorator (attribute attribute: (identifier) @attribute))

(function_definition
  name: (identifier) @function)

(function_definition
  name: (identifier) @constructor
  (#any-of? @constructor "__init__"))

(call
  function: (identifier) @function.call)

(call
  function: (attribute
    attribute: (identifier) @function.method))

((call function: (identifier) @constructor)
  (#match? @constructor "^[A-Z]"))

(interface_definition
  name: (identifier) @type)

(interface_sig
  name: (identifier) @function.method)

(interface_sig
  mutability: (identifier) @keyword)

(struct_definition
  name: (identifier) @type)

(event_definition
  name: (identifier) @type)

(event_definition
  body: (block
    (expression_statement
      (assignment
        left: (identifier) @property))))

(enum_definition
  name: (identifier) @type)

(enum_members
  (identifier) @variant)

(type (identifier) @type)
(type
  (subscript
    (identifier) @type))

(parameters (identifier) @variable.parameter)
(typed_parameter (identifier) @variable.parameter)
(default_parameter name: (identifier) @variable.parameter)
(typed_default_parameter (identifier) @variable.parameter)
(keyword_argument name: (identifier) @variable.parameter)
(lambda_parameters (identifier) @variable.parameter)

(assignment
  left: (identifier) @property
  type: (type))

(attribute
  attribute: (identifier) @property)

((identifier) @variable.special
  (#any-of? @variable.special "self" "msg" "block" "tx" "chain"))

((call function: (identifier) @function.builtin)
  (#any-of? @function.builtin
    "_abi_decode" "_abi_encode" "abs" "as_wei_value" "bitwise_and" "bitwise_not"
    "bitwise_or" "bitwise_xor" "blockhash" "ceil" "concat" "convert"
    "create_copy_of" "create_from_blueprint" "create_minimal_proxy_to" "ecadd"
    "ecmul" "ecrecover" "empty" "extract32" "floor" "isqrt" "keccak256"
    "len" "max" "max_value" "method_id" "min" "min_value" "pow_mod256"
    "raw_call" "raw_log" "send" "sha256" "shift" "slice" "sqrt"
    "uint256_addmod" "uint256_mulmod" "uint2str" "unsafe_add" "unsafe_div"
    "unsafe_mul" "unsafe_sub" "indexed" "public" "constant" "immutable"))

[
  "def"
  "lambda"
] @keyword.function

[
  "assert"
  "pass"
  "as"
  "log"
  "event"
  "struct"
  "interface"
  "enum"
] @keyword

(import_from_statement "from" @keyword.import)
"import" @keyword.import
(aliased_import "as" @keyword.import)

[
  "if"
  "elif"
  "else"
] @keyword.conditional

[
  "for"
  "while"
  "break"
  "continue"
] @keyword.repeat

[
  "return"
] @keyword.return

[
  "raise"
] @keyword.exception

[
  "and"
  "or"
  "not"
  "is"
  "in"
  "del"
] @keyword.operator

[
  "=" "==" "!=" "<" "<=" ">" ">="
  "+" "+=" "-" "-=" "*" "**" "*=" "/" "//" "/=" "%" "%="
  "&" "&=" "|" "|=" "^" "^=" "~" "<<" "<<=" ">>" ">>=" "->" "@" "@="
] @operator

["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["," "." ":" ";" (ellipsis)] @punctuation.delimiter

(ERROR) @error
