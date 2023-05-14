import couchdb
import json
import requests
import time
from datetime import datetime, timedelta, timezone
from mastodon_preprocess_utils_streaming import *

MASTER_NODE = '172.26.134.229'
ADMIN = 'admin'
PASSWORD = 'admin'

class MastodonData():

    def __init__(self, db_name, url=f'http://{ADMIN}:{PASSWORD}@{MASTER_NODE}:5984/'):
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
