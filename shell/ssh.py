#!/opt/homebrew/bin/python3

from os import path, environ
from pprint import pprint

FILE_PATH = f'{environ["HOME"]}/.ssh/config'

if not path.exists(FILE_PATH):
    print('Not config file')

with open(FILE_PATH, 'r') as file:
    hosts = {}
    last_host = ''

    for line in file.readlines():
        line = line.strip()
        if len(line) == 0:
            continue

        if line[0] == '#':
            continue

        if line.startswith('Host '):
            last_host = line.split(' ')[1]
            hosts[last_host] = {}
            continue

        key, value = line.split(' ')
        hosts[last_host][key] = value


    for host in hosts:
        hostname = hosts[host].get('HostName')
        if hostname:
            print(hostname + ' ' * (20 - len(hostname)), host)
