include("karaskel.lua")

script_name = "Romeo x Juliet OP effect"
script_author = "jfs"

fadein = 300

function rxj_op(subs)
	local meta, styles = karaskel.collect_head(subs)
	
	local nsubs = #subs
	for i = 1, nsubs do
		local l = subs[i]
		if l.class == "dialogue" and l.style == "op-romaji" then
			karaskel.preproc_line(subs, meta, styles, l)
			do_romaji(subs, l)
			l = subs[i]
			l.comment = true
			subs[i] = l
		elseif l.class == "dialogue" and l.style == "op-kanji" then
			karaskel.preproc_line(subs, meta, styles, l)
			do_kanji(subs, l)
			l = subs[i]
			l.comment = true
			subs[i] = l
		elseif l.class == "dialogue" and l.style == "op-kana" then
			l.start_time = l.start_time - fadein
			l.end_time = l.end_time + 100
			l.duration = l.end_time - l.start_time
			l.layer = 1
			l.text = string.format("{\\1a&HFF&\\3a&HFF&\\t(0,%d,\\1a&H%02x&\\3a&H%02x&)\\t(%d,%d,\\1a&HFF&\\3a&HFF&)}%s", fadein, 128, 224, l.duration-100, l.duration, l.text)
			subs[i] = l
		elseif l.class == "dialogue" and l.style == "op-english" then
			l.start_time = l.start_time - fadein
			l.end_time = l.end_time + 100
			l.duration = l.end_time - l.start_time
			l.layer = 1
			l.text = string.format("{\\1a&HFF&\\3a&HFF&\\4a&HFF&\\t(0,%d,\\1a&H00&\\3a&H00&\\4a&H80&)\\t(%d,%d,\\1a&HFF&\\3a&HFF&\\4a&HFF&)}%s", fadein, l.duration-100, l.duration, l.text)
			subs[i] = l
		end
	end
end

function do_romaji(subs, line)
	for i = 1, line.kara.n do
		local syl = line.kara[i]
		syl.x, syl.y = line.left+syl.left, line.top
		
		-- black border
		local l = copy_line(line)
		l.start_time = l.start_time - fadein
		l.end_time = l.end_time + i*30
		l.text = string.format("{\\1a&HFF&\\shad0\\pos(%d,%d)\\bord0\\t(0,%d,\\bord%.1f)\\t(%d,%d,\\3c&HFFFFFF&\\bord0)}%s", syl.x, syl.y, fadein, line.styleref.outline, line.duration+300+i*30-200, line.duration+300+i*30, syl.text_stripped)
		l.layer = 10
		subs.append(l)
		
		-- regular fill
		l.text = string.format("{\\bord0\\shad0\\pos(%d,%d)\\1a&HFF&\\t(0,%d,\\1a&H00&)\\t(%d,%d,\\1c&HFFFFFF&\\1a&HFF&)}%s", syl.x, syl.y, fadein, line.duration+300+i*30-200, line.duration+300+i*30, syl.text_stripped)
		l.layer = 12
		subs.append(l)
		
		if syl.duration > 0 then
			-- highlight glow
			if syl.duration < 1500 then
				local glowsize = 3 + math.floor(syl.duration / 100)
				l.start_time = line.start_time
				l.end_time = line.end_time
				l.layer = 13
				for g = 1, glowsize do
					l.text = string.format("{\\bord%d\\shad0\\1a&HFF&\\pos(%d,%d)\\3c%s\\3a&HFF&\\t(%d,%d,\\3a&H%02x&)\\t(%d,%d,\\3a&HFF&)}%s", g, syl.x, syl.y, line.styleref.color2, syl.start_time, syl.start_time + syl.duration/5, 255 - 1/glowsize*255, syl.start_time + syl.duration/5, syl.end_time, syl.text_stripped)
					subs.append(l)
				end
			else
				local glows = math.floor(syl.duration / 200)
				for g = 0, glows-1 do
					l.start_time = line.start_time + syl.start_time + g*200
					l.end_time = l.start_time + 3000
					l.layer = 13
					l.text = string.format("{\\bord0\\shad0\\1a&HFF&\\3a&HC0&\\3c%s\\pos(%d,%d)\\an5\\t(\\bord30\\3a&HFF&)}%s", line.styleref.color2, line.left+syl.center, line.middle, syl.text_stripped)
					subs.append(l)
				end
			end
		end
	end
end

function do_kanji(subs, line)
	for i = 1, line.kara.n do
		local syl = line.kara[i]
		syl.x = 6 + line.height/2
		syl.y = 45 + syl.center
		
		-- border
		local l = copy_line(line)
		l.start_time = l.start_time - fadein
		l.end_time = l.end_time + i*30
		l.text = string.format("{\\1a&HFF&\\shad0\\an5\\pos(%d,%d)\\bord0\\t(0,%d,\\bord%.1f)\\t(%d,%d,\\3c&HFFFFFF&\\bord0)}%s", syl.x, syl.y, fadein, line.styleref.outline, line.duration+100+i*30-200, line.duration+100+i*30, syl.text_stripped)
		l.layer = 10
		subs.append(l)
		
		-- regular fill
		l.text = string.format("{\\bord0\\shad0\\an5\\pos(%d,%d)\\1a&HFF&\\t(0,%d,\\1a&H00&)\\t(%d,%d,\\1c&HFFFFFF&\\1a&HFF&)}%s", syl.x, syl.y, fadein, line.duration+100+i*30-200, line.duration+100+i*30, syl.text_stripped)
		l.layer = 12
		subs.append(l)
		
		if syl.duration > 0 then
			local glows = math.ceil(syl.duration / 100)
			for g = 0, glows-1 do
				l.text = string.format("{\\bord3\\shad0\\an5\\1c%s\\3c%s\\pos(%d,%d)\\1a&H80&&\\3a&H80&\\t(1.3,\\1a&Hff&\\3a&Hff&\\fscy400\\fscx150)}%s", line.styleref.color2, line.styleref.color2, syl.x, syl.y, syl.text_stripped)
				l.layer = 5
				l.start_time = line.start_time + syl.start_time + g*100 - 50
				l.end_time = l.start_time + 500
				subs.append(l)
			end
		end
	end
end


aegisub.register_filter(script_name, "", 2000, rxj_op)
