; extends
((call_expression
  function: (identifier) @_fn
  arguments: (template_string (string_fragment) @injection.content))
 (#eq? @_fn "css")
 (#set! injection.language "css"))

