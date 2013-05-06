name = "Suzumiya Haruhi no Yuuutsu - Hare Hare Yukai - Ending Karaoke"
description = "Karaoke for Suzumiya Haruhi no Yuuutsu ending theme."
version, kind, configuration = 3, 'basic_ass', {}

include("utils.lua")

function process_lines(meta, styles, lines, config)
	local output = {}
	output.n = 0
	math.randomseed(1337) -- just to make sure it's initialised the same every time
	for curline = 0, lines.n-1 do
		local lin = lines[curline]
		if lin.kind == "dialogue" and string.find(lin.style,"HareHare Roomaji") ~= nil then
			doromaji(lin, output, styles[lin.style], meta, curline, false)
		else
			if lin.kind == "dialogue" and string.find(lin.style,"HareHare Kanji") ~= nil then
				doromaji(lin, output, styles[lin.style], meta, curline, true)
			else
				output[output.n] = lin
				output.n = output.n + 1
			end
		end
	end
	return output
end


function doromaji(lin, output, sty, meta, linen, isKanji)
	-- Settings
	local linetop = 25
	if isKanji then
		linetop = 50
	end
	local enterlen = 70
	local leavelen = 30
	local growTime = 4
	local shrinkTime = 10
	local lineEndHaste = 30
	local startWait = 20
	local baseLayer = linen * 100
	
	-- prepare syllable data
	local linewidth = 0
	local syltime = 0
	local syls = {n=0}
	for i = 1, lin.karaoke.n-1 do
		local syl = lin.karaoke[i]
		
		-- Calculate line metrics. Note that this is done twice to account for trailing spaces
		syl.width, syl.height, syl.descent, syl.extlead = aegisub.text_extents(sty, trim(syl.text_stripped))
		syl.trimwidth = syl.width
		syl.width, syl.height, syl.descent, syl.extlead = aegisub.text_extents(sty, syl.text_stripped)
		
		-- Set syllable values
		syl.left = linewidth
		syl.start_time = syltime
		syl.end_time = syltime + syl.duration
		syltime = syltime + syl.duration
		linewidth = linewidth + syl.width + 1
		syls[syls.n] = syl
		syls.n = syls.n + 1
	end
	
	-- Calculate initial line offset
	local lineofs = math.floor((meta.res_x - linewidth) / 2)
	
	-- Colour table
	local hueTable = {
		[0] = 134,
		[1] = 10,
		[2] = 37,
		[3] = 85,
		[4] = 31,
		[5] = 124,
		[6] = 223,
		[7] = 100,
		[8] = 10,
		[9] = 136,
		[10] = 23,
		[11] = 38,
		[12] = 75,
		[13] = 162,
		[14] = 0,
		[15] = 0,
	}
	
	-- Colour calculation
	local firstLine = 1
	if isKanji then
		firstLine = 16
	end
	local indexn = linen - firstLine
	local r,g,b
	r,g,b = HSV_to_RGB(hueTable[indexn]*3/2,30.0/255.0,245.0/255.0)
	local highColour = ass_color(r,g,b)
    r,g,b = HSV_to_RGB(hueTable[indexn]*3/2,130.0/255.0,210.0/255.0)
	local baseColour = ass_color(r,g,b)
	r,g,b = HSV_to_RGB(hueTable[indexn]*3/2,180.0/255.0,190.0/255.0)
	local dimColour = ass_color(r,g,b)
	indexn = indexn + 1
    r,g,b = HSV_to_RGB(hueTable[indexn]*3/2,130.0/255.0,210.0/255.0)
	local nextBaseColour = ass_color(r,g,b)
	r,g,b = HSV_to_RGB(hueTable[indexn]*3/2,180.0/255.0,190.0/255.0)
	local nextDimColour = ass_color(r,g,b)
	local fontSize = sty.fontsize
	
	for i = 0, syls.n-1 do
		-- Setup
		local syl = syls[i]
		local startx, starty
		startx = syl.left+lineofs+(syl.trimwidth/2)
		starty = linetop
		local kanjiMod = 0
		if isKanji then
			kanjiMod = 53
		end
		local angle = math.rad(75 + linen*78 + i*10 + math.random(-3,3) + kanjiMod)
		local amp = 90 + math.random(-10,10)
		local dx = amp * math.cos(angle)
		local dy = -amp * math.sin(angle)

		-- Enter
		local enterlin = copy_line(lin)
		enterlin.layer = baseLayer
		enterlin.start_time = lin.start_time - enterlen
		enterlin.end_time = lin.start_time - startWait
		enterlin.text = string.format("{\\move(%i,%i,%i,%i)\\fad(%i,0)\\c%s}%s",startx+dx,starty+dy,startx,starty,enterlen*10,baseColour,syl.text)
		output[output.n] = enterlin
		output.n = output.n + 1
		
		-- Data
		local sylStart = syl.start_time
		local sylDur = syl.duration
		local sylEnd = sylStart + sylDur
		
		-- Before effect
		local beforelin = copy_line(lin)
		beforelin.layer = baseLayer
		beforelin.start_time = lin.start_time - startWait
		beforelin.end_time = lin.start_time + sylStart - growTime
		beforelin.text = string.format("{\\pos(%i,%i)\\c%s}%s",startx,starty,baseColour,syl.text)
		output[output.n] = beforelin
		output.n = output.n + 1
		
		-- Effect
		local effectlin = copy_line(lin)
		effectlin.layer = 1 + baseLayer
		effectlin.start_time = lin.start_time + sylStart - growTime
		effectlin.end_time = lin.start_time + sylEnd + shrinkTime
		effectlin.text = string.format("{\\pos(%i,%i)\\c%s",startx,starty,baseColour)
		effectlin.text = effectlin.text .. string.format("\\t(0,%i,\\fscx120\\fscy150\\c&%s&)",growTime * 10,highColour)
		effectlin.text = effectlin.text .. string.format("\\t(%i,%i,\\fscx80\\fscy100\\c&%s&)",(growTime+sylDur)*10,(growTime+sylDur+shrinkTime)*10,baseColour)
		effectlin.text = effectlin.text .. "}" .. syl.text
		output[output.n] = effectlin
		output.n = output.n + 1
		
		-- After Effect
		local afterlin = copy_line(lin)
		afterlin.layer = baseLayer
		afterlin.start_time = lin.start_time + sylEnd + shrinkTime
		afterlin.end_time = lin.end_time - lineEndHaste
		afterlin.text = string.format("{\\pos(%i,%i)\\c%s\\t(\\c&%s&)}%s",startx,starty,dimColour,nextDimColour,syl.text)
		output[output.n] = afterlin
		output.n = output.n + 1
		
		-- Leave
		local leavelin = copy_line(lin)
		leavelin.layer = baseLayer
		leavelin.start_time = lin.end_time - lineEndHaste
		leavelin.end_time = lin.end_time + leavelen - math.random(0,10)
		local ampmod = math.random(40,70)
		leavelin.text = string.format("{\\move(%i,%i,%i,%i)\\c%s\\fad(0,%i)}%s",startx,starty,startx+(dx*ampmod/100),starty+(dy*ampmod/100),nextDimColour,leavelen*10,syl.text)
		output[output.n] = leavelin
		output.n = output.n + 1
	end
end