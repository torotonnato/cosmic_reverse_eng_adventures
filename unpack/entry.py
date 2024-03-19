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
