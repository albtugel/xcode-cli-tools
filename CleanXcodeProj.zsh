#!/bin/zsh
# ==============================================================================
# xclean: Soft Clean (Build Artifacts & Index)
# ==============================================================================
xclean() {
  local cfg="$HOME/.xproj_path"
  local project flag build_dir
  local G=$'\e[32m' ; local R=$'\e[31m' ; local C=$'\e[36m' ; local N=$'\e[0m'

  project=$(find . -maxdepth 2 \( -name "*.xcworkspace" -o -name "*.xcodeproj" \) ! -path "*/.*" 2>/dev/null | head -n1)
  
  if [[ -z "$project" ]]; then
    echo "${R}[!] No Xcode project found here.${N}"
    return 1
  fi

  local abs_p=$(realpath "$project")
  flag="-project"; [[ "$abs_p" == *.xcworkspace ]] && flag="-workspace"
  build_dir=$(xcodebuild -showBuildSettings $flag "$abs_p" 2>/dev/null | awk -F' = ' '/CONFIGURATION_BUILD_DIR =/{print $2}' | xargs)

  if [[ -d "$build_dir" ]]; then
    local before=$(du -sh "$build_dir" | awk '{print $1}')
    echo "${C}[*] Soft cleaning: $(basename "$project")...${N}"
    echo "[>] Space to reclaim: $before"

    xcodebuild clean $flag "$abs_p" -alltargets -quiet 2>/dev/null
    rm -rf "$build_dir"
    
    local project_dd="${build_dir%Build/*}"
    [[ -d "${project_dd}Index.noindex" ]] && rm -rf "${project_dd}Index.noindex"

    echo "${G}[OK] Cleaned $before. Next build will be incremental.${N}"
  else
    echo "${R}[!] Build directory not found. Already clean?${N}"
  fi
}