#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# ==============================================================================
# xtest: Run XCTest on iOS Simulator
# Usage:
#   xtest <device_key> -> Runs tests for specific device (iph, pro, pm, etc.)
#   xtest              -> Shows interactive device selection
# Run from the directory containing your .xcodeproj or .xcworkspace
# ==============================================================================
xtest() {
  local arg="$1" project scheme device_id d_name

  # ANSI Colors
  local G=$'\e[32m'
  local R=$'\e[31m'
  local C=$'\e[36m'
  local N=$'\e[0m'

  # 1. Locate Project in current directory
  project=$(find . -maxdepth 2 \( -name "*.xcworkspace" -o -name "*.xcodeproj" \) ! -path "*/.*" 2>/dev/null | head -n1)

  if [[ -z "$project" ]]; then
    echo "${R}[!] No Xcode project found in current directory.${N}"
    echo "${C}[i] cd into your project folder first, then run xtest.${N}"
    return 1
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

  # 4. Resolve Scheme
  local abs_p=$(realpath "$project")
  local flag="-project"; [[ "$abs_p" == *.xcworkspace ]] && flag="-workspace"
  scheme=$(xcodebuild -list $flag "$abs_p" 2>/dev/null | awk '/Schemes:/{f=1;next} f && NF{print $1;exit}')

  # 5. Boot Simulator
  echo "[+] Project: $(basename "$abs_p")"
  echo "[+] Target: $d_name"
  xcrun simctl boot "$device_id" 2>/dev/null
  pgrep -x "Simulator" >/dev/null || open -a Simulator

  # 6. Run Tests
  echo "[*] Running tests for '$scheme'..."
  echo "----------------------------------------"

  xcodebuild test \
    $flag "$abs_p" \
    -scheme "$scheme" \
    -destination "platform=iOS Simulator,id=$device_id" \
    -sdk iphonesimulator \
    CODE_SIGNING_ALLOWED=NO 2>&1 | \
  awk -v G="$G" -v R="$R" -v C="$C" -v N="$N" '
    /Test Suite .* started/  { print C $0 N }
    /Test Case .* passed/    { print G "  ✓ " $0 N }
    /Test Case .* failed/    { print R "  ✗ " $0 N }
    /Test Suite .* passed/   { print G $0 N }
    /Test Suite .* failed/   { print R $0 N }
    /BUILD SUCCEEDED/        { print G $0 N }
    /BUILD FAILED/           { print R $0 N }
  '

  echo "----------------------------------------"
  echo "${G}[OK] Done.${N}"
}

xtest "$@"