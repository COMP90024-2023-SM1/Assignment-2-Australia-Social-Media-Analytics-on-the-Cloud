import couchdb
import json

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

        self.db.update(record_batch)

    def mastodon_processor(self, mastodon_data):
        pass