#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Github 创建 ISSUE API

import json
import requests

try:
    data = {
        'title':  '',
        'body':   '支持 markdown',
        'labels': ['feature']
    }
    resp = requests.post('https://api.github.com/repos/USERNAME/REPO_NAME/issues', json.dumps(data), auth = ('XXX', 'XXX'))
    print resp.text
except Exception as e:
    raise
