from volume import Volume

if __name__ == '__main__':
    Volume('../game_data/cosmo1.vol').extract('../game_data/unpacked')
    Volume('../game_data/cosmo1.stn').extract('../game_data/unpacked')
