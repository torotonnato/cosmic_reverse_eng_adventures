import struct

class Error(Exception):
    pass

class NotRecognized(Error):
    pass

class UnexpectedEof(Error):
    pass

class Entry:

    LEN = 16
    END_MARKER = b'\xFF\xFF'

    def __init__(self, name, ofs, attr, data):
        self.name, self.ofs, self.attr, self.data = name, ofs, attr, data

    @staticmethod
    def from_bytes(entry_data, archive_data):
        ofs, attr, name = struct.unpack('<HH12s', entry_data)
        try:
            end_marker_ofs = archive_data[ofs:].index(Entry.END_MARKER)
            return Entry(
                name.decode().strip('\x00'),
                ofs,
                attr,
                archive_data[ofs:ofs + end_marker_ofs + 2])
        except ValueError:
            raise NotRecognized from Exception

class EntriesIterator:

    def __init__(self, archive_data):
        self._index = 0
        if len(archive_data) < SoundArchive.HEADER_LEN:
            raise UnexpectedEof
        header = archive_data[:SoundArchive.HEADER_LEN]
        self._entries_no = SoundArchive.get_entries_no(header)
        self._archive_data = archive_data

    def __iter__(self):
        return self

    def _get_ofs(self):
        return Entry.LEN * self._index + SoundArchive.HEADER_LEN

    def __next__(self):
        if self._index < self._entries_no:
            ofs = self._get_ofs()
            self._index += 1
            return Entry.from_bytes(
                self._archive_data[ofs:ofs + Entry.LEN],
                self._archive_data)
        else:
            raise StopIteration

class SoundArchive:

    MAGIC_BYTES = b'SND\x00'
    HEADER_LEN  = 16

    def __init__(self, fname, entries):
        self.fname, self.entries = fname, entries

    @staticmethod
    def get_entries_no(header):
        if len(header) < 16:
            raise UnexpectedEof
        return struct.unpack('<H', header[6:8])[0]

    @staticmethod
    def open(fname):
        with open(fname, "rb") as f:
            data = f.read()
            if data[:4] != SoundArchive.MAGIC_BYTES:
                raise NotRecognized
            return SoundArchive(fname, EntriesIterator(data))
