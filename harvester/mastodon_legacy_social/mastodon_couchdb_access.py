import couchdb
import json
import requests
from datetime import datetime, timedelta, timezone
import time
from mastodon_preprocess_utils import *
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

NODE = get_ip_address('eth0') # Please manually set to specific Couchdb address when running on local machine
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

    # retrieves a predetermined number of toots within a certain date range
    # set limit to 1,500,000 toots
    def mastodon_processor(self, start_date, end_date, limit=40, total_limit=1500000):        
        # date range for mastodon data extraction
        url = "https://mastodon.social/api/v1/timelines/public"
        headers = {
            "Authorization": "Bearer D5u3t_naCNonkImCD19nuM-CW5O2yX8cdtwmuejr-ss"
        }

        fetched_count = 0
        # docs_to_insert = []
        max_id = None
        
        while total_limit is None or fetched_count < total_limit:
            # total limit = number of toots to fetch
            # print(fetched_count) # Debugging: Print total statuses fetched after each request
            params = {"max_id": max_id, "limit": limit} if max_id else {"limit": limit}
            response = requests.get(url, headers = headers, params = params)
            time.sleep(1.5)

            if response.status_code != 200:
                # if rate limit is reached, wait until limit resets
                if response.status_code == 429:
                    reset_time_str = response.headers.get("X-RateLimit-Reset")
                    reset_time = datetime.strptime(reset_time_str, "%Y-%m-%dT%H:%M:%S.%fZ").replace(tzinfo=timezone.utc)
                    current_time = datetime.now(timezone.utc)
                    remaining_time = reset_time - current_time

                    print(f"Rate limit exceeded. Waiting for {remaining_time} seconds...")
                    time.sleep(remaining_time.total_seconds() + 1)
                    continue
                else:
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
                    self.save_record(status)
                    # docs_to_insert.append(status)
                    # fetched_count += 1  # Increment the toot counter
                elif created_at < start_date:
                    break

            max_id = statuses[-1]["id"]

            # self.save_record(docs_to_insert)
            # docs_to_insert = []

    