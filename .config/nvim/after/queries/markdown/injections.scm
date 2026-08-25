; extends

((fenced_code_block
   (info_string
     (language) @_lang)
   (code_fence_content) @injection.content) @markup.raw.block
  (#any-of? @_lang "mjs" "plain" "js-nolint" "text")
  (#set! injection.language "javascript")
  (#set! injection.combined)
  (#set! injection.include-children))

((fenced_code_block
   (info_string
     (language) @_lang)
   (code_fence_content) @injection.content) @markup.raw.block
  (#any-of? @_lang "webidl")
  (#set! injection.language "typescript")
  (#set! injection.combined)
  (#set! injection.include-children))

((fenced_code_block
   (info_string
     (language) @_lang)
   (code_fence_content) @injection.content) @markup.raw.block
  (#any-of? @_lang "console" "npm" "shell")
  (#set! injection.language "bash")
  (#set! injection.combined)
  (#set! injection.include-children))
