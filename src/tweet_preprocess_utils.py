import json
from datetime import datetime
import re
from collections import defaultdict

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

def extract_location_data(suburb):
    extracted_suburbs = {}
    for key, value in suburb.items():
        extracted_suburbs[key.lower()] = value["gcc"]
    return extracted_suburbs

def load_data():
    with open('sal.json', 'r') as file:
        location_data = json.load(file)
        processed_locations = extract_location_data(location_data)
    
    # filter for greater capital cities (if the second character is g for greater or a for act in gcc)
    g_location = {}
    for suburb, gcc in processed_locations.items():
        g_location[suburb] = gcc

    # create new dictionary to store cleaned suburb names
    suburbs_by_gcc = defaultdict(list)
    for suburb, gcc in g_location.items():
        # match suburb names that contain brackets
        complex_suburb_name = re.match(r"(\w|\s|-)+(\()", suburb)
        if complex_suburb_name:
            # remove brackets if there is no "-" in bracketed content e.g. "xxx (nsw)" to "xxx"
            new_suburb_name = complex_suburb_name.group(0)[:-2]
            # match suburbs with "-" within brackets in the format "xxx (central coast - nsw)"
            additional_town_name = re.match(r"(.*)(\()(.*)(\s-\s)(\w+)\)$", suburb)

            if additional_town_name:
                # isolate content after "-" as an additional suburb e.g. "central coast"
                cleaned_town_name = additional_town_name.group(3)
                suburbs_by_gcc[gcc].append(cleaned_town_name)

        else:
            new_suburb_name = suburb
        suburbs_by_gcc[gcc].append(new_suburb_name)
        
    return suburbs_by_gcc

suburbs_by_gcc = load_data()

def extract_tweet_info_gcc(one_tweet):
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
    tweet_gcc = ''
    try:
        location = one_tweet['doc']['includes']['places']
        try:
            location_name = location[0]["full_name"].lower().split(", ")
            if location_name[1] in ['new south wales', 'sydney']:
                tweet_gcc_g = '1gsyd'
                tweet_gcc_r = '1rnsw'
            elif location_name[1] in ['victoria', 'melbourne']:
                tweet_gcc_g = '2gmel'
                tweet_gcc_r = '2rvic'
            elif location_name[1] in ['queensland', 'brisbane']:
                tweet_gcc_g = '3gbri'
                tweet_gcc_r = '3rqld'
            elif location_name[1] in ['western australia', 'perth']:
                tweet_gcc_g = '5gper'
                tweet_gcc_r = '5rwau'
            elif location_name[1] in ['south australia', 'adelaide']:
                tweet_gcc_g = '4gade'
                tweet_gcc_r = '4rsau'
            elif location_name[1] in ['tasmania', 'hobart']:
                tweet_gcc_g = '6ghob'
                tweet_gcc_r = '6rtas'
            elif location_name[1] in ['northern territory', 'darwin']:
                tweet_gcc_g = '7gdar'
                tweet_gcc_r = '7rnte'
            elif location_name[1] in ['canberra', 'australian capital territory']:
                tweet_gcc_g = '8acte'
            else:
                tweet_gcc_g = '9oter'
            

            if location_name[0].split(" - ")[0] in suburbs_by_gcc[tweet_gcc_g]:
                tweet_gcc = tweet_gcc_g
            elif location_name[0].split(" - ")[0] in suburbs_by_gcc[tweet_gcc_r]:
                tweet_gcc = tweet_gcc_r
            else:
                tweet_gcc = '9oter'

        except (KeyError, IndexError, json.JSONDecodeError, UnboundLocalError):
            pass

    except (KeyError, TypeError):
        location = {}
        # tweet_gcc = {}
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
        "sentiment": one_tweet['doc']['data']['sentiment'] / 5,
        'location': location,
        'tweet_gcc': tweet_gcc.upper()
    }

    return simplified_tweet
