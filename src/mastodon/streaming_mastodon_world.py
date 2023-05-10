from mastodon import Mastodon, StreamListener
from mastodon_preprocess_utils import *
import json

# Create an instance with user credentials for mastodon.world server
mastodon = Mastodon(
    access_token = 'ejM7XC0yUcYazPJvNYt4EjBroHoW0GQ3V_f_ZTjBvsA',
    api_base_url = 'https://mastodon.world'
)

# Define a listener
class MyStreamListener(StreamListener):
    def on_update(self, status):
        # status = extract_toot_info(status)
        # print(json.dumps(status, indent=2, ensure_ascii=False))
        print(status)

# Start streaming
mastodon.stream_public(MyStreamListener())
