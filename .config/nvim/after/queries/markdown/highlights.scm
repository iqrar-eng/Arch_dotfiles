; extends

((paragraph) @conceal
  (#lua-match? @conceal "^%s*:::%s*$")
  (#set! conceal "")
  (#set! conceal_lines ""))

((paragraph) @conceal
  (#lua-match? @conceal "^%s*:::[%a][%w]*%s*$")
  (#set! conceal "")
  (#set! conceal_lines ""))

((paragraph) @conceal
  (#lua-match? @conceal "^%s*{{%s*InheritanceDiagram%s*}}%s*$")
  (#set! conceal "")
  (#set! conceal_lines ""))

((paragraph) @conceal
 (#lua-match? @conceal "^%s*{{%s*EmbedLiveSample%(.-%)%s*}}%s*$")
 (#offset! @conceal -1 0 0 0)
 (#set! conceal "")
 (#set! conceal_lines ""))

((paragraph) @conceal
 (#lua-match? @conceal "^%s*{{InteractiveExample%(.-%)}}%s*$")
 (#set! conceal "")
 (#set! conceal_lines ""))

((atx_heading
   [
     (atx_h1_marker)
     (atx_h2_marker)
     (atx_h3_marker)
     (atx_h4_marker)
     (atx_h5_marker)
     (atx_h6_marker)
   ] @marker
   heading_content: (inline) @conceal)
 (#match? @conceal "^(Specifications|License|Browser?|Browse.*|Compatibility)$")
 (#offset! @conceal -1 0 2 0)
 (#set! @marker conceal "")
 (#set! @conceal conceal "")
 (#set! conceal_lines ""))

((atx_heading
   [
     (atx_h1_marker)
     (atx_h2_marker)
     (atx_h3_marker)
     (atx_h4_marker)
     (atx_h5_marker)
     (atx_h6_marker)
   ] @marker
   heading_content: (inline) @conceal)
 (#match? @conceal "^Result$")
 (#offset! @conceal 0 0 1 0)
 (#set! @marker conceal "")
 (#set! @conceal conceal "")
 (#set! conceal_lines ""))

((minus_metadata) @conceal
 (#set! conceal "")
 (#set! conceal_lines ""))

((link_reference_definition) @conceal
 (#set! conceal "")
 (#set! conceal_lines ""))

((fenced_code_block
   (info_string
     (language) @_lang)
   (code_fence_content) @_content) @markup.raw.block
  (#eq? @_lang "cjs")
  (#offset! @conceal 0 1 0 0)
  (#set! conceal "")
  (#set! conceal_lines ""))

((fenced_code_block
   (info_string) @_info
   (code_fence_content) @_content) @my_mdn_bad_code_example
  (#lua-match? @_info "example%-bad%s*$"))

((fenced_code_block
   (info_string) @_info
   (code_fence_content) @_content) @my_mdn_bad_code_example
  (#lua-match? @_info ".*MongoDB.*"))

((fenced_code_block
   (info_string) @_lang
   (code_fence_content) @injection.content) @my_mdn_bad_code_example
   (#lua-match? @_lang "^jsx?*"))
