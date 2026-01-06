# GlobalInputExample (macOS)

A minimal macOS example app that demonstrates how to capture **global keyboard and mouse input** using a **CGEvent tap**, with the required **Accessibility permissions**.

## Overview

This project is a **small, focused macOS example** showing how to listen to system-wide input events, even when the app is not in the foreground.

It demonstrates how to:
- Capture global **keyboard events** (keyDown, keyUp)
- Detect **modifier key changes** (flagsChanged)
- Monitor **mouse clicks** and **scroll events**
- Set up a **CGEvent tap** using Core Graphics
- Handle the **Accessibility permission workflow**
- Display live input updates using **SwiftUI** and **Combine**

The goal of this app is **educational**: to provide a clean, easy-to-read reference for developers who need to understand how global input monitoring works on macOS.

## What this example does

- Creates a CGEventTap to listen to global system events
- Registers the tap on the current user session
- Streams captured events into a SwiftUI interface
- Reacts to permission issues (Accessibility not granted)
- Keeps the code intentionally **minimal and readable**

## Permissions

⚠️ **Accessibility permission is required**

macOS does not allow global input capture by default.  
When running this app, you must grant **Accessibility** access:

**System Settings → Privacy & Security → Accessibility**

Once enabled, restart the app for the event tap to become active.

## Why CGEvent taps?

CGEventTap is the **official and lowest-level API** provided by macOS to observe:
- Global keyboard input
- Modifier state changes
- Mouse and scroll events

This example avoids private APIs and focuses on **correct, system-supported behavior**.

## What this project is NOT

- Not a keylogger
- Not intended for production spying or monitoring
- Not sandbox-compatible without special entitlements

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
- Core Graphics (CGEventTap)

## License

MIT — use freely, learn from it, and adapt it to your needs.
