import os
from entry import Entry

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
