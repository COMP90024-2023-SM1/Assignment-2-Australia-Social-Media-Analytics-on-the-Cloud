import couchdb
import json

from tweet_preprocess_utils import *

MASTER_NODE = ''
ADMIN = 'admin'
PASSWORD = 'mysuperfancypassword'

class DataStore():

    def __init__(self, db_name, url=f'http://{ADMIN}:{PASSWORD}@{MASTER_NODE}:5984/'):
        try:
            self.server = couchdb.Server(url)
            self.db = self.server.create(db_name)
            # self._create_views()
        except couchdb.http.PreconditionFailed:
            self.db = self.server[db_name]

    def save_record(self, one_record):
        one_record = json.loads(one_record)
        self.db.save(one_record)

    # def create_view(self):
    #     pass

    def tweet_processor(self, tweet_path, block_start, block_end):

        with open(tweet_path, 'rb') as file:
            file.seek(block_start)
            while file.tell() != block_end:
                line = file.readline().splitlines()
                if line[-1] == ',': # Check if current line has trailing comma
                    line = line[:-1] # Remove trailing comma

                try:
                    tweet = json.loads(line)
                    if tweet['doc']['data']['geo'] != {}:
                        tweet = extract_tweet_info(tweet)
                        self.save_record(tweet)

                except Exception as e:
                    pass