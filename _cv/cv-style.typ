// Layout helpers for the CV, called from the Typst that cv.lua generates.
// ATS-friendly by design: one column, every line is plain selectable text in
// reading order (no tables, images or icons), standard section headings.

#let accent = rgb("#2f5d48")
#let muted = rgb("#5c6670")

#set document(title: "Shubhankar Londhe – CV", author: "Shubhankar Londhe")
// Ligatures (fi, fl) and hyphenation ("biobank-scale" split over two lines)
// both garble words when ATS parsers extract the text
#set text(ligatures: false, hyphenate: false)
#set par(justify: false, leading: 0.6em, spacing: 0.6em)
#set list(indent: 0.2em, body-indent: 0.5em, spacing: 0.45em, marker: text(fill: muted)[•])
#show link: set text(fill: accent)

// Section headings: capitals, accent colour, hairline rule. No letter
// spacing: tracked capitals extract as "P UBLICATIONS" in some parsers.
#show heading.where(level: 2): it => block(above: 1.35em, below: 0.7em, width: 100%)[
  #set text(size: 1.0em, weight: "bold", fill: accent)
  #upper(it.body)
  #v(-0.7em)
  #line(length: 100%, stroke: 0.4pt + accent.lighten(40%))
]

#let cv-header(name, contacts) = {
  // box() keeps each contact item on one line
  let n = contacts.len()
  align(center)[
    #text(size: 2.1em, weight: "bold")[#name]
    #v(-0.2em)
    #text(size: 0.92em)[#contacts.enumerate().map(((i, c)) => box(if i < n - 1 [#c #h(0.35em)|] else [#c])).join(h(0.35em))]
  ]
}

#let cv-summary(body) = block(below: 0.2em)[#body]

#let cv-entry(title: [], date: [], sub: [], details: ()) = block(below: 0.95em, breakable: false)[
  #set par(spacing: 0.4em)
  #set block(spacing: 0.4em)
  // Title and date on one text line, so parsers read them together
  #block[#{ show link: set text(fill: black); text(weight: "bold")[#title] } #h(1fr) #text(fill: muted)[#date]]
  #if sub != [] { block(text(fill: muted, style: "italic")[#sub]) }
  // A single detail reads better as a plain line than as a one-item list
  #if details.len() == 1 { block(details.at(0)) }
  #if details.len() > 1 { list(..details) }
]

#let cv-skill(label, body) = block(below: 0.5em)[#text(weight: "bold")[#label:] #body]

#let cv-line(body) = block(below: 0.4em)[#body]

// Each publication: title on its own line, then authors, venue and links
#let cv-publications(items) = enum(
  spacing: 0.85em,
  ..items.map(((title, meta)) => [
    #text(weight: "bold")[#title] \
    #text(size: 0.95em)[#meta]
  ]),
)
