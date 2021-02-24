#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os

import pydoc
print(pydoc.pipepager(None, 'ls -lh'))
