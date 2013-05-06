timing_input_file = overlua_datastring
font_name = "Insignia LT Std"
font_size = 40
font_size_chorus = 35
ypos = {}
ypos["main"] = 50
ypos["chorus"] = 47.5
fadetime = 1

assert(timing_input_file, "Missing timing input file for Psycho effect.")


function parsenum(str)
	return tonumber(str) or 0
end
function parse_ass_time(ass)
	local h, m, s, cs = ass:match("(%d+):(%d+):(%d+)%.(%d+)")
	return parsenum(cs)/100 + parsenum(s) + parsenum(m)*60 + parsenum(h)*3600
end

function parse_k_timing(text)
	local syls = {}
	local cleantext = ""
	local i = 1
	for timing, syltext in text:gmatch("{\\k(%d+)}([^{]*)") do
		local syl = {dur = parsenum(timing)/100, text = syltext, i = i}
		table.insert(syls, syl)
		cleantext = cleantext .. syltext
		i = i + 1
	end
	return syls, cleantext
end

function read_input_file(name)
	for line in io.lines(name) do
		local start_time, end_time, fx, text = line:match("Dialogue: 0,(.-),(.-),Default,,0000,0000,0000,(.-),(.*)")
		if fx == "color" then
			local cd = {}
			cd.start_time = parse_ass_time(start_time)
			cd.end_time = parse_ass_time(end_time)
			local left, top, right, bottom = text:match("(%d+),(%d+),(%d+),(%d+)")
			cd.left = parsenum(left)
			cd.top = parsenum(top)
			cd.right = parsenum(right)
			cd.bottom = parsenum(bottom)
			cd.width = cd.right - cd.left
			cd.height = cd.bottom - cd.top
			table.insert(colors, cd)
		elseif text then
			local ls = {}
			ls.start_time = parse_ass_time(start_time)
			ls.end_time = parse_ass_time(end_time)
			ls.fx = fx
			ls.rawtext = text
			ls.kara, ls.cleantext = parse_k_timing(text)
			table.insert(lines, ls)
		end
	end
end

function init()
	if inited then return end
	inited = true
	
	lines = {}
	colors = {}
	read_input_file(timing_input_file)
end


function get_sparks_texture(width, height)
	if sparks_texture then return sparks_texture end
	local surf = cairo.image_surface_create(128, 128, "rgb24")
	local c = surf.create_context()
	c.set_source_rgb(0,0,0)
	c.paint()
	c.set_source_rgb(1,1,0.9)
	for i = 1, 50 do
		local x, y = math.random(120)+4, math.random(120)+4
		c.arc(x, y, 3, 0, 2*math.pi)
		c.fill()
	end
	raster.gaussian_blur(surf, 2.5)
	
	sparks_texture = cairo.pattern_create_for_surface(surf)
	sparks_texture.set_extend("repeat")
	
	return sparks_texture
end


function render_frame(f, t)
	init()
	
	-- Find colour for this frame
	local colordef
	for i, cd in pairs(colors) do
		if t >= cd.start_time and t < cd.end_time then
			colordef = cd
		end
	end
	local fsurf = f.create_cairo_surface()
	raster.gaussian_blur(fsurf, 5)
	colordef.r, colordef.g, colordef.b = fsurf.get_pixel(colordef.left+15, colordef.top+15)
	colordef.r, colordef.g, colordef.b = colordef.r/255, colordef.g/255, colordef.b/255
	
	local function blubble_mapper(x, y)
		local nx = x + math.sin(x/30 + y/10 + t*2.0)*3
		local ny = y + math.cos(y/20 + x/20 + t*2.3)*3
		return nx, ny
	end
	local function main_fade_map(line, c)
		local func
		local topy, bottomy = ypos.main - line.fe.ascent, ypos.main + line.fe.descent
		if t < line.start_time then
			local factor = ((line.start_time - t) / fadetime) ^ 0.5
			func = function(x, y)
				local xshrink = 1 - (y - topy) / (bottomy - topy)
				local nx = (x-f.width/2)*xshrink*factor + (x-f.width/2)*(1-factor) + f.width/2
				return nx, y
			end
		elseif t > line.end_time then
			local factor = ((t - line.end_time) / fadetime) ^ 0.5
			func = function(x, y)
				local xshrink = (y - topy) / (bottomy - topy)
				local nx = (x-f.width/2)*xshrink*factor + (x-f.width/2)*(1-factor) + f.width/2
				return nx, y
			end
		else
			return
		end
		
		local path = c.copy_path()
		path.map_coords(func)
		c.new_path()
		c.append_path(path)
	end
	
	-- Find lines to be drawn
	-- FIXME? this should perhaps rather be an object table or whatever
	for i, line in pairs(lines) do
		if line.start_time <= t+fadetime and line.end_time > t-fadetime and ypos[line.fx] then
			local x = 0
			local y = ypos[line.fx]
			
			local surf = cairo.image_surface_create(f.width, 200, "argb32")
			local c = surf.create_context()
			c.select_font_face(font_name)
			if line.fx == "chorus" then
				c.set_font_size(font_size_chorus)
			else
				c.set_font_size(font_size)
			end
			if not line.te then line.te = c.text_extents(line.cleantext); line.fe = c.font_extents() end
			x = (f.width - line.te.width) / 2 - line.te.x_bearing
			c.move_to(x, y)
			c.text_path(line.cleantext)
			
			if line.fx == "main" then
				main_fade_map(line, c)
				
				c.set_line_width(8)
				c.set_source_rgba(1-colordef.r, 1-colordef.g, 1-colordef.b, 1)
				c.stroke_preserve()
				raster.gaussian_blur(surf, 1.5)
				c.set_line_width(3)
				c.set_source_rgba(1, 1, 1, 1)
				c.stroke()
				
				local sumdur = line.start_time
				for j, syl in pairs(line.kara) do
					if not syl.te then syl.te = c.text_extents(syl.text) end
					c.move_to(x, y)
					c.text_path(syl.text)
					main_fade_map(line, c)
					x = x + syl.te.x_advance
					if (syl.i == 1 and t < sumdur+syl.dur) or
							(syl.i == #line.kara and t > sumdur) or
							(t >= sumdur and t < sumdur+syl.dur) then
						local sparks = get_sparks_texture()
						local texmat = cairo.matrix_create()
						texmat.init_rotate(t/10)
						texmat.scale(3, 3)
						sparks.set_matrix(texmat)
						c.set_source(sparks)
						c.fill()
					else
						c.set_source_surface(fsurf, 0, 0)
						c.fill_preserve()
						c.set_source_rgba(0, 0, 0, 0.3)
						c.fill()
					end
					sumdur = sumdur + syl.dur
				end
				
			elseif line.fx == "chorus" then
				local path = c.copy_path()
				path.map_coords(blubble_mapper)
				c.new_path()
				c.append_path(path)
			
				c.set_source_rgba(0.5, 0.5, 0.5, 1)
				c.fill_preserve()
				raster.gaussian_blur(surf, 2)
				c.set_operator("add")
				c.set_source_rgba(colordef.b, colordef.g, colordef.r, 0.7)
				c.fill_preserve()
				c.push_group()
				c.set_source_rgba(colordef.b*0.3, colordef.r*0.3, colordef.g*0.3, 1)
				c.set_line_width(4)
				c.stroke_preserve()
				c.set_operator("clear")
				c.fill()
				c.pop_group_to_source()
				c.set_operator("over")
				c.paint()
			else
				c.fill()
			end
			
			local final = surf
			if t < line.start_time or t > line.end_time then
				local invisibility
				if t < line.start_time then
					invisibility = (line.start_time - t) / fadetime
				else
					invisibility = (t - line.end_time) / fadetime
				end
				final = cairo.image_surface_create(surf.get_width(), surf.get_height(), "argb32")
				local c = final.create_context()
				c.set_source_surface(surf, 0, 0)
				c.paint_with_alpha(1-invisibility)
				raster.gaussian_blur(final, invisibility*15)
			end
			
			f.overlay_cairo_surface(final, 0, 0)
		end
	end
end
