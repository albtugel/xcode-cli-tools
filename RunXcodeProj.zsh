# ==============================================================================
# xrun: Build and Launch iOS Project on Simulator
# Usage:
#   xrun <device_key> -> Builds for specific device (iph, pro, pm, etc.)
#   xrun              -> Shows interactive device selection
# ==============================================================================
xrun() {
  local cfg="$HOME/.xproj_path"
  local base_dir="$([[ -f "$cfg" ]] && <"$cfg")"
  local arg="$1" project scheme device_id d_name
  
  # ANSI Colors
  local G=$'\e[32m' # Green
  local R=$'\e[31m' # Red
  local C=$'\e[36m' # Cyan
  local N=$'\e[0m'  # Reset

  # 1. Locate Project
  project=$(find . -maxdepth 2 \( -name "*.xcworkspace" -o -name "*.xcodeproj" \) ! -path "*/.*" 2>/dev/null | head -n1)
  
  if [[ -z "$project" && -d "$base_dir" ]]; then
    local names=(); for p in "$base_dir"/*; do
      [[ -d "$p" ]] && ls "$p" | grep -qE "\.(xcodeproj|xcworkspace)$" && names+=("$(basename "$p")")
    done
    if [[ ${#names[@]} -eq 1 ]]; then
      echo "[i] Auto-selected: ${names[1]}"
      cd "$base_dir/${names[1]}"
    else
      echo "${C}--- Build Project ---${N}"
      local i=1; for n in "${names[@]}"; do echo "  $i) $n"; ((i++)); done
      echo -n "${C}Choice [1-${#names[@]}]:${N} "; read -r pc; cd "$base_dir/${names[$((pc))]}"
    fi
    project=$(find . -maxdepth 2 \( -name "*.xcworkspace" -o -name "*.xcodeproj" \) ! -path "*/.*" 2>/dev/null | head -n1)
  fi

  # 2. Select Device Type
  local keys=(iph pro pm plus se air 16e ipadpro ipadair ipad mini)
  if [[ -z "$arg" ]]; then
    echo "${C}--- Device ---${N}"
    local i=1; for k in "${keys[@]}"; do echo "  $i) $k"; ((i++)); done
    echo -n "${C}Choice [1-${#keys[@]}]:${N} "; read -r dc; arg="${keys[$dc]}"
  fi

  # 3. Resolve Simulator
  local info=$(xcrun simctl list devices available --json | python3 -c "
import sys, json, re
target = '$arg'
try:
    data = json.load(sys.stdin)
    cands = []
    for rt, devs in data.get('devices', {}).items():
        if 'iOS' not in rt and 'iPadOS' not in rt: continue
        for d in devs:
            if not d.get('isAvailable'): continue
            n = d['name'].lower()
            match = re.search(r'\d+', d['name'])
            v = int(match.group()) if match else 0
            if (target=='iph' and 'iphone' in n and not any(x in n for x in ['pro','max','plus','se','air','16e'])) or \
               (target=='pro' and 'iphone' in n and 'pro' in n and 'max' not in n) or \
               (target=='pm' and 'pro max' in n) or \
               (target=='plus' and 'iphone' in n and 'plus' in n) or \
               (target=='se' and 'se' in n) or \
               (target=='air' and 'iphone air' in n) or \
               (target=='16e' and '16e' in n) or \
               (target=='ipadpro' and 'ipad pro' in n) or \
               (target=='ipadair' and 'ipad air' in n) or \
               (target=='ipad' and 'ipad' in n and not any(x in n for x in ['pro','air','mini'])) or \
               (target=='mini' and 'ipad mini' in n):
                cands.append((v, d['udid'], d['name']))
    cands.sort(key=lambda x: x[0], reverse=True)
    if cands: print(f'{cands[0][1]}|{cands[0][2]}')
except: sys.exit(1)
")
  [[ -z "$info" ]] && { echo "${R}[!] No simulator found for '$arg'${N}"; return 1; }
  device_id="${info%|*}"; d_name="${info#*|}"

  # 4. Build & Launch
  local abs_p=$(realpath "$project")
  local flag="-project"; [[ "$abs_p" == *.xcworkspace ]] && flag="-workspace"
  scheme=$(xcodebuild -list $flag "$abs_p" 2>/dev/null | awk '/Schemes:/{f=1;next} f && NF{print $1;exit}')

  echo "[+] Target: $d_name"
  xcrun simctl boot "$device_id" 2>/dev/null
  pgrep -x "Simulator" >/dev/null || open -a Simulator

  echo "[*] Building '$scheme'..."
  if xcodebuild build $flag "$abs_p" -scheme "$scheme" -destination "platform=iOS Simulator,id=$device_id" -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO 2>&1 | \
    sed -e "s/.*BUILD SUCCEEDED.*/${G}** BUILD SUCCEEDED **${N}/gi" \
        -e "s/.*BUILD FAILED.*/${R}** BUILD FAILED **${N}/gi" \
        -e "s/error:/${R}error:${N}/gi" | grep -iE "succeeded|failed|error:"; then
    
    local sets=$(xcodebuild -showBuildSettings $flag "$abs_p" -scheme "$scheme" -sdk iphonesimulator 2>/dev/null)
    local bid=$(echo "$sets" | awk '/PRODUCT_BUNDLE_IDENTIFIER =/{print $3}')
    local bdir=$(echo "$sets" | awk -F' = ' '/CONFIGURATION_BUILD_DIR =/{print $2}' | xargs)
    local apath=$(find "$bdir" -name "*.app" -maxdepth 1 2>/dev/null | head -n1)

    echo "[+] Deploying..."
    xcrun simctl install "$device_id" "$apath"
    xcrun simctl launch "$device_id" "$bid"
    echo "${G}[OK] Done.${N}"
  else
    echo "${R}[!] Build stopped due to errors.${N}"
  fi
}