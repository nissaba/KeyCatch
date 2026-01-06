//
//  GlobalEventTap.swift
//  KeyCatch
//
//  Created by Pascale on 2026-01-04.
//


import Cocoa
import Combine

final class GlobalEventTap: ObservableObject {
    // C-compatible callback (must not capture Swift context)
    private static let eventTapCallback: CGEventTapCallBack = { proxy, type, cgEvent, userInfo in
        // Recover the Swift instance from the userInfo pointer
        if let userInfo = userInfo {
            let unmanaged = Unmanaged<GlobalEventTap>.fromOpaque(userInfo)
            let instance = unmanaged.takeUnretainedValue()
            instance.handleEvent(type: type, cgEvent: cgEvent)
        }
        // Return the original event (unmodified)
        return Unmanaged.passUnretained(cgEvent)
    }

    // Instance handler invoked by the static callback
    private func handleEvent(type: CGEventType, cgEvent: CGEvent) {
        var description: String?
        switch type {
        case .keyDown:
            let keyCode = cgEvent.getIntegerValueField(.keyboardEventKeycode)
            if let nsEvent = NSEvent(cgEvent: cgEvent) {
                let chars = nsEvent.charactersIgnoringModifiers
                let currentMods = nsEvent.modifierFlags.intersection(.deviceIndependentFlagsMask)
                let modifiers: [(NSEvent.ModifierFlags, String)] = [
                    (.shift, "<Shift>"),
                    (.control, "<Control>"),
                    (.option, "<Option>"),
                    (.command, "<Command>"),
                    (.capsLock, "<Caps Lock>"),
                    (.function, "<Fn>")
                ]
                let activeMods = modifiers
                    .filter { currentMods.contains($0.0) }
                    .map { $0.1 }
                if let c = chars, !c.isEmpty {
                    let combo = (activeMods + [c]).joined(separator: " + ")
                    description = "KeyPressed: \(combo)"
                } else {
                    let combo = (activeMods + ["keyCode=\(keyCode)"]).joined(separator: " + ")
                    description = "KeyPressed: \(combo)"
                }
            } else {
                description = "KeyPressed (keyCode): \(keyCode)"
            }
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            let buttonNumber = cgEvent.getIntegerValueField(.mouseEventButtonNumber)
            let buttonName: String
            switch buttonNumber {
            case 0: buttonName = "Left Button"
            case 1: buttonName = "Right Button"
            case 2: buttonName = "Middle Button"
            case 3: buttonName = "Button 4"
            case 4: buttonName = "Button 5"
            default: buttonName = "Button \(buttonNumber)"
            }
            description = "Mouse button pressed: \(buttonName)"
        case .scrollWheel:
            let deltaY = cgEvent.getDoubleValueField(.scrollWheelEventDeltaAxis1)
            let deltaX = cgEvent.getDoubleValueField(.scrollWheelEventDeltaAxis2)
            description = "Scroll: ΔY=\(Int(deltaY)) ΔX=\(Int(deltaX))"
        case .flagsChanged:
            guard let nsEvent = NSEvent(cgEvent: cgEvent) else { break }
            let current = nsEvent.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let previous = lastModifierFlags

            let modifiers: [(NSEvent.ModifierFlags, String)] = [
                (.shift, "Shift"),
                (.control, "Control"),
                (.option, "Option"),
                (.command, "Command"),
                (.capsLock, "Caps Lock"),
                (.function, "Fn")
            ]

            if let changed = modifiers.first(where: { current.contains($0.0) != previous.contains($0.0) }) {
                let isPressed = current.contains(changed.0)
                if isPressed {
                    description = "\(changed.1) Pressed"
                }
            } else {
                let active = modifiers
                    .filter { current.contains($0.0) }
                    .map { $0.1 }
                    .joined(separator: " + ")
                description = active.isEmpty ? "No modifiers active" : "Modifiers: \(active)"
            }

            lastModifierFlags = current
        default:
            break
        }

        if let description {
            self.event = description
        }
    }

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    @Published var event: String = "No Event"
    private var lastModifierFlags: NSEvent.ModifierFlags = []
    
    func start() {
        if ensureAccessibilityPermission() {
            // KeyDown + Left/Right mouse down
            let mask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.leftMouseDown.rawValue)
            | (1 << CGEventType.rightMouseDown.rawValue)
            | (1 << CGEventType.otherMouseDown.rawValue)
            | (1 << CGEventType.scrollWheel.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)
            
            // Pass an unretained reference to self via userInfo; lifecycle tied to this instance
            let userInfo = Unmanaged.passUnretained(self).toOpaque()
            
            guard let tap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: CGEventMask(mask),
                callback: GlobalEventTap.eventTapCallback,
                userInfo: userInfo
            ) else {
                print("Failed to create event tap. Check Accessibility permission and sandbox status.")
                return
            }
            
            eventTap = tap
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        else{
            presentAccessibilityAlert()
        }
    }
    
    func stop() {
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let source = runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes) }
        runLoopSource = nil
        eventTap = nil
    }
    
    func ensureAccessibilityPermission() -> Bool{
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            print("Accessibility permission not granted. Prompting user...")
        }
        return trusted
    }
    
    private func presentAccessibilityAlert() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "KeyCatch needs Accessibility permission to capture global keyboard and mouse events.\n\nGo to System Settings > Privacy & Security > Accessibility and enable KeyCatch."
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Quit")

        // Make sure we present on the main thread
        DispatchQueue.main.async {
            let response = alert.runModal()
            switch response {
            case .alertFirstButtonReturn:
                // Try to open the Accessibility pane
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            default:
                NSApp.terminate(nil)
            }
        }
    }
}

