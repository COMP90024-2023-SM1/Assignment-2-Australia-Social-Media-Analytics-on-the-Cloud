import json
from datetime import datetime

DATE_FORMAT = "%Y-%m-%dT%H:%M:%S.%fZ"

def create_block(file_path: str, dataset_size, size_per_core: int):
    """
    Divide the dataset into block for each individual process

    Arguments:
    file_path --- path to the dataset
    dataset_size --- size of the dataset
    size_per_core --- allocated size for each core
    """
    with open(file_path, 'r', encoding='utf-8') as file:

        # Read pass the first line
        file.readline()
        block_end = file.tell()

        while True:
            block_start = block_end
            file.seek(file.tell() + size_per_core)
            # Read the next line to prevent reading partial tweet
            file.readline()
            block_end = file.tell()

            if block_end > dataset_size:
                block_end = dataset_size
            
            yield block_start, block_end
            if block_end == dataset_size:
                break

def extract_tweet_info(one_tweet):
    """
    Extract necessary information of a tweet and returns in
    JSON format

    Arguments:
    one_tweet --- one tweet JSON object
    """
    tweet_time = datetime.strptime(one_tweet['doc']['data']['created_at'],
                                   DATE_FORMAT)
    simplified_tweet = {
        'tweet_time': tweet_time,
        'language_code': one_tweet['doc']['data']['lang'],
        'tweet_metrics': one_tweet['doc']['data']['public_metrics'],
        'tweet_text': one_tweet['doc']['data']['text'],
        'location': one_tweet['doc']['includes']['places']
    }

    return simplified_tweet
