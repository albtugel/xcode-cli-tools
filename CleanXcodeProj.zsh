# ==============================================================================
# xclean: Deep Clean Xcode Project and Derived Data
# ==============================================================================
xclean() {
  local G=$'\e[32m' # Green
  local C=$'\e[36m' # Cyan
  local N=$'\e[0m'  # Reset

  echo "${C}[*] Starting Deep Clean...${N}"

  # 1. Standard xcodebuild clean
  local project=$(find . -maxdepth 2 \( -name "*.xcworkspace" -o -name "*.xcodeproj" \) ! -path "*/.*" 2>/dev/null | head -n1)
  if [[ -n "$project" ]]; then
    local flag="-project"; [[ "$project" == *.xcworkspace ]] && flag="-workspace"
    echo "[>] Running xcodebuild clean..."
    xcodebuild clean $flag "$project" -alltargets quiet
  fi

  # 2. Clear DerivedData for this specific project (if possible) or global
  echo "[>] Clearing DerivedData..."
  rm -rf ~/Library/Developer/Xcode/DerivedData/*
  
  # 3. Clear Swift Package Manager caches
  if [[ -d ".swiftpm" ]]; then
    echo "[>] Clearing SPM cache..."
    rm -rf .swiftpm/
  fi

  echo "${G}[OK] System is clean as a whistle.${N}"
}