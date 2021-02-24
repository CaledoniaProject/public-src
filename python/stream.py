#!/usr/bin/env python

import sys
import os
import re
import json
import requests
import itertools

r = requests.get('https://github.com/timeline.json', timeout=5, stream=True)

maxsize = 100000
content = ''

for chunk in r.iter_content(100):
    content += chunk
    print 'READ ', chunk
    if len(content) > maxsize:
        r.close()
        raise ValueError('Response too large')

print content
print json.loads(content)

