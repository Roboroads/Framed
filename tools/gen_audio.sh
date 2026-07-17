#!/usr/bin/env bash
# Synthesises Framed's sounds from scratch with sox. Run from the repo root.
#
# The sounds are generated, not sourced: a two-tone blip is a handful of
# sine waves, and a recipe survives review, tweaking and licence questions
# in a way an opaque .wav from a stock library does not. Same reasoning as
# tools/gen_brand.py.
#
# Everything sits in 1.5-2.7kHz on purpose. That's where human hearing
# peaks, where a phone speaker is actually loud, and above the low-frequency
# rumble of a street — this game is played outdoors, and a pulse nobody
# hears is a pulse nobody acts on.
#
# Output here is the SOURCE format only (44.1kHz mono wav). Platform
# formats derive from it — see the audio issue.
set -euo pipefail

OUT="assets/audio/src"
mkdir -p "$OUT"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# pulse: the compass update. A camera beeps twice when focus locks, which is
# exactly what the app's mark draws and exactly what a pulse means — the
# game found your target. Two blips, a fifth apart, rising: A6 then E7.
#
# IDEA.md calls the simultaneous pulse a tell you can watch for IRL. With a
# sound, it becomes a tell you can *hear*: every phone in the square chirps
# at once.
sox -n -r 44100 -c 1 "$TMP/a1.wav" synth 0.045 sine 1760 fade t 0.004 0.045 0.03 pad 0 0.055
sox -n -r 44100 -c 1 "$TMP/a2.wav" synth 0.10 sine 2637 fade t 0.004 0.10 0.075
sox "$TMP/a1.wav" "$TMP/a2.wav" "$OUT/pulse.wav" reverb 12 50 28 gain -n -3

for f in "$OUT"/*.wav; do
  printf '%-28s %ss\n' "$f" "$(soxi -D "$f")"
done
