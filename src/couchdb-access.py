import couchdb
import json

admin = 'admin'
password = 'mysuperfancypassword'

class DataStore():

    def __init__(self, db_name, url=f'http://{admin}:{password}@127.0.0.1:5984/'):
        try:
            self.server = couchdb.Server(url)
            self.db = self.server.create(db_name)
            self._create_views()
        except couchdb.http.PreconditionFailed:
            self.db = self.server[db_name]

    def save_record(self, one_record):
        one_record = json.loads(one_record)
        self.db.save(one_record)

    def create_view(self):
        pass