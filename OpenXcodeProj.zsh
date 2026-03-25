# ==============================================================================
# xproj: Quick Open Xcode Projects from a Base Directory
# Usage:
#   xproj <name> -> Opens project directly
#   xproj        -> Shows interactive selection menu
# ==============================================================================
xproj() {
  local cfg="$HOME/.xproj_path"
  local base_dir selected xfile
  local C=$'\e[36m' # Cyan
  local N=$'\e[0m'  # Reset

  # Load or setup base directory
  [[ -f "$cfg" ]] && base_dir=$(<"$cfg")
  if [[ ! -d "$base_dir" ]]; then
    echo -n "${C}[?] Enter Projects Path:${N} "; read -r upath
    base_dir="${upath/#\~/$HOME}"
    [[ -d "$base_dir" ]] && echo "$base_dir" > "$cfg" || return 1
  fi

  # Scan for directories containing Xcode files
  local projects=()
  for p in "$base_dir"/*; do
    [[ -d "$p" ]] && ls "$p" | grep -qE "\.(xcodeproj|xcworkspace)$" && projects+=("$(basename "$p")")
  done

  # Interactive selection logic
  selected="$1"
  if [[ -z "$selected" ]]; then
    echo "${C}--- Projects ---${N}"
    local i=1; for p in "${projects[@]}"; do echo "  $i) $p"; ((i++)); done
    echo -n "${C}Select [1-${#projects[@]}]:${N} "; read -r ch
    selected="${projects[$((ch))]}"
  fi

  [[ -z "$selected" ]] && return 1

  # Find and open
  xfile=$(find "$base_dir/$selected" -maxdepth 1 \( -name "*.xcworkspace" -o -name "*.xcodeproj" \) | sort -r | head -n1)
  echo "[>] Opening $selected..."
  open "$xfile"
  echo "[OK] Xcode is launching."
}
