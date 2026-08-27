#!/usr/bin/env python3
"""Extract PNG frames + hotspots from ANI cursor files (Brushbuddy pack).

Used at Nix build time. Reads .ani files from ani/ dir, writes frames/*.png
+ manifest.json (frame list with hotspots per cursor).
"""
import os
import struct
import json

SRC = "ani"
OUT = "frames"


def walk_chunks(data, start, end):
    """Yield (fourcc, data_start, data_end) for RIFF sub-chunks within bounds."""
    i = start
    while i + 8 <= end:
        fcc = data[i : i + 4]
        size = struct.unpack("<I", data[i + 4 : i + 8])[0]
        dstart = i + 8
        dend = dstart + size
        if dend > end:
            break
        yield fcc, dstart, dend
        i = dend + (size & 1)


def parse_icondir(buf):
    count = struct.unpack("<H", buf[4:6])[0]
    out = []
    for e in range(count):
        base = 6 + e * 16
        w = buf[base] or 256
        h = buf[base + 1] or 256
        xhot = struct.unpack("<H", buf[base + 4 : base + 6])[0]
        yhot = struct.unpack("<H", buf[base + 6 : base + 8])[0]
        bsize = struct.unpack("<I", buf[base + 8 : base + 12])[0]
        boff = struct.unpack("<I", buf[base + 12 : base + 16])[0]
        png = buf[boff : boff + bsize]
        if png.startswith(b"\x89PNG"):
            out.append((w, h, xhot, yhot, png))
    return out


def parse_ani(path):
    with open(path, "rb") as fh:
        data = fh.read()
    if data[:4] != b"RIFF" or data[8:12] != b"ACON":
        raise ValueError(f"{path}: not an ANI")
    riff_size = struct.unpack("<I", data[4:8])[0]
    # RIFF payload: after 'RIFF' + size + 'ACON', chunks run until riff end
    body_end = 12 + riff_size - 4
    frames = []
    for fcc, dstart, dend in walk_chunks(data, 12, body_end):
        if fcc == b"LIST" and data[dstart : dstart + 4] == b"fram":
            for sub, sds, sde in walk_chunks(data, dstart + 4, dend):
                if sub == b"icon":
                    frames.extend(parse_icondir(data[sds:sde]))
    return frames


def main():
    os.makedirs(OUT, exist_ok=True)
    manifest = {}
    for fname in sorted(os.listdir(SRC)):
        if not fname.endswith(".ani"):
            continue
        base = os.path.splitext(fname)[0]
        safe = base.replace(" ", "_")
        frames = parse_ani(os.path.join(SRC, fname))
        entries = []
        for idx, (w, h, xhot, yhot, png) in enumerate(frames):
            png_path = os.path.join(OUT, f"{safe}_f{idx:02d}.png")
            with open(png_path, "wb") as fh:
                fh.write(png)
            entries.append({"frame": idx, "w": w, "h": h, "xhot": xhot, "yhot": yhot})
        manifest[base] = entries
        print(f"{base}: {len(frames)} frames")
    with open(os.path.join(OUT, "manifest.json"), "w") as fh:
        json.dump(manifest, fh, indent=2)


if __name__ == "__main__":
    main()
