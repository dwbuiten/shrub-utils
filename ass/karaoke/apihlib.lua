is_syl_blank = function(syl)
  if syl.duration <= 0 then
    return true
  end
  local t = syl.text_stripped
  if t:len() <= 0 then
    return true
  end
  t = t:gsub("[ \t\n\r]", "")
  t = t:gsub("　", "")
  return t:len() <= 0
end

karaskel.ext_preproc_line = function(subs, meta, styles, line)
  karaskel.preproc_line(subs, meta, styles, line)
  local curblank, curspace, ci = 0, 0, 1
  line.chars = {}
  for i = 1, #line.kara do
    local syl = line.kara[i]
    syl.chars = {}
    syl.curblank = curblank
    if is_syl_blank(syl) then
      curblank = curblank + 1
    end
    local left = syl.left - syl.prespacewidth
    for c,j in unicode.chars(syl.text_stripped) do
      local char = table.copy(syl)
      line.chars[ci] = char
      syl.chars[j] = char
      char.basesyl = syl
      char.i = ci
      char.curblank = curspace
      char.text, char.text_stripped, char.text_spacestripped = c, c, c
      char.prespace, char.postspace = "", ""
      char.prespacewidth, char.postspacewidth = 0, 0
      char.width = aegisub.text_extents(line.styleref, char.text)
      char.left = left
      char.center = left + char.width / 2
      char.right = left + char.width
      left = char.right
      ci = ci + 1
      if is_syl_blank(char) then
        curspace = curspace + 1
      end
    end
  end
  line.nchar, line.nblank, line.nspace = unicode.len(line.text_stripped), curblank, curspace
  for i = 1, #line.kara do
    local syl = line.kara[i]
    syl.nsyl = #line.kara
    syl.nblank = line.nblank
    for j = 1, #syl.chars do
      local char = syl.chars[j]
      char.nsyl = line.nchar
      char.nblank = line.nspace
    end
  end
end

set_line_prop = function(line, newlayer, newstart, newend, newactor, neweffect)
  if not newlayer then
    line.layer = line.layer
  end
  if not newstart then
    line.start_time = line.start_time
  end
  if not newend then
    line.end_time = line.end_time
  end
  line.duration = line.end_time - line.start_time
  line.actor = newactor or ""
  line.effect = neweffect or ""
end

time_shifter = function(s, offset, dur)
  local temp1, temp2 = s:match("(.-)(\\t.+)")
  if not temp1 then
    temp1 = s
  end
  local temp = temp1
  if temp2 ~= nil then
    for a,b,c in temp2:gmatch("\\t%((%-?%d+),(%-?%d+),(.-)%)") do
      if tonumber(b + offset) <= 0 then
        temp = c
      else
        if tonumber(b + offset) > 0 and tonumber(a + offset) < dur then
          temp = string.format("%s\\t(%d,%d,%s)", temp, a + offset, b + offset, c)
        end
      end
    end
  end
  return temp
end