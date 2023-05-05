import couchdb
import json
import requests
from datetime import datetime, timedelta
import time
from mastodon_preprocess_utils import *

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

    # retrieves a predetermined number of toots within a certain date range
    # set limit to 3,000,000 toots to match the amount of twitter data we have
    def mastodon_processor(self, start_date, end_date, limit=40, total_limit=3000000):        
        # date range for mastodon data extraction
        start_date = datetime(2022, 2, 1)
        end_date = datetime(2023, 5, 6)

        url = "https://mastodon.social/api/v1/timelines/public"
        headers = {
            "Authorization": "Bearer D5u3t_naCNonkImCD19nuM-CW5O2yX8cdtwmuejr-ss"
        }

        fetched_count = 0
        docs_to_insert = []
        max_id = None
        
        while total_limit is None or fetched_count < total_limit:
            # total limit = number of toots to fetch
            # print(fetched_count) # Debugging: Print total statuses fetched after each request
            params = {"max_id": max_id, "limit": limit} if max_id else {"limit": limit}
            response = requests.get(url, headers = headers, params = params)
            time.sleep(1)

            if response.status_code != 200:
                print(f"Error fetching data: {response.status_code}")
                break

            statuses = response.json()
            if not statuses:
                break

            for status in statuses:
                created_at = datetime.strptime(status["created_at"], "%Y-%m-%dT%H:%M:%S.%fZ")
                # print(f"Status created at: {created_at}")  # Debugging: Print created_at for each status
                # check if toot in date range
                if start_date <= created_at <= end_date:
                    # preprocess toot and append to list to save
                    status = extract_toot_info(status)
                    docs_to_insert.append(status)
                    fetched_count += 1  # Increment the toot counter
                elif created_at < start_date:
                    break

            max_id = statuses[-1]["id"]

            # Inserting toots by batch to speed up the process
            if len(docs_to_insert) == 1000:
                    self.save_record(docs_to_insert)
                    docs_to_insert = []

        # Insert the remaining toots
        if len(docs_to_insert) != 0:
            self.save_record(docs_to_insert)

    