import itertools

def expand_ip_range(ipstr):
    parts = ipstr.split('.')
    param = []

    for part in parts:
        if '-' in part:
            tmp   = part.split('-')
            start = 0
            stop  = 255

            try:
                start = int(tmp[0])
                if start < 0 or start > 255:
                    start = 0
            except:
                pass

            try:
                stop = int(tmp[1])
                if stop < 0 or stop > 255:
                    stop = 255
            except:
                pass

            tmp = []
            for i in range(start, stop + 1):
                tmp.append(i)

            param.append(tmp)
            
        else:
            param.append([part])

    for row in itertools.product(*param):
        yield '.'.join(map(str, row))

for row in expand_ip_range('192.168.154-155.10-11'):
    print(row)

for row in expand_ip_range('192.168.250-.10-11'):
    print(row)

for row in expand_ip_range('192.168.-2.10-11'):
    print(row)

