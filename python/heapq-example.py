#!/usr/bin/env python

import sys
import os
import re
import json
import requests
import itertools
import heapq

h   = []
cap = 5

def add(item):
    if len(h) < cap:
        heapq.heappush(h, item)
    else:
        heapq.heappushpop(h, item)

add((5, "OK"))
add((3, "Hello"))
add((99, "World"))
add((8, "Aaron"))
add((99, "Mack"))
add((11, "Julia"))

for i in range(len(h)):
    print heapq.heappop(h)

