(function_definition) @function.around
(function_definition body: (block) @function.inside)

(interface_definition) @class.around
(interface_definition body: (_) @class.inside)

(struct_definition) @class.around
(struct_definition body: (block) @class.inside)

(event_definition) @class.around
(event_definition body: (block) @class.inside)

(comment)+ @comment.around
