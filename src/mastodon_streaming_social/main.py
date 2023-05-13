from datetime import datetime
from mastodon_preprocess_utils_streaming import *
from mastodon_couchdb_access_streaming import MastodonData
from mastodon import Mastodon, StreamListener

def main():
    store_mastodon = MastodonData(db_name = 'streaming_mastodon_social_data')

    # Create an instance with user credentials for mastodon.social server
    mastodon = Mastodon(
    access_token = 'UshFiWoNf2IKxrpfjAkGsLphX-hheqatIph9E7mqq44',
    api_base_url = 'https://mastodon.social'
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




