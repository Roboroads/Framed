#!/usr/bin/env bash
# Synthesises Framed's sounds and derives every platform format from them.
# Run from the repo root. Needs sox and ffmpeg (dev-machine tools only —
# neither ships in the app).
#
# The sounds are generated, not sourced: these are a handful of sine waves
# and filtered noise, and a recipe survives review, tweaking and licence
# questions in a way an opaque .wav from a stock library does not. Same
# reasoning as tools/gen_brand.py, and the same rule: edit this script, never
# the generated files.
#
# Everything sits in 1.5-2.7kHz on purpose. That's where human hearing peaks,
# where a phone speaker is actually loud, and above the low-frequency rumble
# of a street — this game is played outdoors, and a pulse nobody hears is a
# pulse nobody acts on.
set -euo pipefail

SRC="assets/audio/src"
APP="assets/audio"
RAW="android/app/src/main/res/raw"
IOS="ios/Runner/Sounds"
mkdir -p "$SRC" "$APP" "$RAW" "$IOS"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------- sources --

# pulse: the compass update. A camera beeps twice when focus locks, which is
# what the app's mark draws and what a pulse means — the game found your
# target. Two blips, a fifth apart, rising: A6 then E7.
#
# IDEA.md calls the simultaneous pulse a tell you can watch for IRL. With a
# sound it becomes a tell you can *hear*: every phone in the square fires at
# the same instant.
sox -n -r 44100 -c 1 "$TMP/p1.wav" synth 0.045 sine 1760 fade t 0.004 0.045 0.03 pad 0 0.055
sox -n -r 44100 -c 1 "$TMP/p2.wav" synth 0.10 sine 2637 fade t 0.004 0.10 0.075
sox "$TMP/p1.wav" "$TMP/p2.wav" "$SRC/pulse.wav" reverb 12 50 28 gain -n -3

# shutter: plays when a frame photo is revealed to the jury on the judging
# screen — NOT when the photo is taken. Framing is covert (IDEA.md: the
# target is never notified), so the camera itself stays silent on purpose.
# Two mechanical clicks, mirror-then-blades, from filtered noise.
sox -n -r 44100 -c 1 "$TMP/s1.wav" synth 0.010 noise fade h 0 0.010 0.009 \
  highpass 1500 lowpass 7000 pad 0 0.055
sox -n -r 44100 -c 1 "$TMP/s2.wav" synth 0.016 noise fade h 0 0.016 0.014 \
  highpass 1100 lowpass 5500
sox "$TMP/s1.wav" "$TMP/s2.wav" "$SRC/shutter.wav" reverb 8 50 20 gain -n -6

# ------------------------------------------------------- platform formats --

for src in "$SRC"/*.wav; do
  name="$(basename "$src" .wav)"

  # Android notification sounds live in res/raw and are addressed as R.raw.<name>,
  # so the filename has to be a legal resource name: lowercase, digits and
  # underscores only. A hyphen here is a build error, not a warning.
  if [[ ! "$name" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo "error: '$name' is not a legal Android resource name" >&2
    exit 1
  fi
  ffmpeg -y -loglevel error -i "$src" -c:a libvorbis -q:a 5 "$RAW/$name.ogg"

  # iOS wants CAF/AIFF/WAV in the app bundle. These are tiny, so PCM in a CAF
  # container avoids any decoder question at notification time.
  ffmpeg -y -loglevel error -i "$src" -c:a pcm_s16le "$IOS/$name.caf"

  # In-app playback (audioplayers) is one Flutter asset for both platforms,
  # so it can't be the .ogg — iOS won't decode Vorbis. MP3 plays everywhere
  # and is a tenth the size of the source .wav.
  ffmpeg -y -loglevel error -i "$src" -c:a libmp3lame -q:a 4 "$APP/$name.mp3"
done

# Only assets/audio/*.mp3 ships in the bundle: pubspec declares `assets/audio/`,
# and Flutter does not recurse into subdirectories, so assets/audio/src/ stays
# a source directory rather than payload.
for f in "$SRC"/*.wav "$APP"/*.mp3 "$RAW"/*.ogg "$IOS"/*.caf; do
  printf '%-44s %6sB  %ss\n' "$f" "$(stat -c%s "$f")" "$(soxi -D "$f" 2>/dev/null || echo '?')"
done
