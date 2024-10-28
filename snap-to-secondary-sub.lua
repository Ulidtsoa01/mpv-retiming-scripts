SNAP_KEY = 'Alt+c'
SNAP_LEFT_KEY = 'Alt+LEFT'
SNAP_RIGHT_KEY = 'Alt+RIGHT'
SWAP_SUB_AND_SUB2_KEY = 'e'

FONT_SIZE = nil --'{\\fs16}'

local mp = require 'mp'

local function showMessage(message, persist)
  local ass_start = mp.get_property_osd('osd-ass-cc/0')
  local ass_stop = mp.get_property_osd('osd-ass-cc/1')
  local fontsize = FONT_SIZE or ''
  mp.osd_message(ass_start..fontsize..message..ass_stop, persist and 999 or 2);
end

local function snapSubToSecondarySub()
  local sub_selected = mp.get_property("current-tracks/sub/selected")
  local secondary_sub_selected = mp.get_property("current-tracks/sub2/selected")
  if sub_selected and secondary_sub_selected then
    local subStart = mp.get_property_native('sub-start');
    local secondarySubStart = mp.get_property_native('secondary-sub-start');
    local diff = secondarySubStart - subStart;
    mp.set_property('sub-delay', diff);
    local message = 'Sub delay: '..math.floor(diff*1000+.5)..'ms';
    showMessage(message);
  else
    local sub_delay = mp.get_property_native('sub-delay')
    showMessage('Sub delay: '..math.floor(sub_delay*1000+.5)..'ms\\N✘No sub or secondary sub selected');
  end
end

local function snapLeftSubToSecondarySub()
  mp.command('no-osd sub-step -1')
  snapSubToSecondarySub()
end

local function snapRightSubToSecondarySub()
  mp.command('no-osd sub-step 1')
  snapSubToSecondarySub()
end

local function format_track_switch_message(id , lang, title)
  local text = '(%id%) %lang% ("%title%")\\N'
  text = text:gsub('%%(%a+)%%', { id = id, lang = lang, title = title})
  return text
end

local function swapSubWithSecondarySub()
  local sub_selected = mp.get_property_native("current-tracks/sub/selected")
  local sub2_selected = mp.get_property_native("current-tracks/sub2/selected")
  local sub_id = mp.get_property_number("current-tracks/sub/id") or ""
  local sub2_id = mp.get_property_number("current-tracks/sub2/id") or ""
  local sub_lang = mp.get_property("current-tracks/sub/lang") or "unknown"
  local sub2_lang = mp.get_property("current-tracks/sub2/lang") or "unknown"
  local sub_title = mp.get_property("current-tracks/sub/title") or mp.get_property("current-tracks/sub/external-filename") or ""
  local sub2_title = mp.get_property("current-tracks/sub2/title") or mp.get_property("current-tracks/sub2/external-filename") or ""
  local sub_swapped = false
  local message1 = ''
  local message2 = ''
  
  if sub_selected then
    mp.set_property("sid", "no")
    mp.set_property("secondary-sid", sub_id)
    sub_swapped = true
    message1 = "Secondary subtitles: "..format_track_switch_message(sub_id, sub_lang, sub_title)
  end
  if sub2_selected then
    if not sub_swapped then
      mp.set_property("secondary-sid", "no")
    end
    mp.set_property("sid", sub2_id)
    message2 = "Subtitles: "..format_track_switch_message(sub2_id, sub2_lang, sub2_title)
  end
  showMessage(message1..message2)
end

mp.add_key_binding(SNAP_KEY, 'sub-to-sec-sub', snapSubToSecondarySub);
mp.add_key_binding(SNAP_LEFT_KEY, 'left-sub-to-sec-sub', snapLeftSubToSecondarySub, {repeatable = true});
mp.add_key_binding(SNAP_RIGHT_KEY, 'right-sub-to-sec-sub', snapRightSubToSecondarySub, {repeatable = true});
mp.add_key_binding(SWAP_SUB_AND_SUB2_KEY, 'swap-sub-with-sec-sub', swapSubWithSecondarySub);