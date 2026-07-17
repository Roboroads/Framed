#!/usr/bin/env python3
"""Generate every Framed brand raster from one SVG geometry.

Run from the repo root. Writes the SVG sources to assets/brand/ and the
platform rasters straight into the Android res tree and the iOS asset
catalogue.
"""
import json
import os
import subprocess
import sys

CHARCOAL = "#14100F"
BONE = "#F2EDEB"
CRIMSON = "#E0313E"
TILT = -6  # handheld: you grabbed the shot, you didn't line it up


def brackets(cx, cy, box, stroke, color):
    h = box / 2
    corners = [
        (cx - h, cy - h, 1, 1), (cx + h, cy - h, -1, 1),
        (cx + h, cy + h, -1, -1), (cx - h, cy + h, 1, -1),
    ]
    arms = (0.30, 0.26, 0.30, 0.26)  # opposite pairs match; adjacent don't
    return "\n    ".join(
        f'<path d="M {x + sx * a * box:.1f} {y:.1f} L {x:.1f} {y:.1f} '
        f'L {x:.1f} {y + sy * a * box:.1f}" fill="none" stroke="{color}" '
        f'stroke-width="{stroke:.1f}" stroke-linecap="butt" stroke-linejoin="miter"/>'
        for (x, y, sx, sy), a in zip(corners, arms)
    )


def bust(cx, cy, s, color):
    head_r, head_cy = 62 * s, cy - 58 * s
    sw, sb = 150 * s, cy + 130 * s
    return (
        f'<circle cx="{cx:.1f}" cy="{head_cy:.1f}" r="{head_r:.1f}" fill="{color}"/>'
        f'<path d="M {cx - sw:.1f} {sb:.1f} A {sw:.1f} {sw * 0.95:.1f} 0 0 1 '
        f'{cx + sw:.1f} {sb:.1f} Z" fill="{color}"/>'
    )


def mark_svg(size, field, box, stroke, subject_scale):
    c = size / 2
    k = size / 1024
    bg = f'<rect width="{size}" height="{size}" fill="{field}"/>' if field else ""
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">
  {bg}
  <g transform="rotate({TILT} {c} {c})">
    {brackets(c, c, box * k, stroke * k, BONE)}
    {bust(c, c + 10 * k, subject_scale * k, CRIMSON)}
  </g>
</svg>
'''


def png(svg_path, out, w):
    subprocess.run(["inkscape", svg_path, "-w", str(w), "-h", str(w), "-o", out],
                   check=True, capture_output=True)


ROOT = os.getcwd()
BRAND = f"{ROOT}/assets/brand"
RES = f"{ROOT}/android/app/src/main/res"
IOS = f"{ROOT}/ios/Runner/Assets.xcassets"

os.makedirs(BRAND, exist_ok=True)

# --- SVG sources (checked in; these are the real design artefacts) ---
# Full-bleed: iOS icon, legacy Android icon, launch screens.
open(f"{BRAND}/icon.svg", "w").write(mark_svg(1024, CHARCOAL, 620, 58, 1.0))
# Adaptive foreground: mark shrunk into Android's centre-66% safe zone.
open(f"{BRAND}/icon-foreground.svg", "w").write(mark_svg(1024, None, 470, 44, 0.76))
# Launch mark: same geometry, no field (drawn over a solid colour layer).
open(f"{BRAND}/launch-mark.svg", "w").write(mark_svg(1024, None, 620, 58, 1.0))

# --- Android legacy mipmaps ---
for d, s in [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144),
             ("xxxhdpi", 192)]:
    png(f"{BRAND}/icon.svg", f"{RES}/mipmap-{d}/ic_launcher.png", s)

# --- Android adaptive foreground (108dp canvas) ---
for d, s in [("mdpi", 108), ("hdpi", 162), ("xhdpi", 216), ("xxhdpi", 324),
             ("xxxhdpi", 432)]:
    png(f"{BRAND}/icon-foreground.svg", f"{RES}/mipmap-{d}/ic_launcher_foreground.png", s)

# --- Android launch mark (centred bitmap over a colour layer) ---
for d, s in [("mdpi", 96), ("hdpi", 144), ("xhdpi", 192), ("xxhdpi", 288),
             ("xxxhdpi", 384)]:
    png(f"{BRAND}/launch-mark.svg", f"{RES}/drawable-{d}/launch_mark.png", s)

# --- iOS app icon: drive every size off the catalogue's own Contents.json ---
appicon = f"{IOS}/AppIcon.appiconset"
meta = json.load(open(f"{appicon}/Contents.json"))
for img in meta["images"]:
    side = float(img["size"].split("x")[0])
    scale = int(img["scale"].rstrip("x"))
    png(f"{BRAND}/icon.svg", f"{appicon}/{img['filename']}", round(side * scale))

# --- iOS launch image ---
launch = f"{IOS}/LaunchImage.imageset"
for name, s in [("LaunchImage.png", 128), ("LaunchImage@2x.png", 256),
                ("LaunchImage@3x.png", 384)]:
    png(f"{BRAND}/launch-mark.svg", f"{launch}/{name}", s)

print("brand rasters regenerated")
