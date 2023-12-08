#!/usr/bin/env python

import sys
import os
import re
import json
import requests
import itertools
import logging
import threading

from Queue import Queue

max_threads = 10
threads     = []
q           = Queue()

def worker(tid, q):
    while True:
        data = q.get()
        if data is None:
            break

        logging.warning(data)

for i in range(0, max_threads):
    t = threading.Thread(
        target = worker,
        args   = (i + 1, q, ))
    t.daemon = True
    t.start()

    threads.append(t)

for t in threads:
    q.put("Hello")
    q.put(None)

for t in threads:
    t.join()
