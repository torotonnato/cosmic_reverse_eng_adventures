import os
from entry import Entry

class Volume:
    def __init__(self, fname):
        self.entries = []
        self.fname = os.path.basename(fname)
        self.load(fname)

    def load(self, fname):
        with open(fname, 'rb') as f:
            self.data = f.read()
            for idx in range(0, len(self.data), Entry.record_size):
                entry = Entry.from_bytes(self.data[idx:idx + Entry.record_size])
                self.entries.append(entry)
                if entry.ofs + entry.size >= len(self.data):
                    break

    def print(self):
        for entry in self.entries:
            entry.print()
            print()

    def print_as_csv(self):
        for entry in self.entries:
            print(entry.as_csv())

    def extract(self, path_prefix):
        path = os.path.join(path_prefix, self.fname)
        os.makedirs(path)
        for entry in self.entries:
            entry.extract(path, self.data)
