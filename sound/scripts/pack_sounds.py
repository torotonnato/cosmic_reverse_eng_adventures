from os import path
import struct
from cosmo_sound_archive import SoundArchive

def name_pp():
    unnamed_counter = 1
    def helper(name):
        nonlocal unnamed_counter
        name = name[:10].lower()
        if 'unnamed' in name:
            name = f'noname{str(unnamed_counter).rjust(2, "0")}'
            unnamed_counter += 1
        return name.ljust(5 + (len(name) + 1) // 2).rjust(10)
    return helper
    
def pack(entries):
    meta = b''
    data = b''
    pp = name_pp()
    ofs = 2 + len(entries) * 12
    for entry in entries:
        name = pp(entry.name).encode()
        meta += struct.pack('<10sH', name, ofs)
        ofs += len(entry.data)
        data += entry.data
    return struct.pack('<H', len(entries)) + meta + data

BASE_PATH = '../../game_data/unpacked/cosmo1.stn'

sound_archives = ['sounds.mni', 'sounds2.mni', 'sounds3.mni']
paths = [path.join(BASE_PATH, fname) for fname in sound_archives]

entries = []
for fname in paths:
    entries.extend(SoundArchive.open(fname).entries)

with open('../res/sounds.bin', 'wb') as fout:
    fout.write(pack(entries))
