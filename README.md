# mpv retiming scripts

Scripts related to retiming subtitle files. Keybinds can be rebound near the top of each file. Each script can be installed by placing the respective file into your [mpv scripts folder](https://mpv.io/manual/master/#files).

### snap-to-secondary-sub

Adds keybinds to make it easier to retime subs to match the timing of the internal subs in a video file:

- `Alt+c`: Set the sub-delay so the start time of the primary subtitle matches the start time of the secondary subtitle.
- `Alt+LEFT`: Execute `sub-step -1` (CTRL+SHIFT+LEFT), then execute what `Alt+c` does.
- `Alt+RIGHT`: Execute `sub-step 1` (CTRL+SHIFT+RIGHT), then execute what `Alt+c` does.
- `e`: Swap primary subtitle and secondary subtitle with each other.

NOTE: Different subtitle tracks don't always begin or end in the same places. It is suggested to keep the secondary sub visible while retiming with this script.

### save-sub-delay-to-file

Script for retiming .ass and .srt **files** by using the sub delay as the offset to shift the subtitle timings by. Upon execution, basic-sub-utility reads the current subtitle file and the resulting output is loaded into mpv.

Press `w` to bring up a menu. You can configure the script's defaults by changing the `options` near the beginning of the script.

Setup:

1. This script depends on basic-sub-utility, which can be downloaded [here](https://github.com/Ulidtsoa01/basic-sub-utility/releases).
2. In the `options`, set `tool_path` to the location of your basic-sub-utility executable.

Thanks goes to [Rapptz](https://github.com/Rapptz) for help with testing.

### Reccomended mpv settings

To take full advantage of these scripts, the following settings and keybinds are helpful.
In `mpv.conf`:

```
secondary-sid=auto
secondary-sub-visibility=no
slang=ja,jpn,jp,enm,en,eng       # automatically select subtitles in decreasing priority
alang=ja,jpn,jp,enm,en,eng       # automatically select audio tracks in decreasing priority
```

In `input.conf`:

```
Alt+v cycle secondary-sub-visibility   # hide or show the secondary subtitles

### Non-default keybinds
; cycle secondary-sid down
' cycle secondary-sid
C set sub-delay 0
```
