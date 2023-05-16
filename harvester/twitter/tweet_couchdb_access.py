import couchdb
import json

from tweet_preprocess_utils import *

MASTER_NODE = '172.26.134.229'
ADMIN = 'admin'
PASSWORD = 'admin'

class DataStore():

    def __init__(self, db_name, url=f'http://{ADMIN}:{PASSWORD}@{MASTER_NODE}:5984/'):
        try:
            self.server = couchdb.Server(url=url)
            self.db = self.server.create(db_name)
            # self._create_views()
        except couchdb.http.PreconditionFailed:
            self.db = self.server[db_name]

    def save_record(self, record_batch):
        self.db.update(record_batch)

    # def _create_views(self):
    #     count_map = 'function(doc) { emit(doc.id, 1); }'
    #     count_reduce = 'function(keys, values) { return sum(values); }'
    #     view = couchdb.design.ViewDefinition('twitter', 
    #                                          'count_tweets', 
    #                                          count_map, 
    #                                          reduce_fun=count_reduce)
    #     view.sync(self.db)

    # def count_tweets(self):
    #     for doc in self.db.view('twitter/count_tweets'):
    #         return doc.value

    def tweet_processor(self, tweet_path, block_start, block_end):

        docs_to_insert = []
        with open(tweet_path, 'rb') as file:
            file.seek(block_start)
            while file.tell() != block_end:
                line = file.readline().splitlines()[0].decode('utf-8')
                if line[-1] == ',': # Check if current line has trailing comma
                    line = line[:-1] # Remove trailing comma

                try:
                    tweet = json.loads(line)
                    if tweet['doc']['data']['geo'] != {} and tweet['doc']['data']['lang'] != 'und':
                        if is_within_australia([tweet['doc']['includes']['places'][0]['geo']['bbox'][1], tweet['doc']['includes']['places'][0]['geo']['bbox'][0]]):
                            tweet = extract_tweet_info(tweet)
                            tweet = json.dumps(tweet)
                            tweet = json.loads(tweet)
                            docs_to_insert.append(tweet)

                except (KeyError, ValueError, TypeError) as e:
                    pass

                # Inserting tweets by batch to speed up the process
                if len(docs_to_insert) == 1000:
                    self.save_record(docs_to_insert)
                    docs_to_insert = []

            # Insert the remaining tweets
            if len(docs_to_insert) != 0:
                self.save_record(docs_to_insert)