#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import re
import json
import argparse
import subprocess

from os.path import expanduser

class NeteaseTools:
    def __init__(self, **kwargs):
        self.default_path = expanduser("~/Library/Containers/com.netease.163music/Data/Documents/storage/Logs/music.163.log")

    def do_file(self, log_file):
        with open(log_file, 'r') as f:
            for line in f:
                data = self.parse_line(line)
                if data:
                    self.convert2curl(data)

    def do_tail(self):
        print 'Listening for new logs'

        proc = subprocess.Popen(['tail', '-f', self.default_path], stdout = subprocess.PIPE)
        while True:
            line = proc.stdout.readline()
            if line != '':
                data = self.parse_line(line)
                if data:
                    self.convert2curl(data)

    def parse_line(self, line):
        data = None
        if '[info]player._$load, ,' in line:
            line = re.sub(r'^[^{]+', '', line)
            data = json.loads(line)

        return data

    def convert2curl(self, data):
        print "\n", '#', data['artistName'].encode('utf8'), data['songName'].encode('utf8')
        print 'curl "{}" -o "{} - {}.mp3"'.format(
              data['musicurl'], 
              data['artistName'].replace('/', ' ').encode('utf8'), 
              data['songName'].replace('/', ' ').encode('utf8')
        ), "\n"

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description = '网易云音乐下载工具 For Mac')
    parser.add_argument('files', metavar = 'files', nargs = '*',
                        help = 'Additional log files to parse')
    parser.add_argument('-l', dest='listen', action='store_true', required = False,
                        help = 'Monitor log for changes')
    parser.add_argument('-o', dest='output', required = False,
                        help = 'Save shell script to this file')

    try:
        args    = parser.parse_args()
        netease = NeteaseTools()

        if args.listen:
            netease.do_tail()
        elif len(args.files):
            for file in args.files:
                netease.do_file(file)
        else:
            netease.do_file(netease.default_path)
    except KeyboardInterrupt:
        print "\nUser interrupt\n"
        os._exit(0)
    except Exception as e:
        raise




