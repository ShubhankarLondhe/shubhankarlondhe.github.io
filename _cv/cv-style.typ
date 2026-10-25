// Layout helpers for the CV, called from the Typst that cv.lua generates.
// ATS-friendly by design: one column, every line is plain selectable text in
// reading order (no tables, images or icons), standard section headings.

#let accent = rgb("#3f7259")
#let muted = rgb("#5f6f65")

#set document(title: "Shubhankar Londhe – CV", author: "Shubhankar Londhe")
// Ligatures (fi, fl) can extract as odd glyphs in some ATS parsers
#set text(ligatures: false)
#set par(justify: false, leading: 0.55em)
#set list(indent: 0.6em, body-indent: 0.4em, spacing: 0.35em)
#show link: set text(fill: accent)

#show heading.where(level: 2): it => block(above: 1.0em, below: 0.55em, width: 100%)[
  #set text(size: 1.12em, weight: "bold", fill: black)
  #it.body
  #v(-0.65em)
  #line(length: 100%, stroke: 0.5pt + accent)
]

#let cv-header(name, contacts) = {
  align(center)[
    #text(size: 2.0em, weight: "bold")[#name]
    #v(-0.3em)
    // box() keeps each contact item on one line
    #let n = contacts.len()
    #text(size: 0.9em)[#contacts.enumerate().map(((i, c)) => box(if i < n - 1 [#c #h(0.3em)·] else [#c])).join(h(0.3em))]
  ]
}

#let cv-summary(body) = block(below: 0.5em)[#body]

#let cv-entry(title: [], date: [], sub: [], details: ()) = block(below: 0.75em, breakable: false)[
  #set par(spacing: 0.5em)
  #set block(spacing: 0.5em)
  #set list(spacing: 0.5em)
  // Title and date on one text line, so parsers read them together
  #block[#{ show link: set text(fill: black); text(weight: "bold")[#title] } #h(1fr) #text(fill: muted)[#date]]
  #if sub != [] { text(style: "italic")[#sub] }
  #if details.len() > 0 { list(..details) }
]

#let cv-skill(label, body) = block(below: 0.45em)[#text(weight: "bold")[#label:] #body]

#let cv-line(body) = block(below: 0.4em)[#body]

#let cv-publications(items) = enum(spacing: 0.55em, ..items)
