#!/usr/bin/python3

import os
import sys
from typing import Dict

FILE_PATH = f'{os.environ["HOME"]}/.ssh/config'

if not os.path.exists(FILE_PATH):
    print('Not config file')

with open(FILE_PATH, 'r') as file:
    hosts: Dict[str, Dict[str, str]] = {}
    last_host = ''

    for line in file.readlines():
        line = line.strip()
        if len(line) == 0:
            continue

        if line[0] not in [' ', 'H']:
            continue

        if line.startswith('Host '):
            last_host = line.split(' ')[1]
            hosts[last_host] = {}
            continue

        key, value = line.split(' ')
        hosts[last_host][key] = value

    for host in hosts:
        hostname = hosts[host].get('HostName')
        if not hostname:
            continue

        if len(sys.argv) == 2 and not host.startswith(sys.argv[1]):
            continue

        print(hostname + ' ' * (20 - len(hostname)), host)
