import os
import struct

class Entry:

    record_size = 20

    def __init__(self, fname, ofs, size, data):
        self.fname = fname
        self.ofs   = ofs
        self.size  = size
        self.data  = data

    @staticmethod
    def from_bytes(volume_data, idx):
        metadata = volume_data[idx * Entry.record_size:(idx + 1) * Entry.record_size]
        ofs, size = struct.unpack('<II', metadata[12:20])
        return None if ofs + size >= len(volume_data) else Entry(
            metadata[:12].strip(b'\x00').lower().decode(),
            ofs,
            size,
            volume_data[ofs:ofs + size]
        )

    def print(self):
        print(f'\tfname: {self.fname}')
        print(f'\t  ofs: {hex(self.ofs)} ({self.ofs})')
        print(f'\t size: {self.size}')

    def as_csv(self):
        return f'{self.fname};{hex(self.ofs)};{self.size};'

    def unpack(self, path):
        with open(f'{path}/{self.fname}', 'wb') as f:
            f.write(self.data)



class Volume:

    def __init__(self, fname, data):
        self.fname = os.path.basename(fname)
        self.data = data
        self.entries = []

    @staticmethod
    def open(fname):
        with open(fname, 'rb') as f:
            vol = Volume(fname, f.read())
            idx = 0
            while entry := Entry.from_bytes(vol.data, idx):
                vol.entries.append(entry)
                idx += 1
            return vol

    def print(self):
        for entry in self.entries:
            entry.print()
            print()

    def print_as_csv(self):
        for entry in self.entries:
            print(entry.as_csv())

    def unpack(self, path_prefix):
        path = os.path.join(path_prefix, self.fname)
        try:
            os.makedirs(path)
        except OSError:
            pass
        for entry in self.entries:
            entry.unpack(path)
