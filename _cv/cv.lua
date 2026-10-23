-- Renders the CV and publication list from data/cv.yml and data/publications.bib.
--
-- Shortcodes:
--   {{< cv-section NAME >}}   one section (website: Markdown; PDF: Typst)
--   {{< cv-document >}}       the whole PDF CV, sections ordered by
--                             layouts[<cv-variant>] in cv.yml
--   {{< cv-publications >}}   website publication list grouped by year

local stringify = pandoc.utils.stringify

---------------------------------------------------------------------------
-- Data loading
---------------------------------------------------------------------------

local function read_file(path)
  local f = assert(io.open(path, "r"), "cannot open " .. path)
  local content = f:read("a")
  f:close()
  return content
end

-- Plain Lua tables from YAML: let pandoc parse it as front matter, then
-- turn every leaf back into its Markdown source text.
local function meta_to_lua(v)
  local t = pandoc.utils.type(v)
  if t == "List" then
    local out = {}
    for i, x in ipairs(v) do out[i] = meta_to_lua(x) end
    return out
  elseif t == "Meta" or t == "table" then
    local out = {}
    for k, x in pairs(v) do out[k] = meta_to_lua(x) end
    return out
  elseif t == "Inlines" or t == "Blocks" then
    return pandoc.write(pandoc.Pandoc(t == "Inlines" and { pandoc.Plain(v) } or v), "markdown",
      { wrap_text = "none" }):gsub("\n+$", "")
  elseif t == "boolean" or t == "string" or t == "number" then
    return v
  end
  return stringify(v)
end

local cv_cache
local function cv_data()
  if not cv_cache then
    local yaml = read_file(quarto.utils.resolve_path("../data/cv.yml"))
    local doc = pandoc.read("---\n" .. yaml .. "\n---\n", "markdown")
    cv_cache = meta_to_lua(doc.meta)
  end
  return cv_cache
end

-- Minimal BibTeX reader: @type{key, field = {value}, ...}. Keeps every
-- field (including custom ones such as code/preprint/status) and file order.
local pubs_cache
local function publications()
  if pubs_cache then return pubs_cache end
  local src = read_file(quarto.utils.resolve_path("../data/publications.bib"))
  src = src:gsub("\n%%[^\n]*", "\n"):gsub("^%%[^\n]*", "")
  local entries = {}
  for etype, body in src:gmatch("@(%w+)%s*(%b{})") do
    body = body:sub(2, -2)
    local key, rest = body:match("^%s*([^,%s]+)%s*,(.*)$")
    local e = { type = etype:lower(), key = key }
    local pos = 1
    while true do
      local s, e2, name = rest:find("([%w_%-]+)%s*=%s*", pos)
      if not s then break end
      local value
      local c = rest:sub(e2 + 1, e2 + 1)
      if c == "{" then
        local b = rest:match("^%b{}", e2 + 1)
        value, pos = b:sub(2, -2), e2 + 1 + #b
      elseif c == '"' then
        local q = rest:match('^"[^"]*"', e2 + 1)
        value, pos = q:sub(2, -2), e2 + 1 + #q
      else
        value = rest:match("^[^,}%s]+", e2 + 1)
        pos = e2 + 1 + #value
      end
      e[name:lower()] = value:gsub("%s+", " ")
    end
    local authors = {}
    for a in (e.author .. " and "):gmatch("(.-)%s+and%s+") do
      local family, given = a:match("^%s*(.-)%s*,%s*(.-)%s*$")
      authors[#authors + 1] = { family = family or a, given = given or "" }
    end
    e.authors = authors
    entries[#entries + 1] = e
  end
  pubs_cache = entries
  return entries
end

---------------------------------------------------------------------------
-- Formatting helpers
---------------------------------------------------------------------------

local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

-- "10.2022" -> month number, year
local function parse_date(d)
  if not d then return nil end
  local m, y = d:match("^(%d%d?)%.(%d%d%d%d)$")
  if m then return tonumber(m), y end
  return nil, d
end

-- style: "web" (Oct 2022–present), "pdf" (Oct 2022 – Present), "year" (2022–present)
local function date_range(start, finish, style)
  local dash = style == "pdf" and " – " or "–"
  local present = style == "pdf" and "Present" or "present"
  local sm, sy = parse_date(start)
  local function one(m, y)
    if style == "year" or not m then return y end
    return months[m] .. " " .. y
  end
  if not finish then return one(sm, sy) end
  if finish == "Present" then return one(sm, sy) .. dash .. present end
  local em, ey = parse_date(finish)
  if style ~= "year" and sy == ey and sm and em then
    return months[sm] .. dash .. months[em] .. " " .. ey
  end
  return one(sm, sy) .. dash .. one(em, ey)
end

local function initials(given)
  local out = ""
  for part in given:gmatch("[^%s%-%.]+") do out = out .. part:sub(1, 1) end
  return out
end

local function is_me(a)
  local fam, giv = cv_data().me:match("^(.-),%s*(.*)$")
  return a.family == fam and a.given == giv
end

-- Author list as Markdown. Long lists keep the first five, me and the last two.
local function author_list(authors, style)
  local function name(a)
    local n = style == "web" and (initials(a.given) .. " " .. a.family) or (a.given .. " " .. a.family)
    if not is_me(a) then return n end
    return style == "web" and ("[" .. n .. "]{.me}") or ("**" .. n .. "**")
  end
  local n = #authors
  local parts = {}
  if n <= 10 then
    for _, a in ipairs(authors) do parts[#parts + 1] = name(a) end
  else
    for i = 1, 5 do parts[#parts + 1] = name(authors[i]) end
    for i = 6, n - 2 do
      if is_me(authors[i]) then
        parts[#parts + 1] = "…"
        parts[#parts + 1] = name(authors[i])
      end
    end
    parts[#parts + 1] = "…"
    parts[#parts + 1] = name(authors[n - 1])
    parts[#parts + 1] = name(authors[n])
  end
  return table.concat(parts, ", ")
end

local function venue(p)
  local v = "*" .. p.journal .. "*"
  if p.volume then
    v = v .. " " .. p.volume .. (p.number and ("(" .. p.number .. ")") or "")
    if p.pages then v = v .. ", " .. p.pages:gsub("%-%-", "–") end
  end
  return v
end

local function pub_links(p)
  local links = {}
  if p.preprint then links[#links + 1] = { "Preprint", p.preprint } end
  if p.url or (p.doi and not p.preprint) then
    links[#links + 1] = { "Paper", p.url or ("https://doi.org/" .. p.doi) }
  end
  if p.pdf then links[#links + 1] = { "PDF", p.pdf } end
  if p.code then links[#links + 1] = { "Code", p.code } end
  return links
end

local function join_nonempty(list, sep)
  local out = {}
  for _, x in ipairs(list) do if x and x ~= "" then out[#out + 1] = x end end
  return table.concat(out, sep)
end

local function md_blocks(md)
  return pandoc.read(md, "markdown").blocks
end

---------------------------------------------------------------------------
-- Website (Markdown) rendering, matching the existing page structure
---------------------------------------------------------------------------

local web_titles = {
  affiliations = "Affiliations", education = "Education", publications = "Publications",
  talks = "Talks", teaching = "Teaching", skills = "Skills", grants = "Awards & Grants",
  languages = "Languages", summary = "Summary",
}

local function web_row(left, lines)
  return "::: {.cv-row}\n[" .. left .. "]{.cv-date}\n\n::: {}\n" ..
      table.concat(lines, "\\\n") .. "\n:::\n:::\n"
end

local function web_section(name)
  local cv = cv_data()
  local out = { "## " .. web_titles[name] .. "\n" }
  local items = cv[name] or {}
  if name == "languages" then
    local langs = {}
    for _, l in ipairs(items) do langs[#langs + 1] = l.title end
    out[#out + 1] = table.concat(langs, ", ") .. "\n"
  elseif name == "summary" then
    out[#out + 1] = cv.summary .. "\n"
  else
    for _, e in ipairs(items) do
      local lines, left
      if name == "skills" then
        left = e.title
        lines = { table.concat(e.details or {}, "; ") }
      else
        left = date_range(e.start, e["end"], name == "education" and "year" or "web")
        local head = "**" .. (e.url and ("[" .. e.title .. "](" .. e.url .. ")") or e.title) .. "**"
        if name == "talks" and e.location then head = head .. ", " .. e.location end
        lines = { head }
        if name ~= "talks" and (e.org or e.location) then
          lines[#lines + 1] = join_nonempty({ e.org, e.location }, ", ")
        end
        local details = e["web-details"] or (name ~= "education" and e.details) or {}
        for _, d in ipairs(details) do lines[#lines + 1] = d end
      end
      out[#out + 1] = web_row(left, lines)
    end
  end
  return md_blocks(table.concat(out, "\n"))
end

local function web_publications()
  local by_year, years = {}, {}
  for _, p in ipairs(publications()) do
    if not by_year[p.year] then
      by_year[p.year] = {}
      years[#years + 1] = p.year
    end
    table.insert(by_year[p.year], p)
  end
  local out = {}
  for _, y in ipairs(years) do
    local entries = {}
    for _, p in ipairs(by_year[y]) do
      local meta
      if p.journal == "bioRxiv" or p.journal == "medRxiv" or p.journal == "arXiv" then
        meta = "*" .. p.journal .. "* (preprint" .. (p.status and (", " .. p.status) or "") .. ")"
      else
        meta = venue(p) .. (p.status and (" (" .. p.status .. ")") or "")
      end
      local pills = {}
      for _, l in ipairs(pub_links(p)) do pills[#pills + 1] = "[" .. l[1] .. "](" .. l[2] .. "){.pill}" end
      entries[#entries + 1] = "::: {.entry}\n[" .. p.title .. "]{.entry-title}\\\n" ..
          author_list(p.authors, "web") .. "\\\n[" .. meta .. "]{.entry-meta}\\\n" ..
          table.concat(pills, "\n") .. "\n:::\n"
    end
    out[#out + 1] = "::: {.pub-year}\n## " .. y .. "\n\n::: {.pub-list}\n" ..
        table.concat(entries, "\n") .. ":::\n:::\n"
  end
  return md_blocks(table.concat(out, "\n"))
end

---------------------------------------------------------------------------
-- PDF (Typst) rendering
---------------------------------------------------------------------------

-- Markdown -> Typst markup, escaped by pandoc's Typst writer
local function ty(md)
  if not md or md == "" then return "[]" end
  local doc = pandoc.read(md, "markdown")
  local blocks = doc.blocks
  if #blocks == 1 and (blocks[1].t == "Para" or blocks[1].t == "Plain") then
    blocks = { pandoc.Plain(blocks[1].content) }
  end
  local s = pandoc.write(pandoc.Pandoc(blocks), "typst"):gsub("\n+$", "")
  return "[" .. s .. "]"
end

local function ty_list(list)
  local parts = {}
  for _, d in ipairs(list or {}) do parts[#parts + 1] = ty(d) end
  if #parts == 0 then return "()" end
  return "(" .. table.concat(parts, ", ") .. ",)"
end

local pdf_titles = web_titles

local function raw(s) return pandoc.RawBlock("typst", s) end

local function pdf_section(name)
  local cv = cv_data()
  local blocks = { raw("== " .. pdf_titles[name]) }
  if name == "summary" then
    blocks[#blocks + 1] = raw("#cv-summary(" .. ty(cv.summary) .. ")")
    return blocks
  end
  if name == "publications" then
    local items = {}
    for _, p in ipairs(publications()) do
      local links = {}
      for _, l in ipairs(pub_links(p)) do links[#links + 1] = "[" .. l[1] .. "](" .. l[2] .. ")" end
      local md = author_list(p.authors, "pdf") .. ". " .. p.title .. ". " .. venue(p) ..
          " (" .. p.year .. ")" .. (p.status and (", " .. p.status) or "") .. "." ..
          (#links > 0 and (" " .. table.concat(links, " · ")) or "")
      items[#items + 1] = ty(md)
    end
    blocks[#blocks + 1] = raw("#cv-publications((" .. table.concat(items, ", ") .. ",))")
    return blocks
  end
  if name == "languages" then
    local langs = {}
    for _, l in ipairs(cv.languages) do
      langs[#langs + 1] = l.title .. ((l.details and l.details[1]) and (" (" .. l.details[1]:lower() .. ")") or "")
    end
    blocks[#blocks + 1] = raw("#cv-line(" .. ty(table.concat(langs, ", ")) .. ")")
    return blocks
  end
  if name == "skills" then
    for _, e in ipairs(cv.skills) do
      blocks[#blocks + 1] = raw("#cv-skill(" .. ty(e.title) .. ", " .. ty(table.concat(e.details or {}, "; ")) .. ")")
    end
    return blocks
  end
  for _, e in ipairs(cv[name] or {}) do
    local title = e.url and ("[" .. e.title .. "](" .. e.url .. ")") or e.title
    local sub = join_nonempty({ e.org, e.location }, ", ")
    if name == "teaching" then sub = "" end
    blocks[#blocks + 1] = raw("#cv-entry(" ..
        "title: " .. ty(title) ..
        ", date: " .. ty(date_range(e.start, e["end"], "pdf")) ..
        ", sub: " .. ty(sub) ..
        ", details: " .. ty_list(e.details) .. ")")
  end
  return blocks
end

local function pdf_document(variant)
  local cv = cv_data()
  local contact = {}
  for _, c in ipairs(cv.contact) do contact[#contact + 1] = ty("[" .. c.text .. "](" .. c.url .. ")") end
  local blocks = { raw("#cv-header(" .. ty(cv.name) .. ", (" .. table.concat(contact, ", ") .. ",))") }
  local order = cv.layouts[variant]
  assert(order, "unknown cv-variant '" .. tostring(variant) .. "'")
  for _, name in ipairs(order) do
    for _, b in ipairs(pdf_section(name)) do blocks[#blocks + 1] = b end
  end
  return blocks
end

---------------------------------------------------------------------------

local function is_pdf() return quarto.doc.is_format("typst") end

return {
  ["cv-section"] = function(args)
    local name = stringify(args[1])
    return is_pdf() and pdf_section(name) or web_section(name)
  end,
  ["cv-document"] = function(_, _, meta)
    return pdf_document(stringify(meta["cv-variant"] or "academic"))
  end,
  ["cv-publications"] = function()
    return web_publications()
  end,
}
