# LangPerApp

A macOS menu-bar app that remembers the keyboard layout separately for each app.
If you choose Hebrew in one app and English in another, each app gets its own layout back when you switch to it.

## Install (no building needed)

1. Download `LangPerApp.zip` from the [latest release](https://github.com/guyozeri/LangPerApp/releases/latest).
2. Unzip it and drag `LangPerApp.app` into **Applications**.
3. Open it. macOS will say it can't verify the app (it isn't notarized). Click **Done**, then go to **System Settings → Privacy & Security** and click **Open Anyway**.
   - If macOS says the app "is damaged", run: `xattr -dr com.apple.quarantine /Applications/LangPerApp.app`
4. From the keyboard icon in the menu bar, turn on **Launch at Login**.

Works on Apple Silicon and Intel Macs, macOS 13+.

## Build from source

```sh
./build.sh
open build/LangPerApp.app
```

This also creates `build/LangPerApp.zip` (universal binary) for distribution.

Requires macOS 13+ and the Swift toolchain (Xcode or Command Line Tools). No Accessibility permission is needed.

To install, copy `build/LangPerApp.app` to `/Applications`, then turn on **Launch at Login** from the menu.

## How it works

- When you change the layout, it is saved for the frontmost app (keyed by bundle ID, stored in UserDefaults).
- When an app comes to the front, its saved layout is restored with `TISSelectInputSource`.
- The first time an app is seen, it either keeps the current layout or uses the "Default for New Apps" setting.

## Important

Turn off **System Settings → Keyboard → Input Sources → Edit… → "Automatically switch to a document's input source"**, or macOS and this app will fight over the layout. LangPerApp detects this setting: while it's on, the menu-bar icon shows ⚠️ and an alert offers to open the Input Sources settings directly.

## Debug logs

```sh
log stream --predicate 'subsystem == "LangPerApp"' --level info
```
