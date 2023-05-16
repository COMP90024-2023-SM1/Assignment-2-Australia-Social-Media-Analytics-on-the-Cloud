import couchdb
import json
import requests
import time
from datetime import datetime, timedelta, timezone
from mastodon_preprocess_utils_streaming import *
import socket
import fcntl
import struct

def get_ip_address(interface):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        ip_address = socket.inet_ntoa(fcntl.ioctl(
            sock.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', interface[:15].encode())
        )[20:24])
        return ip_address
    except IOError:
        assert False, "Unable to retrieve IP Address for " + interface

NODE = get_ip_address('eth0')
ADMIN = 'admin'
PASSWORD = 'admin'

class MastodonData():

    def __init__(self, db_name, url=f'http://{ADMIN}:{PASSWORD}@{NODE}:5984/'):
        try:
            self.server = couchdb.Server(url=url)
            self.db = self.server.create(db_name)
            # self._create_views()
        except couchdb.http.PreconditionFailed:
            self.db = self.server[db_name]

    def save_record(self, record_batch):
        '''
        Insert mastodon data to couchDB in batches
        '''

        self.db.save(record_batch)
