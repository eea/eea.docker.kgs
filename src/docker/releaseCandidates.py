#!/plone/instance/bin/zopepy
# -*- coding: ascii -*-

import sys
import mmap
from os import listdir

def main(argv):
    print '*** Release candidates list ***'
    print '==============================='

    packages = listdir('./src')
    packages.sort()
    found = False
    for cand_d in packages:

        try:
            cand_f = open('./src/%s/docs/HISTORY.txt' % cand_d)
        except IOError:
            #print 'No HISTORY.txt found: %s' % cand_d
            continue
        cand_s = mmap.mmap(cand_f.fileno(), 0, access=mmap.ACCESS_READ)
        cand_n = cand_s.rfind('unreleased')

        for k in range(5):
            cand_s.readline()
        if cand_s.readline() != '\n':
            found = True
            print 'Release candidate: %s' % cand_d

    print '==============================='
    if found:
        sys.exit(1)

if __name__ == "__main__":
    main(sys.argv[1:])
