import couchdb
import json

from tweet_preprocess_utils import *

MASTER_NODE = 'localhost'
ADMIN = 'admin'
PASSWORD = 'admin'

class DataStore():

    def __init__(self, db_name, url=f'http://{ADMIN}:{PASSWORD}@127.0.0.1:5984/'):
        self.server = couchdb.Server(url)
        if db_name not in self.server:
            self.db = self.server.create(db_name)
            self._create_views()
        else:
            self.db = self.server[db_name]

    def save_record(self, one_record):
        one_record = json.dumps(one_record)
        one_record = json.loads(one_record)
        self.db.save(one_record)

    def _create_views(self):
        count_map = 'function(doc) { emit(doc.id, 1); }'
        count_reduce = 'function(keys, values) { return sum(values); }'
        view = couchdb.design.ViewDefinition('twitter', 
                                             'count_tweets', 
                                             count_map, 
                                             reduce_fun=count_reduce)
        view.sync(self.db)

    def count_tweets(self):
        for doc in self.db.view('twitter/count_tweets'):
            return doc.value

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