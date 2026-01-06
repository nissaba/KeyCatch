# KeyCatch (macOS)

A minimal macOS example app that captures global keyboard and mouse input using a CGEvent tap, with the required Accessibility permissions.

## Overview

This project is a **small, focused macOS example** showing how to listen to system-wide input events, even when the app is not in the foreground.

It demonstrates how to:
- Capture global keyboard presses (keyDown)
- Show modifier combinations with keys (e.g., “KeyPressed: <Shift> + d”)
- Detect standalone modifier key changes (flagsChanged) and report presses only
- Monitor mouse clicks and scroll events
- Set up a CGEvent tap using Core Graphics
- Handle the Accessibility permission workflow
- Display live input updates using SwiftUI and Combine

## What this example does

- Creates a CGEvent tap to listen to global system events
- Registers and enables the tap on the current user session
- Streams captured events into a SwiftUI interface via Combine
- Reacts to permission issues (Accessibility not granted) and offers to open Settings
- Keeps the code intentionally minimal and readable

## Current behavior details

- Key presses:
  - Uses charactersIgnoringModifiers to keep the base character and prepends active modifiers
  - Example: pressing Shift + d shows “KeyPressed: <Shift> + d”
  - Falls back to keyCode when no character is available

- Modifier-only presses:
  - Uses flagsChanged events and reports “Shift Pressed”, “Control Pressed”, etc.
  - Releases are intentionally not reported

- Mouse:
  - Reports left, right, middle, and other mouse button presses with a readable name
  - Reports scroll deltas (ΔY and ΔX)

## Permissions

Accessibility permission is required to observe global input.

System Settings → Privacy & Security → Accessibility → Enable KeyCatch

If permission isn’t granted, the app shows a warning and offers to open the correct settings pane.

## Why CGEvent taps?

CGEvent taps are the system-supported way to observe global input on macOS:

- Global keyboard input
- Modifier state changes
- Mouse and scroll events

This example avoids private APIs and focuses on **correct, system-supported behavior**.

## What this project is NOT

- Not a keylogger
- Not intended for production spying or monitoring
- Not sandbox-compatible without special configuration

It is strictly a **learning and reference project**.

## Use cases

This pattern is useful for:
- Developer tools
- Input visualizers
- Accessibility utilities
- Shortcut managers
- Debugging or learning how macOS input works internally

## Tech stack

- macOS
- Swift
- SwiftUI
- Combine
- Core Graphics (CGEvent tap)

## License

MIT — use freely, learn from it, and adapt it to your needs.

