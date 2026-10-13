# macOS App

## macOS App Version 1.0

### Product Page Information

#### App Previews and Screenshots

- [Screenshots.key](./Screenshots.key)

#### Promotional Text

```
Point and click without a mouse or trackpad. Move, click, and drag the pointer from the keyboard, with adjustable speed for precise, comfortable control.
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

REACH EVERY DISPLAY
Press ⌃⌥C to send the pointer to the center of the next display, so crossing a multi-monitor setup takes one keystroke per screen.

ADJUST IT TO YOUR HANDS
• Change every shortcut to keys that are comfortable for you.
• Set the starting speed, top speed, and how quickly it accelerates, and see the result on a live graph.
• Turn off individual shortcuts in apps where they would conflict.
• Export your settings and import them on another Mac.

PERMISSIONS & PRIVACY
TelePointer uses Accessibility permission only to click at the pointer's location when you press a click shortcut. It does not read or control other apps' content. It collects no data and makes no network connections.
```

#### Keywords

```
 accessibility,motor,disability,RSI,tremor,cursor,pointer,click,drag,hotkey,trackpad,multi-monitor
```

#### Support URL

```
https://taeminator1.github.io/AppStoreConnect/TelePointer/privacy
```

#### Version

```
1.0
```

#### Copyright

```
2026 TAEMIN YUN
```

### Build

```
1.0.0 (2)
```

### App Review Information

#### Notes

```
Regarding the previous rejection under guideline 2.4.5: TelePointer is a keyboard-only alternative to a mouse or trackpad for people who cannot use one comfortably or at all, similar to Mouse Keys in System Settings → Accessibility → Pointer Control. It uses Accessibility permission only to click at the pointer's location when the user presses a click shortcut. Our earlier description emphasized productivity rather than who the app is for; we have updated the description, promotional text, keywords, and support page to state its accessibility purpose clearly. The app binary is unchanged.

----

TelePointer is a menu bar app (LSUIElement). It has no Dock icon and no window at launch. After launching, look for its icon in the menu bar.

HOW TO TEST
1. Moving the pointer works immediately, with no permission:
• Hold ⌃⌥ + I / J / K / L — move up / left / down / right (starts slowly, speeds up while held)
• Hold ⌃⌥⌘ + I / J / K / L — move at a steady, gentle speed
• ⌃⌥C — move the pointer to the center of the next display (with one display, to the center of the current one)
2. Clicking requires Accessibility permission:
• Press ⌃⌥X (left click). macOS shows a prompt; choose "Open System Settings".
• In Privacy & Security → Accessibility, turn on TelePointer.
• Quit and relaunch TelePointer from its menu, then press ⌃⌥X to left-click and ⌃⌥V to right-click at the pointer's location.
3. Settings… in the menu opens the window for changing shortcuts, pointer speed, and per-app exceptions.

WHY ACCESSIBILITY
TelePointer is for people who cannot use a mouse or trackpad comfortably or at all — for example, because of limited fine motor control, tremors, or repetitive strain — but who can press keys. It works like Mouse Keys in System Settings → Accessibility → Pointer Control, with adjustable acceleration, a steady-speed mode for precise targeting, and customizable shortcuts.

Moving the pointer alone is not enough for these users; they also need to click. Accessibility permission is used only for that:
• A click is posted (CGEvent) only when the user presses a click shortcut, at the pointer's current location.
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