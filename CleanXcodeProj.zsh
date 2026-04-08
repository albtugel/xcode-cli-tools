#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# ==============================================================================
# xclean: Soft Clean (DerivedData for current project)
# Run from the directory containing your .xcodeproj or .xcworkspace
# ==============================================================================
xclean() {
  local project flag
  local G=$'\e[32m'; local R=$'\e[31m'; local C=$'\e[36m'; local N=$'\e[0m'

  # 1. Locate Project
  project=$(find . -maxdepth 2 \( -name "*.xcworkspace" -o -name "*.xcodeproj" \) ! -path "*/.*" 2>/dev/null | head -n1)

  if [[ -z "$project" ]]; then
    echo "${R}[!] No Xcode project found in current directory.${N}"
    echo "${C}[i] cd into your project folder first, then run xclean.${N}"
    return 1
  fi

  local abs_p=$(realpath "$project")
  local project_name=$(basename "$abs_p" | sed 's/\.\(xcodeproj\|xcworkspace\)$//')
  local derived_data="$HOME/Library/Developer/Xcode/DerivedData"

  # 2. Find DerivedData folder for this project (name-HASH pattern)
  local dd_folder=$(find "$derived_data" -maxdepth 1 -type d -name "${project_name}-*" 2>/dev/null | head -n1)

  if [[ -z "$dd_folder" ]]; then
    echo "${G}[✓] Nothing to clean — no DerivedData found for '$project_name'.${N}"
    return 0
  fi

  # 3. Clean
  local size=$(du -sh "$dd_folder" 2>/dev/null | awk '{print $1}')
  echo "${C}[*] Cleaning DerivedData for '$project_name'...${N}"
  echo "[>] Space to reclaim: $size"

  flag="-project"; [[ "$abs_p" == *.xcworkspace ]] && flag="-workspace"
  xcodebuild clean $flag "$abs_p" -alltargets -quiet 2>/dev/null
  rm -rf "$dd_folder"

  echo "${G}[✓] Done. Reclaimed $size. Next build will be a full rebuild.${N}"
}

xclean "$@"