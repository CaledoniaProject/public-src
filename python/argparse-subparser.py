#!/usr/bin/env python

import sys
import os
import re
import json
import requests
import itertools
import argparse

main_parser   = argparse.ArgumentParser()
subparsers    = main_parser.add_subparsers()

dns_subparser = subparsers.add_parser('dns')
dns_subparser.add_argument('--domain', 
        default = None, required = True,
        action = 'store_true', dest = "domain", help='Target root domain name')

server_subparser = subparsers.add_parser('server')
server_subparser.add_argument('--port', 
        default = 31337, required = True,
        action = 'store_true', dest = "port", help='Listen port')

args = main_parser.parse_args()
print args

