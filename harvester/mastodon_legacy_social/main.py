from datetime import datetime
from mastodon_preprocess_utils import *
from mastodon_couchdb_access import MastodonData

def main():
    store_mastodon = MastodonData(db_name = 'legacy_mastodon_social_data')

    start_date = datetime(2023, 5, 1)
    end_date = datetime(2023, 5, 30)

    store_mastodon.mastodon_processor(start_date, end_date)

if __name__ == "__main__":
    main()


