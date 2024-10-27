# mpv retiming scripts

### snap-to-secondary-sub

NOTE: Different subtitle tracks don't always begin or end in the same places. It is suggested to keep the secondary sub visible while retiming with this script.

Adds keybinds to make it easier to retime subs to match the timing of the internal subs in a video file:

- `Alt+c`: Set the sub-delay so the start time of the primary subtitle matches the start time of the secondary subtitle.
- `Alt+LEFT`: Execute `sub-step -1` (CTRL+SHIFT+LEFT), then execute what `Alt+c` does.
- `Alt+RIGHT`: Execute `sub-step 1` (CTRL+SHIFT+RIGHT), then execute what `Alt+c` does.
- `Alt+u`: Swap primary subtitle and secondary subtitle with each other.

### Reccomended mpv settings

To take full advantage of this script, the following settings and keybinds are helpful.
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
