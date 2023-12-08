#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import re
import json
import requests
import itertools

def my_product(dicts):
    return (dict(itertools.izip(dicts, x)) for x in itertools.product(*dicts.itervalues()))

pattern = '{a} is not {b}'
cols    = { 
   'a': [1, 2], 
   'b': [3, 4]
}

for prod in my_product(cols):
    print pattern.format(**prod)


