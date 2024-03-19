import struct

class Entry:
    record_size = 20

    def __init__(self, fname, ofs, size):
        self.fname = fname
        self.ofs   = ofs
        self.size  = size

    @staticmethod
    def from_bytes(data):
        return Entry(
            data[:11].strip(b'\x00').lower().decode(),
            struct.unpack('<i', data[12:16])[0],
            struct.unpack('<i', data[16:20])[0]
        )

    def print(self):
        print(f'\tfname: {self.fname}')
        print(f'\t  ofs: {hex(self.ofs)} ({self.ofs})')
        print(f'\t size: {self.size}')

    def as_csv(self):
        return f'{self.fname};{hex(self.ofs)};{self.size};'

    def extract(self, path, data):
        with open(f'{path}/{self.fname}', 'wb') as f:
            f.write(data[self.ofs:self.ofs + self.size])
