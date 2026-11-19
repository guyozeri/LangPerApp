# LangPerApp

A macOS menu-bar app that remembers the keyboard layout separately for each app.
If you choose Hebrew in one app and English in another, each app gets its own layout back when you switch to it.

## Build & run

```sh
./build.sh
open build/LangPerApp.app
```

Requires macOS 13+ and the Swift toolchain (Xcode or Command Line Tools). No Accessibility permission is needed.

To install, copy `build/LangPerApp.app` to `/Applications`, then turn on **Launch at Login** from the menu.

## How it works

- When you change the layout, it is saved for the frontmost app (keyed by bundle ID, stored in UserDefaults).
- When an app comes to the front, its saved layout is restored with `TISSelectInputSource`.
- The first time an app is seen, it either keeps the current layout or uses the "Default for New Apps" setting.

## Important

Turn off **System Settings → Keyboard → Input Sources → Edit… → "Automatically switch to a document's input source"**, or macOS and this app will fight over the layout.

## Debug logs

```sh
log stream --predicate 'subsystem == "LangPerApp"' --level info
```
