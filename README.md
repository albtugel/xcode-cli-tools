# xcode-cli-tools 🚀
A collection of lightweight **Zsh** scripts to automate Xcode project navigation and CLI builds. No more digging through folders or waiting for the heavy Xcode UI just to run a build.

---

## 🛠 Features
- **Fast Navigation**: Find and open `.xcodeproj` or `.xcworkspace` files from any depth in your directory.
- **CLI Builds**: Build and deploy your app to iOS Simulators directly from the terminal.
- **Visual Feedback**: Color-coded status messages (Success/Error) to keep you informed.
- **Simulator Auto-Detect**: Automatically finds the booted simulator to save your time.
- **Testing**: Run XCTest suites on any simulator directly from the terminal.

## 🚀 Commands
- `xproj`: Interactive menu to search, select, and open your projects.
- `xrun`: Builds the project and installs it on the active iOS Simulator.
- `xtest`: Runs XCTest suite on the selected iOS Simulator.

## 📦 Installation

### One-line install via curl
```zsh
curl -fsSL https://raw.githubusercontent.com/albtugel/xcode-cli-tools/main/install.sh | zsh
```

### Manual install
1. **Clone the repository**:
```zsh
    git clone https://github.com/albtugel/xcode-cli-tools.git ~/xcode-cli-tools
```

2. **Add to your Zsh profile**:
```zsh
    echo "source ~/xcode-cli-tools/OpenXcodeProj.zsh" >> ~/.zshrc
    echo "source ~/xcode-cli-tools/RunXcodeProj.zsh" >> ~/.zshrc
    echo "source ~/xcode-cli-tools/xtest.zsh" >> ~/.zshrc
```

3. **Reload your terminal**:
```zsh
    source ~/.zshrc
```

---

Created by albtugel — iOS Developer & Automation Enthusiast.