// Layout helpers for the CV, called from the Typst that cv.lua generates.
// ATS-friendly by design: one column, every line is plain selectable text in
// reading order (no tables, images or icons), standard section headings.
// Font: Source Sans 3 (SIL Open Font License), bundled in _cv/fonts/.

#let ink = rgb("#1f2328")
#let accent = rgb("#2f5d48")
#let muted = rgb("#5f6b76")
#let rule = rgb("#d5dbd7")
// Width reserved for dates on the right (fits "Aug 2017 – May 2022")
#let date-column = 8.5em

#set document(title: "Shubhankar Londhe – CV", author: "Shubhankar Londhe")
// Ligatures (fi, fl) and hyphenation both garble words when ATS parsers
// extract the text
#set text(fill: ink, ligatures: false, hyphenate: false)
#set par(justify: false, leading: 0.68em, spacing: 0.7em)
#set list(indent: 0.1em, body-indent: 0.55em, spacing: 0.5em, marker: text(fill: muted)[•])
#show strong: set text(weight: "semibold")
#show link: set text(fill: accent)
// Keep each link on one line (e.g. "ukbb-utils-gagneur" must not split)
#show link: box

// Section headings: capitals in the accent colour above a light rule. No
// letter spacing: tracked capitals extract as "P UBLICATIONS" in some parsers.
#show heading.where(level: 2): it => block(above: 1.7em, below: 0.85em, width: 100%)[
  #set text(size: 1.0em, weight: "semibold", fill: accent)
  #upper(it.body)
  #v(-0.6em)
  #line(length: 100%, stroke: 0.6pt + rule)
]

#let cv-header(name, contacts) = {
  // Contacts on one line, or two balanced lines if there are more than three
  let sep = [#h(0.5em)#text(fill: rule)[|]#h(0.5em)]
  let half = calc.ceil(contacts.len() / 2)
  align(center)[
    #text(size: 2.3em, weight: "semibold")[#name]
    #v(0.1em)
    #text(size: 0.95em, fill: muted)[
      #if contacts.len() <= 3 { contacts.join(sep) } else [
        #contacts.slice(0, half).join(sep) \
        #contacts.slice(half).join(sep)
      ]
    ]
  ]
  v(0.4em)
}

#let cv-summary(body) = block(below: 0.2em)[#body]

#let cv-entry(title: [], date: [], lead: [], sub: [], details: (), strong: false) = block(below: 1.1em, breakable: false)[
  #set par(spacing: 0.45em)
  #set block(spacing: 0.45em)
  // Title and date on one text line, so parsers read them together
  #block[#{
      show link: set text(fill: ink)
      text(weight: if strong { "semibold" } else { "regular" })[#title]
    } #h(1fr) #text(fill: muted, size: 0.95em)[#date]]
  // Everything below the title stops short of the date column, so long lines
  // wrap instead of running under the dates
  #pad(right: date-column)[
    // Optional second line, e.g. the supervisor or host
    #if lead != [] { block(lead) }
    #if sub != [] { block(sub) }
    // Details in grey; a single detail reads better as a plain line than as
    // a one-item list
    #if details.len() == 1 { block(text(fill: muted)[#details.at(0)]) }
    #if details.len() > 1 { v(0.15em); text(fill: muted, list(..details)) }
  ]
]

#let cv-skill(label, body) = block(below: 0.6em)[#text(weight: "semibold")[#label:] #body]

#let cv-line(body) = block(below: 0.4em)[#body]

// Each publication: title, then authors, venue and links in grey
#let cv-publications(items) = enum(
  spacing: 1.0em,
  numbering: n => text(fill: muted)[#n.],
  ..items.map(((title, meta)) => [
    #title \
    #text(size: 0.93em, fill: muted)[#meta]
  ]),
)
