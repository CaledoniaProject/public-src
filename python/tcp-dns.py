#!/usr/local/homebrew/bin/python

import sys
import os
import re
import json
import itertools
import dns.resolver

data = dns.resolver.query('baidu.com', 'A', tcp = True)
for i in data.response.answer:
    print i

