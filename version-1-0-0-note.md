# Sinc Rev. 1 Keyboard Layout

## Feature

Version 1.0.0 adds a layered keyboard layout for the Sinc Rev. 1 keyboard. It provides:

- A QWERTY base layer for normal typing. (Layer 0)
- A function layer for function keys, navigation, RGB controls, and media controls.
- A Colemak alternate typing layer. (Layer 2)
- Layer switching through `DF(0)`, `DF(2)`, and `MO(1)`.
- Two rotary encoders with both setup for volume control.
- Left side macros are consistent across both layer 0 and 2 for easy layout switching.

## What Was Updated

- Added the complete Sinc Rev. 1 layout.
- Added the QWERTY base layer, including standard alphanumeric keys, modifiers, navigation, media playback, and system keys.
- Added the function layer with RGB hue, saturation, and brightness controls; function keys; cursor navigation; and transparent fall-through keys.
- Added a Colemak layer by changing the letter positions while retaining the base layer's modifier, navigation, media, and number-key behavior.
- Added audio toggle behavior on the Colemak layer.
- Configured encoder actions for volume control, RGB mode selection, and previous/next media track control.
- Preserved unused positions with `KC_NO` and inherited base-layer behavior with `KC_TRNS`.

## Layer Summary

| Layer | Purpose | Main controls |
| --- | --- | --- |
| 0 | QWERTY base | Typing, modifiers, navigation, media, and system keys |
| 1 | Function and utility | Function keys, RGB settings, navigation, and media controls |
| 2 | Colemak alternate | Colemak typing layout with alternate audio and encoder behavior |

## File

The layout definition is stored in [`version-1-0-0`](version-1-0-0).
