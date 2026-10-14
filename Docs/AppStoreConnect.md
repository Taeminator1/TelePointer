# macOS App

## macOS App Version 1.1

### Product Page Information

#### App Previews and Screenshots

- [Screenshots.key](./Screenshots.key)

#### Promotional Text

```
Point and click without a mouse or trackpad. Move, click, drag, and scroll from the keyboard, with adjustable speed for precise, comfortable control.
```

#### Description

```
TelePointer lets you control the mouse pointer entirely from the keyboard. It is built for people who find a mouse or trackpad difficult or impossible to use — because of limited fine motor control, tremors, pain, or repetitive strain — but who can press keys.

MOVE THE POINTER
Hold ⌃⌥ with I, J, K, or L to move up, left, down, or right. The pointer starts slowly so small targets are easy to reach, then speeds up the longer you hold.

PRECISE, STEADY MOVEMENT
Add ⌘ (⌃⌥⌘ + I/J/K/L) to move at a constant, gentle speed when you need to line up something small.

CLICK AND DRAG
Press ⌃⌥X to left-click and ⌃⌥V to right-click at the pointer's location. Press again quickly to double-click. Hold the click shortcut while moving to drag.

SCROLL
Hold ⌃⌥Z and press I, J, K, or L to scroll up, left, down, or right under the pointer, just like a mouse wheel.

RESPONDS LIKE A REAL MOUSE
Buttons and links show their hover effects as the pointer passes over them, and an auto-hidden Dock and Hot Corners respond at the screen edges.

REACH EVERY DISPLAY
Press ⌃⌥C to send the pointer to the center of the next display, so crossing a multi-monitor setup takes one keystroke per screen.

ADJUST IT TO YOUR HANDS
• Change every shortcut to keys that are comfortable for you.
• Set the starting speed, top speed, and how quickly it accelerates, and see the result on a live graph.
• Turn off individual shortcuts in apps where they would conflict.
• Export your settings and import them on another Mac.

PERMISSIONS & PRIVACY
TelePointer uses Accessibility permission only to send clicks, drags, scrolls, and pointer movement to the apps under the pointer when you press its shortcuts, so they respond as they would to a mouse. It does not read or control other apps' content. It collects no data and makes no network connections.
```

#### What's New in This Version

```
• Scroll from the keyboard: hold ⌃⌥Z and press I, J, K, or L to scroll under the pointer.
• Hover effects, an auto-hidden Dock, and Hot Corners now respond when you move the pointer with the keyboard.
• Korean localization, following your system language.
• Now runs on macOS 15 Sequoia and later.
```

#### Keywords

```
accessibility,motor,disability,RSI,tremor,cursor,mouse,click,drag,hotkey,trackpad,multi-monitor
```

#### Support URL

```
https://taeminator1.github.io/AppStoreConnect/TelePointer/support
```

#### Version

```
1.1
```

#### Copyright

```
2026 TAEMIN YUN
```

### Build

```
1.1.0 (3)
```

### App Review Information

#### Notes

```
Regarding guideline 2.4.5, raised in the review of version 1.0: TelePointer remains a keyboard-only alternative to a mouse or trackpad for people who cannot use one comfortably or at all. Version 1.1 adds scrolling from the keyboard, hover updates while the pointer moves, and Korean localization. The purpose of the Accessibility permission is unchanged; see WHY ACCESSIBILITY below.

----

TelePointer is a menu bar app (LSUIElement). It has no Dock icon and no window at launch. After launching, look for its icon in the menu bar.

HOW TO TEST
1. Moving the pointer works immediately, with no permission:
• Hold ⌃⌥ + I / J / K / L — move up / left / down / right (starts slowly, speeds up while held)
• Hold ⌃⌥⌘ + I / J / K / L — move at a steady, gentle speed
• ⌃⌥C — move the pointer to the center of the next display (with one display, to the center of the current one)
2. Clicking, scrolling, and hover updates require Accessibility permission:
• Press ⌃⌥X (left click). macOS shows a prompt; choose "Open System Settings".
• In Privacy & Security → Accessibility, turn on TelePointer.
• Quit and relaunch TelePointer from its menu, then press ⌃⌥X to left-click and ⌃⌥V to right-click at the pointer's location.
• Hold ⌃⌥Z and press I / J / K / L to scroll up / left / down / right under the pointer.
• Move the pointer over a button or link: its hover effect appears without touching the mouse. Moving to a screen edge reveals an auto-hidden Dock and triggers Hot Corners.
3. Settings… in the menu opens the window for changing shortcuts, pointer speed, and per-app exceptions.
4. The interface is in English or Korean, following the system language.

WHY ACCESSIBILITY
TelePointer is for people who cannot use a mouse or trackpad comfortably or at all — for example, because of limited fine motor control, tremors, or repetitive strain — but who can press keys. It works like Mouse Keys in System Settings → Accessibility → Pointer Control, with adjustable acceleration, a steady-speed mode for precise targeting, and customizable shortcuts.

Moving the pointer alone is not enough for these users; they also need to click, drag, and scroll, and the apps under the pointer need to respond as they would to a mouse. Accessibility permission is used only for that:
• Mouse events (CGEvent) — clicks, drags, scrolls, and pointer movement — are posted only while the user presses a TelePointer shortcut, at the pointer's current location.
• TelePointer does not read, observe, or control other apps' interfaces or content.
• It does not automate input or record keystrokes.
• The app is sandboxed, collects no data, and makes no network connections.
```

### App Store Version Release

- Automatically release this version

# General

## App Information

### Localizable Information

#### Name

```
TelePointer
```

#### Subtitle

```
Keyboard pointer control
```

### General Information

#### Bundle ID

```
com.taeminyun.TelePointer
```

#### SKU

```
telepointer
```

#### Primary Language

- English (U.S.)

#### Category

- Utilities
- Productivity

#### Content Rights

```
No, this app does not contain, show, or access third-party content.
```

#### License Agreement

```
Apple’s Standard License Agreement
```

#### Age Rating

- 4+: 172 countries or regions
- AL: Brazil
- ALL: Korea, Republic of
- 00+: Vietnam

# App Store

## Trust & Safety

### App Privacy

#### Privacy Policy

##### Privacy Policy URL

```
https://taeminator1.github.io/AppStoreConnect/TelePointer/privacy
```

#### Data Types

```
Data is not collected from this app.
```

## Monetization

### Pricing and Availability

#### App Availability

- 175 Available

### App Distribution Methods

- Public — Discoverable by anyone on the App Store (default)
  - Offer a reduced price on the Apple School Manager for volume purchases

### Last-Compatible Version Settings

| PLATFORM | AVAILABLE VERSIONS |
| --- | --- |
| macOS | All |