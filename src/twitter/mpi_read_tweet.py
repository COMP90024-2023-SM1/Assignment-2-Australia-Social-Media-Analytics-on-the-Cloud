import os

from mpi4py import MPI
from tweet_preprocess_utils import *
from tweet_couchdb_access import DataStore

tweet_path = '../data/twitter-huge.json'

COMM = MPI.COMM_WORLD
SIZE = COMM.Get_size()
RANK = COMM.Get_rank()

def main():
    
    data_store = DataStore(db_name='twitter_data')

    if RANK == 0:
        # Equally split dataset to each process
        dataset_size = os.path.getsize(tweet_path)

        size_per_core = dataset_size / SIZE

        # Divide tweet data into blocks for each core
        block_list = []
        for block_start, block_end in create_block(tweet_path, dataset_size, size_per_core):
            block_list.append({"block_start": block_start, "block_end": block_end})

    else:
        block_list = None

    # Distribute data blocks to different cores
    scattered_data = COMM.scatter(block_list, root = 0)
    print("Hello world from process", RANK + 1, "of",SIZE)
    print("RANK #" + str(RANK) + " responsible for block between byte " + str(
        scattered_data['block_start']) + " and byte " + str(scattered_data['block_end']))
    
    # Split data into blocks for preprocessing and storing into couchDB
    data_store.tweet_processor(tweet_path,
                               scattered_data['block_start'], 
                               scattered_data['block_end'])
    
