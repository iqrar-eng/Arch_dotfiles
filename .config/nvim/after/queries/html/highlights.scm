; extends

((element
  (self_closing_tag
    (tag_name) @tag) @conceal)
  (#any-of? @tag "Image" "TypeTable" "InlineToc" "Solution" "Youtube")
  (#offset! @conceal 0 0 1 0)
  (#set! conceal_lines ""))

((start_tag
   (tag_name) @tag) @conceal
  (#any-of? @tag "Callout" "CalloutContainer" "CalloutDescription" "Cards" "Card" "Steps" "RSC" "ConsoleBlock" "Pitfall" "Sandpack" "Recipes" "Note" "Intro" "Step")
  (#set! conceal "")
  (#set! conceal_lines ""))

((end_tag
   (tag_name) @tag) @conceal
  (#any-of? @tag "Callout" "CalloutContainer" "CalloutDescription" "Cards" "Card" "Steps" "RSC" "ConsoleBlock" "Pitfall" "Sandpack" "Recipes" "Note" "Intro" "Step")
  (#set! conceal "")
  (#set! conceal_lines ""))

((start_tag
   (tag_name) @tag) @conceal
  (#any-of? @tag "details")
  (#offset! @conceal 0 0 1 0)
  (#set! conceal "")
  (#set! conceal_lines ""))

((end_tag
   (tag_name) @tag) @conceal
  (#any-of? @tag "details")
  (#offset! @conceal 0 0 1 0)
  (#set! conceal "")
  (#set! conceal_lines ""))

((comment) @conceal
  (#set! conceal "")
  (#offset! @conceal 0 0 1 0)
  (#set! conceal_lines ""))
