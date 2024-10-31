SHOW_WINDOW_KEY = "w"

local mp = require 'mp'
local assdraw = require("mp.assdraw")
local utils = require "mp.utils"
local retiming_window = {}
retiming_window.__index = retiming_window

function retiming_window:new()
    local options
    options = {
        tool_path = [[C:\<path>\basic-sub-utility.exe]], --SETUP: replace with path to basic-sub-utility (https://github.com/Ulidtsoa01/basic-sub-utility/releases)
        save_to_new_file = true, --If true, outputted sub file is renamed to the currently playing video (along with any replacements specified by rename_filename)
        preserve_original_file = false, --If true, will not replace the original/first subtitle file executed on
        rename_filename = {"(.*)", "%1.ja", 1}, --string.gsub() params: provide a pattern, replacement string, and limit for number of substitutions
            --read https://www.lua.org/manual/5.3/manual.html#6.4.1 for pattern-matching
        keybinds = {
            {'1', 'set-start-time', function() options:set_sub_start() end, {}},
            {'2', 'set-end-time', function() options:set_sub_end() end, {}},
            {'m', 'cycle-modes', function() options:cycle_mode() end, {}},
            {'s', 'toggle-save-new-file', function() options:toggle_new_file() end, {}},
            {'!', 'earliest-start-time', function() options:set_start("-∞") end, {}},
            {'@', 'latest-end-time', function() options:set_end("∞") end, {}},
            {'r', 'execute', function() options:execute() end, {}},
        },
        padding_x = 20,
        padding_y = 90,
    }
    retiming_window.displayed = false
    retiming_window.start_time = "-∞"
    retiming_window.end_time = "∞"
    retiming_window.mode = 1
    retiming_window.orig_file_path = nil
    retiming_window.target_file_path = nil
    retiming_window.current_file_path = nil
    retiming_window.drop_index = nil
    return setmetatable(options, retiming_window)
end

local mode_map = {{"retime", "Shift by sub delay"}, {"remove", "Remove selected lines"}}

local function showMessage(message, persist)
    local ass_start = mp.get_property_osd('osd-ass-cc/0')
    local ass_stop = mp.get_property_osd('osd-ass-cc/1')
    local fontsize = '' --{\\fs12}
    mp.osd_message(ass_start..fontsize..tostring(message)..ass_stop, persist or 2.5);
end

local function testMessage(t)
    local message = ""
    if type(t) == "table" then
        for _,v in pairs(t) do
            message = message..v.."\\N"
        end
    else
        message = tostring(t)
    end
    showMessage(message, 5)
end


local function bold(text)
    return "{\\b1}" .. tostring(text) .. "{\\b0}"
end

local function paren(text)
    return "(" .. tostring(text) .. ")"
end

local function yesno(text)
    return text and "yes" or "no"
end


local function format_duration_HHMMSSssss(duration)
    if duration == nil then return "00:00" end
    local negative = ""
    if duration  <= -0.00005 then
        negative = "-"
        duration = duration*-1
    end
    duration = math.floor(duration * 10000 + 0.5)/10000
    local hours = math.floor(duration / 3600)
    local minutes = math.floor(duration / 60 % 60)
    local seconds = math.floor(duration % 60)
    local ssss = (duration*10000)%10000
    return negative..string.format("%02d:%02d:%02d.%04d", hours, minutes, seconds, ssss)
end


local function format_duration_ms(duration)
    if duration == nil then return "00:00" end
    local negative = ""
    if duration  <= -0.0005 then
        negative = "-"
        duration = duration*-1
    end
    duration = math.floor(duration * 1000 + 0.5)/1000
    local hours = math.floor(duration / 3600)
    local minutes = math.floor(duration / 60 % 60)
    local seconds = math.floor(duration % 60)
    local milliseconds = (duration*1000)%1000
    local hr = hours ~= 0 and hours..":" or ""
    return negative..hr..string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
end

local function path(abs_path)
    local directory, filename = utils.split_path(abs_path)
    local name, extension = filename:match("(.*)%.([^%./]+)$")
    return {dir=directory, filename=filename, name=name, ext=extension}
end


local function copy(src, target)
    local infile = io.open(src, "r")
    local instr = infile:read("*a")
    infile:close()

    local outfile = io.open(target, "w")
    outfile:write(instr)
    outfile:close()
end

local function file_exists(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
 end

function retiming_window:handle_file_names()
    self.current_file_path = mp.get_property("current-tracks/sub/external-filename")
    if not self.orig_file_path then
        self.orig_file_path = self.current_file_path
    end
    if self.target_file_path then
        return
    end
    if self.save_to_new_file then
        local new_name = mp.get_property('filename/no-ext')
        local r = self.rename_filename
        new_name = string.gsub(new_name, r[1], r[2], r[3])
        local orig = path(self.orig_file_path)
        self.target_file_path = orig['dir']..new_name.."."..orig['ext']
    else
        self.target_file_path = self.orig_file_path
    end
    if self.preserve_original_file and self.target_file_path == self.orig_file_path then
        local orig = path(self.orig_file_path)
        self.target_file_path = orig['dir']..orig['name'].." (1)."..orig['ext']
    end
end

function retiming_window:after_call()
    local message = ""
    if file_exists(self.target_file_path) then
        os.remove(self.target_file_path)
        message = "✔Existing file replaced. Edited sub saved to "..self.target_file_path
    else
        message = "Edited sub saved to "..self.target_file_path
    end
    local curr = path(self.current_file_path)
    local program_output = curr['dir']..curr['name'].."_modified".."."..curr['ext']
    os.rename(program_output, self.target_file_path)
    showMessage(message, 5)
    mp.set_property("sub-delay", 0)
    self:set_start("-∞")
    self:set_end("∞")
    mp.commandv("sub-remove", self.drop_index)
    mp.commandv("sub-add", self.target_file_path)
    self.current_file_path = self.target_file_path
end

function retiming_window:execute()
    local sub_selected = mp.get_property_native("current-tracks/sub/selected")
    local track_external = mp.get_property_native("current-tracks/sub/external")
    local track_codec = mp.get_property("current-tracks/sub/codec")

    if not sub_selected then
        self:unbind()
        showMessage("✘No track selected")
        return
    end
    if not track_external then
        self:unbind()
        showMessage("✘Track must be external")
        return
    end
    if not (track_codec == "subrip" or track_codec == "ass") then
        self:unbind()
        showMessage("✘Track must be .srt or .ass ("..track_codec..")")
        return
    end
    
    self:handle_file_names()
    self.drop_index = mp.get_property_number("current-tracks/sub/id")
    local args = {
        self.tool_path,
        self.current_file_path,
    }
    if self.mode == 1 then
        local delay = mp.get_property_native("sub-delay")
        if delay == 0 then
            self:unbind()
            showMessage("✘Delay is 0")
            return
        end
        args[#args+1] = "--shift"
        args[#args+1] = string.format("%.4f", delay)
        if self.start_time ~= "-∞" then
            args[#args+1] = "--start"
            args[#args+1] = format_duration_HHMMSSssss(self.start_time)
        end
        if self.end_time ~= "∞" then
            args[#args+1] = "--end"
            args[#args+1] = format_duration_HHMMSSssss(self.end_time)
        end
    elseif self.mode == 2 then
        if self.start_time == "-∞" and self.end_time == "∞" then
            self:unbind()
            showMessage("✘Remove mode needs either a start or end time to be set")
        end
        if self.start_time ~= "-∞" then
            args[#args+1] = "--remove_start"
            args[#args+1] = format_duration_HHMMSSssss(self.start_time)
        end
        if self.end_time ~= "∞" then
            args[#args+1] = "--remove_end"
            args[#args+1] = format_duration_HHMMSSssss(self.end_time)
        end
    end
    
    showMessage("Processing...")
    local r = mp.command_native({
        name = "subprocess",
        playback_only = false,
        args = args,
        capture_stdout = true,
    })
    if r.status == 0 then
        self:after_call()
    else
        showMessage("✘Failed to run basic-sub-utility: "..r.status)
    end
end

function retiming_window:set_sub_start()
    local sub_start = mp.get_property_native('sub-start')
    if sub_start then
        self.start_time = sub_start - 0.0001
    else
        self.start_time = mp.get_property_native('time-pos')
    end
    self:draw()
end

function retiming_window:set_sub_end()
    local sub_end = mp.get_property_native('sub-end')
    if sub_end then
        self.end_time = sub_end + 0.0001
    else
        self.end_time = mp.get_property_native('time-pos')
    end
    self:draw()
end

function retiming_window:set_start(time)
    self.start_time = time
    self:draw()
end

function retiming_window:set_end(time)
    self.end_time = time
    self:draw()
end

function retiming_window:cycle_mode()
    self.mode = self.mode+1
    if self.mode > #mode_map then
        self.mode = self.mode % #mode_map
    end
    self:draw()
end

function retiming_window:toggle_new_file()
    self.save_to_new_file = not self.save_to_new_file
    self.target_file_path = nil
    self:draw()
end

function retiming_window:format_header_string(str)
    local delay = format_duration_ms(mp.get_property_native("sub-delay"))
    str = str:gsub("%%(%a+)%%", { mode = mode_map[self.mode][2], delay =  delay})
    return str
end

function retiming_window:get_header_text()
    local header_style = [[{\q1\c&00ccff&}]]
    local text = "Mode: %mode% [Delay: %delay%]"
    local str = header_style..self:format_header_string(text)
    return str
end

function retiming_window:draw()
    local ass = assdraw.ass_new()
    ass:new_event()
    ass:pos(self.padding_x, self.padding_y)

    local header = self:get_header_text()
    if header ~= nil then
        ass:append("{\\r}"..header.."\\N\\N{\\r}")
    end

    local st = self.start_time
    local et = self.end_time
    st = type(st) == 'number' and format_duration_ms(st) or st
    et = type(et) == 'number' and format_duration_ms(et) or et

    local add = function(key, text)
        return bold(key..':').." "..text.."\\N"
    end

    local k = self.keybinds
    ass:append(add(k[1][1], "set start time "..paren(st)))
    ass:append(add(k[2][1], "set end time "..paren(et)))
    ass:append(add(k[3][1], "cycle mode"))
    ass:append(add(k[4][1], "toggle save to new file "..paren(yesno(self.save_to_new_file))))
    ass:append(add(k[5][1], "set start time to -∞"))
    ass:append(add(k[6][1], "set end time to ∞"))
    ass:append(add(k[7][1], mode_map[self.mode][1]))
    ass:append("\\N")
    ass:append(add(SHOW_WINDOW_KEY, "close"))

    local w, h = mp.get_osd_size()
    mp.set_osd_ass(w, h, ass.text)
end

function retiming_window:unbind()
    self.displayed = false
    mp.set_osd_ass(0, 0, "")
    for _,v in ipairs(self.keybinds) do
        mp.remove_key_binding('retiming-window/'..v[2])
    end
end

function retiming_window:display()
    if self.displayed then
        self:unbind()
        return
    end

    self:draw()
    self.displayed = true
    for _,v in ipairs(self.keybinds) do
        mp.add_forced_key_binding(v[1], 'retiming-window/'..v[2], v[3], v[4])
    end  
end

local current_window = retiming_window.new{}
mp.add_key_binding(SHOW_WINDOW_KEY, "show-window", function() current_window:display() end)
mp.observe_property("sub-delay", "native", function()
    if current_window.displayed then
        current_window:draw()
    end
end)

local max_id = 0

mp.observe_property("current-tracks/sub/id", "native", function()
    local curr_id = mp.get_property_native("current-tracks/sub/id") or 0
    if curr_id > max_id then
        max_id = curr_id
        current_window.orig_file_path = nil
        current_window.target_file_path = nil
        current_window.current_file_path = nil
    end
end)

mp.register_event("file-loaded", function()
    current_window.orig_file_path = nil
    current_window.target_file_path = nil
    current_window.current_file_path = nil
end)
