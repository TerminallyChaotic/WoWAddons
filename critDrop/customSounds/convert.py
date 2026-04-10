#!/usr/bin/env python3
"""
Convert MP3/WAV/etc to OGG for WoW custom crit sounds.

Usage:
  python3 convert.py mysound.mp3
  python3 convert.py mysound.mp3 --trim 0.5    (trim to 0.5 seconds)
  python3 convert.py mysound.mp3 --trim 1.0    (trim to 1.0 seconds)

Requires ffmpeg. Install:
  Mac:     brew install ffmpeg
  Ubuntu:  sudo apt install ffmpeg
  Windows: download from ffmpeg.org and add to PATH

Output: same filename with .ogg extension, in this folder.
Then in WoW: /cp addsound mysound.ogg
"""

import subprocess
import sys
import os


def convert(input_file, trim_seconds=None):
    if not os.path.exists(input_file):
        print(f"Error: '{input_file}' not found")
        return

    base = os.path.splitext(os.path.basename(input_file))[0]
    output_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), base + ".ogg")

    cmd = ["ffmpeg", "-i", input_file, "-y"]

    if trim_seconds:
        cmd.extend(["-t", str(trim_seconds)])

    # OGG Vorbis, decent quality, mono (smaller file)
    cmd.extend(["-c:a", "libvorbis", "-q:a", "4", "-ac", "1", output_file])

    print(f"Converting: {input_file} -> {output_file}")
    if trim_seconds:
        print(f"Trimming to: {trim_seconds}s")

    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        size = os.path.getsize(output_file) / 1024
        print(f"Done! ({size:.1f} KB)")
        print(f"In WoW: /cp addsound {base}.ogg")
    except FileNotFoundError:
        print("Error: ffmpeg not found. Install it:")
        print("  Mac:     brew install ffmpeg")
        print("  Ubuntu:  sudo apt install ffmpeg")
        print("  Windows: download from ffmpeg.org")
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    input_file = sys.argv[1]
    trim = None

    if "--trim" in sys.argv:
        idx = sys.argv.index("--trim")
        if idx + 1 < len(sys.argv):
            trim = float(sys.argv[idx + 1])

    convert(input_file, trim)
