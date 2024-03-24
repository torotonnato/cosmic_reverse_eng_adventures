import sys

def gen(line):
    return [hex(v) for v in line]

banner = input('Insert a banner: ')
if len(banner) > 80:
    sys.exit(1)

just_banner = banner.ljust(40 + len(banner) // 2).rjust(80)
attr = '`' * 80

res = ''.join([''.join(z) for z in zip(just_banner, attr)]).encode()

print('banner_str:')
for ofs in range(0, 160, 10):
    line = res[ofs:ofs + 10]
    print(f'\tdb {", ".join(gen(line))}')
