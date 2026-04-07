#!/bin/zsh

# ==============================================================================
# xcode-cli-tools installer 🚀
# ==============================================================================

REPO="https://github.com/albtugel/xcode-cli-tools.git"
INSTALL_DIR="$HOME/xcode-cli-tools"

# ANSI Colors
G=$'\e[32m'
R=$'\e[31m'
C=$'\e[36m'
N=$'\e[0m'

echo "${C}Installing/Updating xcode-cli-tools...${N}"

# 1. Clone or update
if [[ -d "$INSTALL_DIR" ]]; then
  echo "[i] Directory exists. Pulling latest changes..."
  git -C "$INSTALL_DIR" pull --quiet
else
  echo "[*] Cloning repository to $INSTALL_DIR..."
  git clone --quiet "$REPO" "$INSTALL_DIR"
fi

# 2. Add sources to .zshrc
ZSHRC="$HOME/.zshrc"
# Убедись, что имена файлов в массиве ниже ТОЧНО совпадают с именами в репозитории
SOURCES=(
  "source $INSTALL_DIR/OpenXcodeProj.zsh"
  "source $INSTALL_DIR/RunXcodeProj.zsh"
  "source $INSTALL_DIR/TestXcodeProj.zsh"
  "source $INSTALL_DIR/CleanXcodeProj.zsh"
  "source $INSTALL_DIR/DropXcodeProj.zsh"
)

echo "[*] Registering tools in $ZSHRC..."
for line in "${SOURCES[@]}"; do
  # Проверка: если строки нет в конфиге, только тогда добавляем
  grep -qxF "$line" "$ZSHRC" || echo "$line" >> "$ZSHRC"
done

# 3. Done
echo "${G}[OK] Installation complete!${N}"
echo "${C}Run 'source ~/.zshrc' to activate the new commands.${N}"