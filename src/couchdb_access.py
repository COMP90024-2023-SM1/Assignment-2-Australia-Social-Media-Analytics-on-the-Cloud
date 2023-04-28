import couchdb
import json

from tweet_preprocess_utils import *

MASTER_NODE = 'localhost'
ADMIN = 'admin'
PASSWORD = 'mysuperfancypassword'

class DataStore():

    def __init__(self, db_name, url=f'http://{ADMIN}:{PASSWORD}@127.0.0.1:5984/'):
        self.server = couchdb.Server(url)
        if db_name not in self.server:
            self.db = self.server.create(db_name)
        else:
            self.db = self.server[db_name]

    def save_record(self, one_record):
        one_record = json.dumps(one_record)
        one_record = json.loads(one_record)
        self.db.save(one_record)

    # def create_view(self):
    #     pass

    def tweet_processor(self, tweet_path, block_start, block_end):

        with open(tweet_path, 'rb') as file:
            file.seek(block_start)
            while file.tell() != block_end:
                line = file.readline().splitlines()[0].decode('utf-8')
                if line[-1] == ',': # Check if current line has trailing comma
                    line = line[:-1] # Remove trailing comma

                try:
                    tweet = json.loads(line)
                    if tweet['doc']['data']['geo'] != {}:
                        tweet = extract_tweet_info(tweet)
                        self.save_record(tweet)

                except (KeyError, ValueError) as e:
                    pass