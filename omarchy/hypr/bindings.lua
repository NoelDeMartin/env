-- Personal keybinding overrides.

-- Unbind defaults before replacing them.
hl.unbind("SUPER + T")       -- was: toggle floating/tiling
hl.unbind("SUPER + F")       -- was: full screen
hl.unbind("SUPER + SHIFT + B") -- was: browser
hl.unbind("SUPER + SHIFT + F") -- was: file manager

-- Navigation
o.bind("CTRL + SHIFT + SPACE", "Launch apps", "omarchy-menu toggle apps")
o.bind("SHIFT + F11", "Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("CTRL + ALT + RIGHT", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.bind("CTRL + ALT + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))

-- Media
o.bind("ALT + SPACE", "Play/Pause", "omarchy-shell media playPause")
o.bind("ALT + RIGHT", "Next track", "omarchy-shell media next")
o.bind("ALT + LEFT", "Previous track", "omarchy-shell media previous")
o.bind("CTRL + ALT + UP", "Volume up", "omarchy-audio-output-volume raise")
o.bind("CTRL + ALT + DOWN", "Volume down", "omarchy-audio-output-volume lower")

-- Apps
o.bind("SUPER + T", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + SHIFT + F", "File manager (cwd)", { omarchy = "nautilus-cwd" })
o.bind("SUPER + Q", "Sublime Text", { launch = "subl" })
o.bind("SUPER + A", "Code Editor", { launch = "cursor --classic" })
o.bind("SUPER + E", "Emoji picker", "omarchy-shell shell toggle omarchy.emojis")
