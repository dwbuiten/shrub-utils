-- Aegisub Automation 4 Lua script
-- based on Automation 4 Script Template revision 2
-- written by Mohd. Hafizuddin B. M. Marzuki

include("karaskel.lua")
include("apihlib.lua")

script_name = "Moyashimon OP"
script_description = "Moyashimon OP karaoke effects"
script_author = "Mohd. Hafizuddin B. M. Marzuki"
script_version = "1.0"


function main(subs)
	math.randomseed(4706)
	
	local meta, styles = karaskel.collect_head(subs)
	local maxi = #subs
	
	for i = 1, maxi do
		local line = subs[i]
		
		if line.class == "dialogue" and not line.comment then
			if line.style:find("Romaji") or line.style:find("Kanji") then
				karaskel.ext_preproc_line(subs, meta, styles, line)
				do_kara(subs, meta, line)
			elseif line.style:find("Trans") then
				karaskel.ext_preproc_line(subs, meta, styles, line)
				do_trans(subs, meta, line)
			end
		end
		
		line = subs[i]
		line.comment = true
		subs[i] = line
	end
end

function do_kara(subs, meta, line)
	local nl = table.copy(line)
	
	local rotpath, dir, leadin = "\\frz-10", 1, 800
	for i = 1, math.ceil((line.duration+leadin+400)/1000) do
		rotpath = string.format("%s\\t(%d,%d,\\frz%d)", rotpath, ((i-1)*1000)-leadin, (i*1000)-leadin, dir*10)
		dir = -dir
	end
	
	for i = 1, #line.chars do
		local syl = line.chars[i]

		if not is_syl_blank(syl) then
			syl.x, syl.y = line.left + syl.center, line.middle
			
			nl.start_time = line.start_time-800+(syl.basesyl.i-syl.basesyl.curblank-1)*50
			set_line_prop(nl, 1, _, nl.start_time+750)
			nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)\\be1\\fad(750,0)\\1c%s%s\\fscx0\\fscy0\\t(0.8,\\fscx%d\\fscy%d)}%s", syl.x+math.random(-50,50), syl.y+math.random(-50,50), syl.x, syl.y, line.styleref.color2, time_shifter(rotpath, 800-(syl.basesyl.i-syl.basesyl.curblank-1)*50, nl.duration), line.styleref.scale_x, line.styleref.scale_y, syl.text_spacestripped)
			subs.append(nl)
			
			set_line_prop(nl, 1, nl.end_time, line.start_time+syl.start_time)
			nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\1c%s%s}%s", syl.x, syl.y, line.styleref.color2, time_shifter(rotpath, 50-(syl.basesyl.i-syl.basesyl.curblank-1)*50, nl.duration), syl.text_spacestripped)
			subs.append(nl)
			
			set_line_prop(nl, 0, line.start_time+syl.start_time, line.end_time+400)
			nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\bord%g\\fad(0,400)\\3c%s\\1a&HFF&\\3a&H60&%s}%s", syl.x, syl.y, line.styleref.outline*1.4, line.styleref.color4, time_shifter(rotpath, -syl.start_time, nl.duration), syl.text_spacestripped)
			subs.append(nl)
			
			nl.layer = 1
			nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\fad(0,400)\\1a&HFF&%s}%s", syl.x, syl.y, time_shifter(rotpath, -syl.start_time, nl.duration), syl.text_spacestripped)
			subs.append(nl)
			
			local clipsize = 1
			local sclip, eclip = 0, line.height-clipsize
			for j = sclip, eclip, clipsize do
				local clipcolor = interpolate_color((j-sclip)/(eclip-sclip), line.styleref.color2, line.styleref.color1)
				if line.style:find("Kanji") then clipcolor = interpolate_color((j-sclip)/(eclip-sclip), line.styleref.color1, line.styleref.color2) end
				local clipx1, clipy1, clipx2, clipy2 = 0, line.top+j, meta.res_x, line.top+j+clipsize
				if j == sclip then clipy1 = 0 elseif j == eclip then clipy2 = meta.res_y end
				
				nl.text = string.format("\\be1\\bord0\\fad(0,400)\\1c%s\\clip(%d,%d,%d,%d)%s", clipcolor, clipx1, clipy1, clipx2, clipy2, time_shifter(rotpath, -syl.start_time, nl.duration))
				nl.text = string.format("{\\an5\\pos(%g,%g)%s}%s", syl.x, syl.y, nl.text, syl.text_spacestripped)
				subs.append(nl)
			end
			
			set_line_prop(nl, 2, line.start_time+syl.start_time, line.start_time+syl.end_time+200)
			nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\bord%d\\fad(0,%d)\\1c%s\\3c%s\\1a&H30&\\3a&H30&%s}%s", syl.x, syl.y, line.styleref.outline*2, nl.duration, line.styleref.color4, line.styleref.color4, time_shifter(rotpath, -syl.start_time, nl.duration), syl.text_spacestripped)
			subs.append(nl)
		end
	end
end

function do_trans(subs, meta, line)
	local nl = table.copy(line)
	
	set_line_prop(nl, 0, line.start_time-400, line.end_time+400)
	nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\bord%g\\fad(400,400)\\3c%s\\1a&HFF&\\3a&H60&}%s", line.center, line.middle, line.styleref.outline*1.4, line.styleref.color4, line.text_stripped)
	subs.append(nl)
	
	nl.layer = 1
	nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\fad(400,400)\\1a&HFF&}%s", line.center, line.middle, line.text_stripped)
	subs.append(nl)
	
	local clipsize = 1
	local sclip, eclip = 0, line.height-clipsize
	for j = sclip, eclip, clipsize do
		local clipcolor = interpolate_color((j-sclip)/(eclip-sclip), line.styleref.color2, line.styleref.color1)
		if line.layer == 1 then clipcolor = interpolate_color((j-sclip)/(eclip-sclip), line.styleref.color1, line.styleref.color2) end
		local clipx1, clipy1, clipx2, clipy2 = 0, line.top+j, meta.res_x, line.top+j+clipsize
		if j == sclip then clipy1 = 0 elseif j == eclip then clipy2 = meta.res_y end
		
		nl.text = string.format("\\be1\\bord0\\fad(400,400)\\1c%s\\clip(%d,%d,%d,%d)", clipcolor, clipx1, clipy1, clipx2, clipy2)
		nl.text = string.format("{\\an5\\pos(%g,%g)%s}%s", line.center, line.middle, nl.text, line.text_stripped)
		subs.append(nl)
	end
end

function macro_main(subs)
	main(subs)
	aegisub.set_undo_point(string.format("%s karaoke effects", script_name))
end

aegisub.register_macro(string.format("Apply %s karaoke effects", script_name), string.format("Apply %s karaoke effects to the timed script", script_name), macro_main)
aegisub.register_filter(string.format("Apply %s karaoke effects", script_name), string.format("Apply %s karaoke effects to the timed script", script_name), 2000, main)
