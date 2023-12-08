#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import re
import json
import requests
import itertools

count = {"a": 4, "b": 3, "c": 1}

for key, value in sorted(count.iteritems(), key=lambda (k,v): (v,k)):
    print "%s: %s" % (key, value)


