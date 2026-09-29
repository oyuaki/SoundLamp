# Icon source files

The SVG files in this directory are the editable masters for SoundLamp's menu bar and app icons.

- `MenuIconSilent.svg`: black outline only, for macOS template rendering.
- `MenuIconAudible.svg`: filled system-blue lamp with light rays.
- `AppIcon.svg`: full app icon master for 64–1024 px exports.
- `AppIconSmall.svg`: bulb-only optical master for clean 16–32 px exports.

Run `scripts/export-icons.sh` from anywhere inside the repository to regenerate every PNG referenced by the asset catalogs. The exporter uses macOS AppKit through `osascript`, converts the output to sRGB, preserves transparency, and verifies each PNG's pixel dimensions with `sips`. It has no third-party dependencies.

Run `scripts/export-readme-icons.py` to regenerate the README icon tiles in `docs/images/` (light and dark variants).
