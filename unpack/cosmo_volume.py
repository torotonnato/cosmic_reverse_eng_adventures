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
    def from_bytes(data):
        return Entry(
            data[:12].strip(b'\x00').lower().decode(),
            struct.unpack('<i', data[12:16])[0],
            struct.unpack('<i', data[16:20])[0],
            data
        )

    def print(self):
        print(f'\tfname: {self.fname}')
        print(f'\t  ofs: {hex(self.ofs)} ({self.ofs})')
        print(f'\t size: {self.size}')

    def as_csv(self):
        return f'{self.fname};{hex(self.ofs)};{self.size};'

    def unpack(self, path):
        with open(f'{path}/{self.fname}', 'wb') as f:
            f.write(self.data[self.ofs:self.ofs + self.size])

class Volume:
    def __init__(self, fname, data):
        self.fname = os.path.basename(fname)
        self.data = data
        self.entries = []

    @staticmethod
    def open(fname):
        with open(fname, 'rb') as f:
            vol = Volume(fname, f.read())
            for idx in range(0, len(vol.data), Entry.record_size):
                entry = Entry.from_bytes(vol.data[idx:idx + Entry.record_size])
                vol.entries.append(entry)
                if entry.ofs + entry.size >= len(vol.data):
                    break
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
