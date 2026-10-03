# Claude Code status line. Packaged by pkgs/claude-statusline.nix and wired into
# ~/.claude/settings.json by aspects/homeManager/claude.nix
# (dotfiles.claude.statusLine.enable).
#
# Segments (left to right), each omitted when its data is missing:
#   host  [git branch/upstream/stash]  [jj change id]  [model]  [ctx NN%]  [5h/7d limits]

input=$(cat)

cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$cwd" ] && cwd="$PWD"

# Tokyonight palette, matching the oh-my-posh prompt theme
HOST_COLOR=$'\033[38;2;187;154;247m'   # #bb9af7 purple
GIT_COLOR=$'\033[38;2;125;207;255m'    # #7dcfff cyan
JJ_COLOR=$'\033[38;2;158;206;106m'     # #9ece6a green
MODEL_COLOR=$'\033[38;2;255;158;100m'  # #ff9e64 orange
DIM_COLOR=$'\033[38;2;86;95;137m'      # #565f89 grey, usage below 50%
WARN_COLOR=$'\033[38;2;224;175;104m'   # #e0af68 yellow, usage 50-80%
CRIT_COLOR=$'\033[38;2;247;118;142m'   # #f7768e red, usage above 80%
RESET=$'\033[0m'

pct_color() {
  if [ "$1" -gt 80 ]; then printf '%s' "$CRIT_COLOR"
  elif [ "$1" -ge 50 ]; then printf '%s' "$WARN_COLOR"
  else printf '%s' "$DIM_COLOR"; fi
}

# --- host: uname -n rather than hostname -s, so it works on NixOS and macOS
# without an extra package (macOS reports e.g. "tynan.local", hence the cut).
host_segment="${HOST_COLOR}$(uname -n | cut -d. -f1) ${RESET}"

# --- git: HEAD (branch or short SHA), ahead/behind upstream, stash count ---
git_segment=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    upstream_icon=""
    counts=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
    if [ -n "$counts" ]; then
      read -r behind ahead <<<"$counts"
      if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then upstream_icon="⇕ "
      elif [ "$ahead" -gt 0 ]; then upstream_icon="⇡ "
      elif [ "$behind" -gt 0 ]; then upstream_icon="⇣ "; fi
    fi
    stash_part=""
    stash_count=$(git -C "$cwd" --no-optional-locks stash list 2>/dev/null | wc -l | tr -d ' ')
    [ "$stash_count" -gt 0 ] && stash_part="  ${stash_count}"
    git_segment="${GIT_COLOR} ${upstream_icon}${branch}${stash_part} ${RESET}"
  fi
fi

# --- jj: working-copy change id, only when inside a jj repo ---
# --ignore-working-copy is mandatory here: without it, every status line refresh
# would snapshot the working copy, take repo locks, and could trigger commit
# signing that hangs on a 1Password/SSH agent prompt. The timeout keeps a
# slow/broken jj from stalling the status line.
jj_segment=""
if command -v jj >/dev/null 2>&1; then
  jj_change_id=$(timeout 1 jj -R "$cwd" log -r @ --no-graph --ignore-working-copy --color never -T 'change_id.shortest(8)' 2>/dev/null)
  [ -n "$jj_change_id" ] && jj_segment="${JJ_COLOR}jj:${jj_change_id} ${RESET}"
fi

# --- model: display name, falling back to the model id ---
model_segment=""
model=$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // empty' 2>/dev/null)
[ -n "$model" ] && model_segment="${MODEL_COLOR}${model} ${RESET}"

# --- context window usage: null before the first API response ---
ctx_segment=""
ctx=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
ctx=${ctx%.*}
case "$ctx" in
  ''|*[!0-9]*) ;;
  *) ctx_segment="$(pct_color "$ctx")ctx ${ctx}% ${RESET}" ;;
esac

# --- subscription rate limits: 5-hour and 7-day windows ---
# rate_limits only appears for Pro/Max subscribers after the first API response,
# and each window can be independently absent.
limits_segment=""
now=$(date +%s)
for window in five_hour:5h seven_day:7d; do
  key=${window%%:*}
  label=${window##*:}
  read -r used resets <<<"$(printf '%s' "$input" | jq -r --arg k "$key" \
    '.rate_limits[$k] // empty | "\(.used_percentage // "") \(.resets_at // "")"' 2>/dev/null)"
  used=${used%.*}
  case "$used" in ''|*[!0-9]*) continue ;; esac
  reset_part=""
  case "$resets" in
    ''|*[!0-9]*) ;;
    *)
      left=$((resets - now))
      if [ "$left" -ge 86400 ]; then
        reset_part=" ($((left / 86400))d$((left % 86400 / 3600))h)"
      elif [ "$left" -gt 0 ]; then
        reset_part=" ($((left / 3600))h$((left % 3600 / 60))m)"
      fi
      ;;
  esac
  limits_segment="${limits_segment}$(pct_color "$used")${label} ${used}%${reset_part} ${RESET}"
done

printf '%s\n' "${host_segment}${git_segment}${jj_segment}${model_segment}${ctx_segment}${limits_segment}"
