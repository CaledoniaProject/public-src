#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import mimetools

print(mimetools.pipeto(None, 'ls -lh | cat'))
