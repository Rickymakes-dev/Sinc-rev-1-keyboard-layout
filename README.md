# Sinc Rev. 1 Keyboard Layout

A layered keyboard layout for the Sinc Rev. 1 keyboard.

## Current Version

The current layout is version 1.0.0 and is located in [`v1-0-0/version-1-0-0`](v1-0-0/version-1-0-0).

The release notes are available in [`v1-0-0/version-1-0-0-note.md`](v1-0-0/version-1-0-0-note.md).

## Creating a New Version

1. Load the latest layout in [VIA](https://www.usevia.app/), modify it, and save the new `.json` file into the `download` folder in this repo.
2. Open `New-Version.ps1`, set the call at the bottom to `New-Version -Major $false -ImportMode $true` (use `-Major $true` for a major update, e.g. v1-0-0 to v2-0-0), and press the Run button in VS Code.
3. The script creates the next version folder with the `.json` moved in from `download` and the updated note file, then empties the `download` folder.
4. For a manual code modification instead, set the call to `New-Version -Major $false -ImportMode $false`. The script creates the new version folder with the last version's `.json` and the updated note file copied over. Edit the `.json` yourself afterwards.
5. Fill in the "What Was Updated" section of the new note file.

Note: `download/.gitkeep` is an empty placeholder that keeps the otherwise empty `download` folder from being dropped by Git. Do not delete it; the script leaves it in place when emptying the folder.
