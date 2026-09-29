#!/usr/bin/env python3
"""Builds the README icon images in docs/images/ from the menu bar SVGs in Design/.

Each icon is placed on a small menu-bar-like tile, in a light and a dark variant,
so it stays visible on GitHub in both themes. Template (black) icons are drawn
black on the light tile and white on the dark tile; colored icons keep their color.
"""
import re
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DESIGN = REPO / "Design"
OUT = REPO / "docs" / "images"

ICONS = {
    "silent": "MenuIconSilent.svg",
    "audible": "MenuIconAudible.svg",
    "headphones": "MenuIconHeadphonesAudible.svg",
}

THEMES = {
    # tile fill, tile border, color replacing the template black
    "light": ("#F2F2F7", "#D1D1D6", "#000000"),
    "dark": ("#2C2C2E", "#48484A", "#FFFFFF"),
}

TILE = 56
ICON = 36
OFFSET = (TILE - ICON) / 2


def inner_svg(path: Path) -> str:
    source = path.read_text()
    source = re.sub(r"<\?xml[^>]*\?>", "", source)
    source = re.sub(r"<title>.*?</title>", "", source, flags=re.S)
    match = re.search(r"<svg[^>]*>(.*)</svg>", source, flags=re.S)
    if not match:
        raise SystemExit(f"error: no <svg> element in {path}")
    return match.group(1).strip()


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, filename in ICONS.items():
        body = inner_svg(DESIGN / filename)
        for theme, (fill, border, ink) in THEMES.items():
            icon = body.replace("#000000", ink)
            svg = (
                f'<svg xmlns="http://www.w3.org/2000/svg" width="{TILE}" height="{TILE}" '
                f'viewBox="0 0 {TILE} {TILE}">\n'
                f'  <rect x="0.5" y="0.5" width="{TILE - 1}" height="{TILE - 1}" rx="12" '
                f'fill="{fill}" stroke="{border}"/>\n'
                f'  <g transform="translate({OFFSET} {OFFSET})">\n    {icon}\n  </g>\n'
                f"</svg>\n"
            )
            output = OUT / f"icon-{name}-{theme}.svg"
            output.write_text(svg)
            print(output.relative_to(REPO))


if __name__ == "__main__":
    main()
