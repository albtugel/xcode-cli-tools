#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# ==============================================================================
# xdrop: Hard Reset (Global DerivedData & Logs)
# ==============================================================================
xdrop() {
  local G=$'\e[32m' ; local R=$'\e[31m' ; local C=$'\e[36m' ; local N=$'\e[0m'
  local dd_path="$HOME/Library/Developer/Xcode/DerivedData"

  echo "${R}[!!!] WARNING: Hard reset of ALL Xcode Data [!!!]${N}"
  
  if [[ -d "$dd_path" ]]; then
    local size=$(du -sh "$dd_path" | awk '{print $1}')
    echo "${C}[i] Total DerivedData size: $size${N}"
  fi

  echo -n "${C}[?] Reclaim this space? (y/n):${N} "
  read -r answer

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "[>] Wiping global DerivedData..."
    rm -rf "$dd_path"/*
    rm -rf ~/Library/Logs/CoreSimulator/*
    
    echo "${G}[OK] Deep space clean finished. $size reclaimed.${N}"
  else
    echo "${C}[*] Aborted. No data deleted.${N}"
  fi
}