from volume import Volume

if __name__ == '__main__':
    Volume.open('../game_data/cosmo1.vol').unpack('../game_data/unpacked')
    Volume.open('../game_data/cosmo1.stn').unpack('../game_data/unpacked')
