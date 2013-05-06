--[[
Copyright (c) 2011, Derek Buitenhuis <derek.buitenhuis at gmail.com>

Permission to use, copy, modify, and/or distribute this software for any purpose with
or without fee is hereby granted, provided that the above copyright notice and this
permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD
TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN
NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]

script_name = "Medusa Collision Detection"
script_description = "Detects timing collisions in ASS files."
script_author = "Derek Buitenhuis"
script_version = "0.1"

include("karaskel.lua")

function collision_detect(subtitles, selected_lines, active_lines)
    local lin = {}
    local coll = {}
    local fin = ""

    for i = 1, #subtitles do
        if subtitles[i].class == "dialogue" then
            table.insert(lin, subtitles[i])
        end
    end
    for i = 1, #lin do
        coll[i] = 0
    end
    for i = 1, #lin do
        for j = i + 1, #lin do
            if lin[j].start_time < lin[i].end_time 
               and lin[j].end_time > lin[i].start_time
               and lin[i].comment == false
               and lin[j].comment == false
               and i ~= j then
                coll[i] = coll[i] + 1
                coll[j] = coll[j] + 1
            end
        end
    end
    for i = 1, #coll do
        if coll[i] ~= 0 then
            fin = fin .. "Collisions: " .. coll[i] .. ", Line " .. i .. ": \"" .. lin[i].text .."\n"
        end
    end
    aegisub.dialog.display({{class="textbox", text=fin, width=60, height=15}}, {})
end

aegisub.register_macro("Detect Collisions", "Detects timing collisions in ASS files.", collision_detect)