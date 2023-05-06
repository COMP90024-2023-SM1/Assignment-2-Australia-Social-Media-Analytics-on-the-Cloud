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
    # Parse date format into YYYY-MM-DD HH:MM:SS
    tweet_time = datetime.strptime(one_tweet['doc']['data']['created_at'],
                                   DATE_FORMAT)
    tweet_time = tweet_time.strftime('%Y-%m-%d %H:%M:%S')
    try:
        location = one_tweet['doc']['includes']['places']
    except (KeyError, TypeError):
        location = {}
    tokens = one_tweet['value']['tokens'].split('|')
    tokens = [word.lower() for word in tokens]
    simplified_tweet = {
        'id': one_tweet['id'],
        'tweet_time': tweet_time,
        'language_code': one_tweet['doc']['data']['lang'],
        'tweet_metrics': one_tweet['doc']['data']['public_metrics'],
        'tweet_tags': {'hashtags': one_tweet['value']['tags'].split('|'),
                       'tokens': tokens},
        'tweet_text': one_tweet['doc']['data']['text'].lower(),
        "sentiment": one_tweet['doc']['data']['sentiment']/5,
        'location': location
    }

    return simplified_tweet

def is_within_australia(coord):
    '''
    This function checks if a coordinate is within the Australia bounding box
    '''
    
    AU = ('Australia', (113.338953078, -43.6345972634, 153.569469029, -10.6681857235))
    lat, lon = coord
    if AU[1][0] <= lon <= AU[1][2] and AU[1][1] <= lat <= AU[1][3]:
        return True
    else:
        return False