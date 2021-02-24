#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import re
import json
import itertools

def work(filename):
    parts = []

    with open(filename, 'rb') as f:
        data  = f.read().split("\n")

        for line in data[4:]:
            if line.count('\\x') > 10:
                line = line.decode('string_escape')

            parts.append(line)

    with open(filename, 'wb') as f:
        f.write("\n".join(parts))

for x in sys.argv[1:]:
    work(x)
