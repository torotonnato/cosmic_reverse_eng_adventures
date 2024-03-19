"""
A simple module that generates an EGA palette from an external CSS.

Output format:

palette:
	db <index>, <r>, <g>, <b> ;with index, r, g, b in [0, 64)
"""

import sys
import re

ega_mapping = [
	0x00, 0x01, 0x02, 0x03,
	0x04, 0x05, 0x14, 0x07,
	0x38, 0x39, 0x3A, 0x3B,
	0x3C, 0x3D, 0x3E, 0x3F
]

def pretty_hex(n):
    """
	Pretty prints a number (hex).
	"""
    return f"0x{hex(n)[2:].rjust(2, '0')}"

CSS_RE = re.compile(r'([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})')

def gen_palette_from(css, start_idx):
    """
    Generates a palette starting from start_idx color.
	"""
    idx = start_idx
    if idx < 0 or idx >= len(ega_mapping):
        print('Warning: starting index out of range. Returning []')
        return []
    asm_db = []
    while l := css.readline():
        if m := CSS_RE.search(l):
            if idx >= len(ega_mapping):
                print('; Warning: CSS file contains too many colors. Skipping some')
                break
            r, g, b = [pretty_hex(int(chan, 16) >> 2) for chan in m.groups()]
            asm_db.append(f'\tdb {pretty_hex(ega_mapping[idx])}, {r}, {g}, {b}')
            idx += 1
    return asm_db

if __name__ == '__main__':
    if len(sys.argv) not in [2, 3]:
        print('Usage: gen_pal.py <css_file> start_idx (default= 0)')
        sys.exit(1)

    start_idx = int(sys.argv[2]) if len(sys.argv) == 3 else 0
    with open(sys.argv[1], encoding="utf-8") as f:
        print('palette:')
        print('\n'.join(gen_palette_from(f, start_idx)))
