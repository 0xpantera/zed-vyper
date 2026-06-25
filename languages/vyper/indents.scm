(_
  "["
  "]" @end) @indent

(_
  "{"
  "}" @end) @indent

(_
  "("
  ")" @end) @indent

(function_definition) @start.def

(if_statement) @start.if

(for_statement) @start.for

(while_statement) @start.while

(elif_clause) @start.elif

(else_clause) @start.else

(interface_definition) @start.interface

(event_definition) @start.event

(struct_definition) @start.struct

(enum_definition) @start.enum
