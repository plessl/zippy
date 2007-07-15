#!/usr/bin/env python2.2

# print first n prime numbers
#

import sys
import math
from math import *

i = int(sys.argv[1])
cur = 0

print "The first %d prime numbers are:" % i

while i>0:
    cur += 1
    maxcheck = int(sqrt(cur))+1
    prime = 1
    for j in range(2,maxcheck):

        if (cur % j == 0):
            prime = 0
            #print "  %d is not a prime\n" % cur
            break

    if prime:
        print "%d," % cur
        i -= 1


