[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Zsh](https://img.shields.io/badge/shell-zsh-blue.svg)](https://www.zsh.org/)
[![Repo Size](https://img.shields.io/github/repo-size/albtugel/xcode-cli-tools)](https://github.com/albtugel/xcode-cli-tools)
[![Last Commit](https://img.shields.io/github/last-commit/albtugel/xcode-cli-tools)](https://github.com/albtugel/xcode-cli-tools)
[![Issues](https://img.shields.io/github/issues/albtugel/xcode-cli-tools)](https://github.com/albtugel/xcode-cli-tools/issues)

# xcode-cli-tools 🚀
A collection of lightweight **Zsh** scripts to automate Xcode project navigation and CLI builds. No more digging through folders or waiting for the heavy Xcode UI just to run a build.

---

## 📦 Installation
```zsh
 brew install albtugel/homebrew-tools/xct
```

---

## 🚀 Commands
- `xproj`: Interactive menu to search, select, and open your projects.
- `xrun`: Builds the project and installs it on the active iOS Simulator.
- `xtest`: Runs XCTest suite on the selected iOS Simulator.
- `xclean`: **Soft Clean**. Removes only build artifacts and indexing logs for the current project. Shows reclaimed space.
- `xdrop`: **Hard Reset**. Wipes the entire DerivedData and simulator logs globally. Use this to free up GBs of disk space.

## 🛠 Features
- **Fast Navigation**: Find and open `.xcodeproj` or `.xcworkspace` files from any depth in your directory.
- **CLI Builds & Run**: Build and deploy your app to iOS Simulators directly from the terminal.
- **Automated Testing**: Run XCTest suites with clean, filtered terminal output (no more log spam).
- **Simulator Auto-Detect**: Automatically finds the booted simulator to save your time.
- **Smart Cleaning**: Two-tier cleaning system (Soft & Hard) with real-time disk space recovery reports.
- **Performance Focused**: xclean keeps your module caches intact to ensure lightning-fast subsequent builds.

## 💡 Usage Tips
- **Daily Driver**: Use `xclean` if your project behaves weirdly or doesn't see new files. It's fast and safe.
- **Space Saver**: Run `xdrop` once a week to reclaim those 20GB+ of hidden Xcode junk.
- **Workflow**: Run `xclean && xrun` for a guaranteed "fresh" build on your simulator.

---

Created by albtugel — iOS Developer & Automation Enthusiast.
