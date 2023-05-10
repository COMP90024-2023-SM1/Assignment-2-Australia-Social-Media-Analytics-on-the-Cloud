from mastodon import Mastodon, StreamListener
from mastodon_preprocess_utils import *
import json

# Create an instance with user credentials for mastodon.world server
mastodon = Mastodon(
    access_token = 'D5u3t_naCNonkImCD19nuM-CW5O2yX8cdtwmuejr-ss',
    api_base_url = 'https://mastodon.social'
)

# Define a listener
class MyStreamListener(StreamListener):
    def on_update(self, status):
        # status = extract_toot_info(status)
        # print(json.dumps(status, indent=2, ensure_ascii=False))
        print(status)

# Start streaming
mastodon.stream_public(MyStreamListener())
