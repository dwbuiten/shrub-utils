-- Aegisub Automation 4 Lua script
-- based on Automation 4 Script Template revision 2
-- written by Mohd. Hafizuddin B. M. Marzuki

include("karaskel.lua")
include("apihlib.lua")

script_name = "Moyashimon ED"
script_description = "Moyashimon ED karaoke effects"
script_author = "Mohd. Hafizuddin B. M. Marzuki"
script_version = "1.0"


function main(subs)
	math.randomseed(1398)
	
	local meta, styles = karaskel.collect_head(subs)
	local maxi = #subs
	
	for i = 1, maxi do
		local line = subs[i]
		
		if line.class == "dialogue" and not line.comment then
			if line.style:find("Romaji") then
				karaskel.ext_preproc_line(subs, meta, styles, line)
				do_romaji(subs, meta, line)
			elseif line.style:find("Kanji") then
				karaskel.ext_preproc_line(subs, meta, styles, line)
				do_kanji(subs, meta, line)
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

function do_romaji(subs, meta, line)
	local nl = table.copy(line)
	
	for i = 1, #line.kara do
		local syl = line.kara[i]

		if not is_syl_blank(syl) then
			for i = 1, #syl.chars do
				local syl = syl.chars[i]

				if not is_syl_blank(syl) then
					syl.x, syl.y = line.left + syl.center, line.middle

					set_line_prop(nl, 0, line.start_time-700, line.start_time)
					nl.text = string.format("\\be1\\fad(700,0)\\1c%s\\fscx%d\\fscy%d\\frx%d\\fry%d\\frz%d\\t(\\fscx%d\\fscy%d\\frx0\\fry0\\frz0)", line.styleref.color2, line.styleref.scale_x-50, line.styleref.scale_y-50, math.random(-360,360), math.random(-360,360), math.random(-360,360), line.styleref.scale_x, line.styleref.scale_y)
					nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)%s}%s", syl.x+math.random(-120,120), syl.y+math.random(-60,60), syl.x, syl.y, nl.text, syl.text_spacestripped)
					subs.append(nl)

					set_line_prop(nl, 1, line.start_time, line.start_time+syl.start_time)
					nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\1c%s}%s", syl.x, syl.y, line.styleref.color2, syl.text_spacestripped)
					subs.append(nl)
					
					if line.actor == "flip" then
						set_line_prop(nl, 1, line.start_time+syl.start_time, line.end_time)
						nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\1c%s}%s", syl.x, syl.y, line.styleref.color1, syl.text_spacestripped)
						subs.append(nl)
						
						set_line_prop(nl, 2, line.start_time+syl.start_time, line.start_time+syl.end_time+200)
						nl.text = string.format("\\fscx%d\\fscy%d\\t(\\fscx%d\\fscy%d\\frx%d\\fry%d\\frz%d)", line.styleref.scale_x+40, line.styleref.scale_y+40, line.styleref.scale_x-20, line.styleref.scale_y-20, math.random(40,70), math.random(40,70), math.random(90,180))
						nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)\\be1\\fad(0,%d)\\1c%s%s}%s", syl.x, syl.y, syl.x, syl.y+4, nl.duration, line.styleref.color2, nl.text, syl.text_spacestripped)
						subs.append(nl)
					end

					if line.actor == "shake" then
						set_line_prop(nl, 1, line.start_time+syl.end_time, line.end_time)
						nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\1c%s}%s", syl.x, syl.y, line.styleref.color1, syl.text_spacestripped)
						subs.append(nl)
					end
					
					set_line_prop(nl, 0, line.end_time, line.end_time+700)
					nl.text = string.format("\\be1\\fad(0,700)\\1c%s\\t(\\fscx%d\\fscy%d\\frx%d\\fry%d\\frz%d)", line.styleref.color1, line.styleref.scale_x-50, line.styleref.scale_y-50, math.random(-360,360), math.random(-360,360), math.random(-360,360))
					nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)%s}%s", syl.x, syl.y, syl.x+math.random(-120,120), syl.y+math.random(-60,60), nl.text, syl.text_spacestripped)
					subs.append(nl)
				end
			end
			
			syl.x, syl.y = line.left + syl.center, line.middle
			
			if line.actor == "shake" then
				local dir, shake_dur, shake_dist, shake_scale_inc = 1, 80, 7, 50
				local shake_count = math.ceil(syl.duration/shake_dur)
				for j = 1, shake_count do
					if j < shake_count then
						set_line_prop(nl, 2, line.start_time+syl.start_time+(j-1)*shake_dur, line.start_time+syl.start_time+j*shake_dur)
					else
						set_line_prop(nl, 2, line.start_time+syl.start_time+(j-1)*shake_dur, line.start_time+syl.end_time)
					end
					nl.text = string.format("\\be1\\1c%s\\fscx%g\\fscy%g\\t(\\fscx%g\\fscy%g)", line.styleref.color1, line.styleref.scale_x+shake_scale_inc*(1-((j-1)/shake_count)), line.styleref.scale_y+shake_scale_inc*(1-((j-1)/shake_count)), line.styleref.scale_x+shake_scale_inc*(1-(j/shake_count)), line.styleref.scale_y+shake_scale_inc*(1-(j/shake_count)))
					nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)%s}%s", syl.x-dir*shake_dist*(1-((j-1)/shake_count)), syl.y+dir*shake_dist*(1-((j-1)/shake_count)), syl.x+dir*shake_dist*(1-((j-1)/shake_count)), syl.y-dir*shake_dist*(1-((j-1)/shake_count)), nl.text, syl.text_spacestripped)
					subs.append(nl)
					dir = -dir
				end
			end
		end
	end
end

function do_kanji(subs, meta, line)
	local nl = table.copy(line)
	local curx, cury = meta.res_x-line.height-line.eff_margin_r, (meta.res_y-line.width)/2
	
	for i = 1, #line.kara do
		local syl = line.kara[i]

		if not is_syl_blank(syl) then
			for i = 1, #syl.chars do
				local syl = syl.chars[i]

				if not is_syl_blank(syl) then
					syl.x, syl.y = curx + line.height/2, cury + syl.center
					
					set_line_prop(nl, 0, line.start_time-700, line.start_time)
					nl.text = string.format("\\be1\\fad(700,0)\\1c%s\\fscx%d\\fscy%d\\frx%d\\fry%d\\frz%d\\t(\\fscx%d\\fscy%d\\frx0\\fry0\\frz-90)", line.styleref.color2, line.styleref.scale_x-50, line.styleref.scale_y-50, math.random(-360,360), math.random(-360,360), -90+math.random(-360,360), line.styleref.scale_x, line.styleref.scale_y)
					nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)%s}%s", syl.x+math.random(-60,60), syl.y+math.random(-120,120), syl.x, syl.y, nl.text, syl.text_spacestripped)
					subs.append(nl)

					set_line_prop(nl, 1, line.start_time, line.start_time+syl.start_time)
					nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\1c%s}%s", syl.x, syl.y, line.styleref.color2, syl.text_spacestripped)
					subs.append(nl)
					
					if line.actor == "flip" then
						set_line_prop(nl, 1, line.start_time+syl.start_time, line.end_time)
						nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\1c%s}%s", syl.x, syl.y, line.styleref.color1, syl.text_spacestripped)
						subs.append(nl)
						
						set_line_prop(nl, 2, line.start_time+syl.start_time, line.start_time+syl.end_time+200)
						nl.text = string.format("\\fscx%d\\fscy%d\\t(\\fscx%d\\fscy%d\\frx%d\\fry%d\\frz%d)", line.styleref.scale_x+50, line.styleref.scale_y+50, line.styleref.scale_x-20, line.styleref.scale_y-20, math.random(40,70), math.random(40,70), -90+math.random(90,180))
						nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\fad(0,%d)\\1c%s%s}%s", syl.x, syl.y, nl.duration, line.styleref.color2, nl.text, syl.text_spacestripped)
						subs.append(nl)
					end
					
					if line.actor == "shake" then
						set_line_prop(nl, 1, line.start_time+syl.end_time, line.end_time)
						nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\1c%s}%s", syl.x, syl.y, line.styleref.color1, syl.text_spacestripped)
						subs.append(nl)
					end
					
					set_line_prop(nl, 0, line.end_time, line.end_time+700)
					nl.text = string.format("\\be1\\fad(0,700)\\1c%s\\t(\\fscx%d\\fscy%d\\frx%d\\fry%d\\frz%d)", line.styleref.color1, line.styleref.scale_x-50, line.styleref.scale_y-50, math.random(-360,360), math.random(-360,360), -90+math.random(-360,360))
					nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)%s}%s", syl.x, syl.y, syl.x+math.random(-60,60), syl.y+math.random(-120,120), nl.text, syl.text_spacestripped)
					subs.append(nl)
				end
			end

			syl.x, syl.y = curx + line.height/2, cury + syl.center

			if line.actor == "shake" then
				local dir, shake_dur, shake_dist, shake_scale_inc = 1, 80, 7, 55
				local shake_count = math.ceil(syl.duration/shake_dur)
				for j = 1, shake_count do
					if j < shake_count then
						set_line_prop(nl, 2, line.start_time+syl.start_time+(j-1)*shake_dur, line.start_time+syl.start_time+j*shake_dur)
					else
						set_line_prop(nl, 2, line.start_time+syl.start_time+(j-1)*shake_dur, line.start_time+syl.end_time)
					end
					nl.text = string.format("\\be1\\1c%s\\fscx%g\\fscy%g\\t(\\fscx%g\\fscy%g)", line.styleref.color1, line.styleref.scale_x+shake_scale_inc*(1-((j-1)/shake_count)), line.styleref.scale_y+shake_scale_inc*(1-((j-1)/shake_count)), line.styleref.scale_x+shake_scale_inc*(1-(j/shake_count)), line.styleref.scale_y+shake_scale_inc*(1-(j/shake_count)))
					nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)%s}%s", syl.x-dir*shake_dist*(1-((j-1)/shake_count)), syl.y+dir*shake_dist*(1-((j-1)/shake_count)), syl.x+dir*shake_dist*(1-((j-1)/shake_count)), syl.y-dir*shake_dist*(1-((j-1)/shake_count)), nl.text, syl.text_spacestripped)
					subs.append(nl)
					dir = -dir
				end
			end
		end
	end
end

function do_trans(subs, meta, line)
	local nl = table.copy(line)
	
	for i = 1, #line.chars do
		local syl = line.chars[i]

		if not is_syl_blank(syl) then
			syl.x, syl.y = line.left + syl.center, line.middle

			set_line_prop(nl, 0, line.start_time-700, line.start_time)
			nl.text = string.format("\\be1\\fad(700,0)\\1c%s\\fscx%d\\fscy%d\\frx%d\\fry%d\\frz%d\\t(\\fscx%d\\fscy%d\\frx0\\fry0\\frz0)", line.styleref.color1, line.styleref.scale_x-50, line.styleref.scale_y-50, math.random(-360,360), math.random(-360,360), math.random(-360,360), line.styleref.scale_x, line.styleref.scale_y)
			nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)%s}%s", syl.x+math.random(-120,120), syl.y+math.random(-60,60), syl.x, syl.y, nl.text, syl.text_spacestripped)
			subs.append(nl)

			set_line_prop(nl, 1, line.start_time, line.end_time)
			nl.text = string.format("{\\an5\\pos(%g,%g)\\be1\\1c%s}%s", syl.x, syl.y, line.styleref.color1, syl.text_spacestripped)
			subs.append(nl)

			set_line_prop(nl, 0, line.end_time, line.end_time+700)
			nl.text = string.format("\\be1\\fad(0,700)\\1c%s\\t(\\fscx%d\\fscy%d\\frx%d\\fry%d\\frz%d)", line.styleref.color1, line.styleref.scale_x-50, line.styleref.scale_y-50, math.random(-360,360), math.random(-360,360), math.random(-360,360))
			nl.text = string.format("{\\an5\\move(%g,%g,%g,%g)%s}%s", syl.x, syl.y, syl.x+math.random(-120,120), syl.y+math.random(-60,60), nl.text, syl.text_spacestripped)
			subs.append(nl)
		end
	end
end

function macro_main(subs)
	main(subs)
	aegisub.set_undo_point(string.format("%s karaoke effects", script_name))
end

aegisub.register_macro(string.format("Apply %s karaoke effects", script_name), string.format("Apply %s karaoke effects to the timed script", script_name), macro_main)
aegisub.register_filter(string.format("Apply %s karaoke effects", script_name), string.format("Apply %s karaoke effects to the timed script", script_name), 2000, main)
