# mpv retiming scripts

Scripts related to retiming subtitle files. Keybinds can be rebound near the top of each file. Each script can be installed by placing the respective file into your [mpv scripts folder](https://mpv.io/manual/master/#files).

### snap-to-secondary-sub

Adds keybinds to make it easier to retime subs to match the timing of the internal subs in a video file:

- `Alt+c`: Set the sub-delay so the start time of the primary subtitle matches the start time of the secondary subtitle.
- `Alt+LEFT`: Execute `sub-step -1` (CTRL+SHIFT+LEFT), then execute what `Alt+c` does.
- `Alt+RIGHT`: Execute `sub-step 1` (CTRL+SHIFT+RIGHT), then execute what `Alt+c` does.
- `e`: Swap primary sub and secondary sub.
- `E`: Swap primary sub delay and secondary sub delay.
- `Alt+e`: Swap primary sub and secondary sub along with their delays.

NOTE: Different subtitle tracks don't always begin or end in the same places. It is suggested to keep the secondary sub visible while retiming with this script.

### save-sub-delay-to-file

Provides a few utilities for modifying .ass and .srt **files** within mpv. The retiming mode shifts the subtitle timings by the amount of the current sub delay. The fix-jp mode fixes common issues with Japanese sub files as listed by the the following:
> * Removal of [外:37F6ECF37A0A3EF8DFF083CCC8754F81]-like instances of text
> * Half-width kana is converted into full width kana
> * Removal of &lrm;, U+202A, and U+202C characters

Upon execution, sub-tools reads the current subtitle file and outputs a file, which is loaded back into mpv.

Press `w` to bring up a menu. You can configure the script's defaults by changing the `options` near the beginning of the script.

Setup:

1. This script depends on sub-tools, which can be downloaded [here](https://github.com/Rapptz/sub-tools/releases).
2. In the `options`, set `tool_path` to the location of your sub-tools executable.

Thanks goes to [Rapptz](https://github.com/Rapptz) for help with testing.

![save-sub-delay-to-file](https://github.com/user-attachments/assets/97e3e331-a76a-4df7-8c84-7e4e87f6840a)


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
