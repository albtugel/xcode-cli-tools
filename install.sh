#!/bin/zsh

# ==============================================================================
# xcode-cli-tools installer
# ==============================================================================

REPO="https://github.com/albtugel/xcode-cli-tools.git"
INSTALL_DIR="$HOME/xcode-cli-tools"

# ANSI Colors
G=$'\e[32m'
R=$'\e[31m'
C=$'\e[36m'
N=$'\e[0m'

echo "${C}Installing xcode-cli-tools...${N}"

# 1. Clone or update
if [[ -d "$INSTALL_DIR" ]]; then
  echo "[i] Already installed, updating..."
  git -C "$INSTALL_DIR" pull --quiet
else
  git clone --quiet "$REPO" "$INSTALL_DIR"
fi

# 2. Add sources to .zshrc
ZSHRC="$HOME/.zshrc"
SOURCES=(
  "source $INSTALL_DIR/OpenXcodeProj.zsh"
  "source $INSTALL_DIR/RunXcodeProj.zsh"
  "source $INSTALL_DIR/xtest.zsh"
)

echo "[*] Registering tools in $ZSHRC..."
for line in "${SOURCES[@]}"; do
  grep -qxF "$line" "$ZSHRC" || echo "$line" >> "$ZSHRC"
done

# 3. Done
echo "${G}[OK] Installed! Run 'source ~/.zshrc' to activate.${N}"