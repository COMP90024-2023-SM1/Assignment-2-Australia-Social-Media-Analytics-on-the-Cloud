from datetime import datetime
from mastodon_preprocess_utils_streaming import *
from mastodon_couchdb_access_streaming import MastodonData
from mastodon import Mastodon, StreamListener

def main():
    store_mastodon = MastodonData(db_name = 'streaming_mastodon_world_data')

    # Create an instance with user credentials for mastodon.world server
    mastodon = Mastodon(
    access_token = 'tQAfFvGG7MR2_gVWTA3lDT49kDJNZSJkV08iipRYdAI',
    api_base_url = 'https://mastodon.world'
    )

    # Define a listener
    class MyStreamListener(StreamListener):
        def on_update(self, status):
            status = extract_toot_info(status)
            store_mastodon.save_record(status)

    # Start streaming
    mastodon.stream_public(MyStreamListener())

if __name__ == "__main__":
    main()




