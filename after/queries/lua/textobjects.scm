;; Functions declared with `function name() ... end`
(function_declaration) @function.outer
(function_declaration) @function.inner

;; Anonymous/local functions assigned to variables or table fields
(function_definition) @function.outer
(function_definition) @function.inner
