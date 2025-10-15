
# config.nu
#
# Installed by:
# version = "0.102.0"

cd C:/projects
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.EDITOR = "nvim"

use 'C:\Users\gabri\AppData\Roaming\dystroy\broot\config\launcher\nushell\br' *
alias cop = cd ~\OneDrive\Documents\copera
alias api = cd ~\OneDrive\Documents\copera\apps\api
alias s = jj status

# -- functions --
def rg [...args] {
  let result = (uv run C:\custom_scripts\from_nu\list_files.py ...$args)

  if ($result | is-empty) {
    print "⚠️  No files found"
  } else {
    print $"✅ ($result | lines | length) file(s) found"
    $result | clip
  }
}

# Set up a default font home
if ($nu.os-info.name | str downcase | str contains "windows") {
    $env.FONT_HOME = "C:/Users/gabri/.fonts"
} else {
    $env.FONT_HOME = "~/.local/share/fonts"
}

def add-font [name: string] {
    let path = ($env.FONT_HOME | path join $name)
    if ($path | path exists) {
        # Register from that directory
        ^fontreg $path
        print $"✅ Registered fonts from ($path)"
    } else {
        print $"⚠️ Folder not found: ($path)"
    }
}

def remove-font [name: string] {
    let path = ($env.FONT_HOME | path join $name)
    if ($path | path exists) {
        # remove the directory
        rm $path --recursive --force
        # refresh font cache
        ^fontreg /r
        print $"️ Removed fonts and refreshed cache: ($name)"
    } else {
        print $"⚠️ Folder not found: ($path)"
    }
}

def refresh-fonts [] {
    if ($nu.os-info.name | str downcase | str contains "windows") {
        ^fontreg /r
    } else {
        # For Unix‐like
        ^fc-cache -fv ($env.FONT_HOME)
    }
    print " Font cache refreshed."
}

def install-font [
    name: string,
    --repo: string = "ryanoasis/nerd-fonts"
] {
    # Make sure the font home exists
    mkdir $env.FONT_HOME

    let url = $"https://github.com/($repo)/releases/latest/download/($name).zip"
    let dest = ($nu.temp-path | path join $"($name).zip")
    let target = ($env.FONT_HOME | path join $name)

    print $"⬇️ Downloading ($name) from ($repo)..."
    http get $url | save -f $dest

    print " Extracting..."
    mkdir $target
    # Use tar or unzip (assuming zip is extractable via tar)
    ^tar -xf $dest -C $target

    if ($nu.os-info.name | str downcase | str contains "windows") {
        print " Registering with fontreg..."
        ^fontreg $target
    } else {
        print " Refreshing font cache..."
        ^fc-cache -fv ($env.FONT_HOME)
    }

    # cleanup
    rm $dest
    print $"✅ Installed ($name) font successfully!"
}


# -----------

$env.PROMPT_COMMAND_RIGHT = { || "" }


# --- WezTerm "classics" hotkeys banner ---------------------------------------
if $nu.is-interactive {
  let banner = [
    ""
    "WEZTERM HOTKEYS (essentials)"
    "Tabs:"
    "  Ctrl+Shift+T       → New tab"
    "  Ctrl+Shift+W       → Close tab"
    "  Ctrl+Tab           → Next tab"
    "  Ctrl+Shift+Tab     → Previous tab"
    ""
    "Panes:"
    "  Ctrl+Alt+%         → Split horizontal"
    "  Ctrl+Alt+\"        → Split vertical"
    "  Ctrl+Shift+Arrow   → Move focus between panes"
    "  Ctrl+Alt+Shift+Arrow → Resize pane"
    ""
    "Copy & Paste:"
    "  Ctrl+Shift+C       → Copy"
    "  Ctrl+Shift+V       → Paste"
    ""
    "Other:"
    "  Ctrl+Shift+F       → Search"
    "  Ctrl+Plus/Minus    → Zoom font in/out"
    "  Ctrl+0             → Reset font size"
    "  Ctrl+Shift+Z       → Toggle pane zoom"
    "  F11                → Toggle fullscreen"
    ""
  ]
  print ($banner | str join (char nl))
}
