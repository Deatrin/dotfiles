# Tycho Keybind Cheat Sheet

## Hyprland — `SUPER` = Windows key

### Applications
| Keybind | Action |
|---|---|
| `SUPER + Enter` | Terminal (ghostty) |
| `SUPER + T` | Terminal with fastfetch |
| `SUPER + D` | App launcher (rofi) |
| `SUPER + B` | File manager (thunar) |
| `SUPER + SHIFT + S` | Emoji picker (bemoji) |
| `SUPER + P` | Password manager (rofi-pass) |

### Windows
| Keybind | Action |
|---|---|
| `SUPER + Q` | Kill active window |
| `SUPER + F` | Fullscreen |
| `SUPER + V` | Toggle floating |
| `SUPER + Space` | Toggle floating |
| `SUPER + O` | Toggle window opacity |
| `SUPER + H/J/K/L` | Move focus left/down/up/right |

### Workspaces
| Keybind | Action |
|---|---|
| `SUPER + 1-0` | Switch to workspace 1-10 |
| `SUPER + SHIFT + 1-0` | Move window to workspace 1-10 |
| `SUPER + Scroll Up/Down` | Switch workspace +1/-1 |

### Layout (dwindle)
| Keybind | Action |
|---|---|
| `SUPER + SHIFT + P` | Toggle pseudo-tiling |
| `SUPER + J` | Toggle split direction |

### System
| Keybind | Action |
|---|---|
| `SUPER + SHIFT + L` | Lock screen (hyprlock) |
| `SUPER + Escape` | Logout menu (wlogout) |
| `SUPER + M` | Exit Hyprland |

### Mouse
| Keybind | Action |
|---|---|
| `SUPER + LMB drag` | Move window |
| `SUPER + RMB drag` | Resize window |

---

## Tmux — Prefix = `Ctrl + A`

### Sessions & Clients
| Keybind | Action |
|---|---|
| `Prefix + D` / `Ctrl + D` | Detach client |
| `Prefix + R` | Reload config |

### Windows
| Keybind | Action |
|---|---|
| `Prefix + C` | New window (current path) |
| `Prefix + K` | Kill window (confirm) |
| `Prefix + SHIFT + K` | Kill window (no confirm) |
| `Prefix + Ctrl + N` | Next window |
| `Prefix + Ctrl + P` | Previous window |
| `Shift + Right` | Next window |
| `Shift + Left` | Previous window |

### Panes
| Keybind | Action |
|---|---|
| `Prefix + E` | Synchronize panes ON |
| `Prefix + SHIFT + E` | Synchronize panes OFF |

### Sessions (resurrect)
| Keybind | Action |
|---|---|
| `Prefix + Ctrl + S` | Save session |
| `Prefix + Ctrl + R` | Restore session |

### Copy mode (vi)
| Keybind | Action |
|---|---|
| `Prefix + [` | Enter copy mode |
| `V` | Begin selection |
| `Y` | Yank selection |
| `Q` / `Escape` | Exit copy mode |

---

## Neovim — `<leader>` = `\`

> Tip: press `<leader>` and wait — **which-key** will show available bindings. `:Cheatsheet` opens the full built-in cheatsheet.

### Navigation
| Keybind | Action |
|---|---|
| `h/j/k/l` | Left/down/up/right |
| `w/W` | Next word/WORD |
| `b/B` | Previous word/WORD |
| `e/E` | End of word/WORD |
| `0` | Start of line |
| `^` | First non-blank character |
| `$` | End of line |
| `gg` | Top of file |
| `G` | Bottom of file |
| `{` / `}` | Previous/next empty line (paragraph) |
| `Ctrl + d` | Half page down |
| `Ctrl + u` | Half page up |
| `Ctrl + f` | Full page down |
| `Ctrl + b` | Full page up |
| `%` | Jump to matching bracket |
| `*` / `#` | Search word under cursor forward/backward |
| `n` / `N` | Next/previous search result |
| `''` | Jump back to last position |
| `Ctrl + o` | Jump to older position in jumplist |
| `Ctrl + i` | Jump to newer position in jumplist |
| `zz` | Center cursor on screen |
| `zt` / `zb` | Cursor to top/bottom of screen |
| `H/M/L` | Jump to top/middle/bottom of screen |
| `<number>G` | Jump to line number |

### File Tree (neo-tree)
| Keybind | Action |
|---|---|
| `<leader>pv` | Open file tree |
| `<leader>pt` | Toggle file tree |

### Telescope
| Keybind | Action |
|---|---|
| `<leader><leader>` | Find open buffers |
| `<leader>sf` | Search files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Search current word |
| `<leader>s.` | Recent files |
| `<leader>sr` | Resume last search |
| `<leader>sd` | Search diagnostics |
| `<leader>ss` | Search Telescope builtins |
| `<leader>sk` | Search keymaps |
| `<leader>sh` | Search help tags |

### LSP
| Keybind | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` / `]d` | Previous/next diagnostic |
| `<leader>sd` | Search diagnostics (Telescope) |

### Git (gitsigns)
| Keybind | Action |
|---|---|
| `]c` / `[c` | Next/prev hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hu` | Undo stage hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff this |

### Motion (hop / leap)
| Keybind | Action |
|---|---|
| `s` | Leap forward |
| `S` | Leap backward |
| `<leader>hw` | Hop to word |
| `<leader>hl` | Hop to line |
| `<leader>hc` | Hop to char |

### Surround
| Keybind | Action |
|---|---|
| `ys<motion><char>` | Add surround (e.g. `ysiw"`) |
| `ds<char>` | Delete surround |
| `cs<old><new>` | Change surround |

### Terminal (toggleterm)
| Keybind | Action |
|---|---|
| `<C-\>` | Toggle terminal |
| `<leader>gg` | Open lazygit |

### Utility
| Keybind | Action |
|---|---|
| `<leader>rp` | Precognition peek (motion hints) |
| `<leader>xx` | Toggle trouble diagnostics |
| `<C-z>` | Undo highlight |
