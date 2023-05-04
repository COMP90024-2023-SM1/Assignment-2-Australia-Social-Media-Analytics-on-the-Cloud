import requests
import json
from datetime import datetime, timedelta
import time

MASTODON_BASE_URL = "https://mastodon.social"
ACCESS_TOKEN = "D5u3t_naCNonkImCD19nuM-CW5O2yX8cdtwmuejr-ss"

# retrieves a predetermined number of toots within a certain date range
def get_legacy_data(start_date, end_date, limit=40, total_limit=500):
    url = "https://mastodon.social/api/v1/timelines/public"
    headers = {
        "Authorization": "Bearer D5u3t_naCNonkImCD19nuM-CW5O2yX8cdtwmuejr-ss"
    }

    fetched_count = 0
    filtered_statuses = []
    max_id = None
    
    # total limit = number of toots to fetch
    while total_limit is None or fetched_count < total_limit:
        print(fetched_count)
        params = {"max_id": max_id, "limit": limit} if max_id else {"limit": limit}
        response = requests.get(url, headers=headers, params=params)
        time.sleep(0.5)

        if response.status_code != 200:
            print(f"Error fetching data: {response.status_code}")
            break

        statuses = response.json()
        if not statuses:
            break

        for status in statuses:
            created_at = datetime.strptime(status["created_at"], "%Y-%m-%dT%H:%M:%S.%fZ")
            print(f"Status created at: {created_at}")  # Debugging: Print created_at for each status
            if start_date <= created_at <= end_date:
                filtered_statuses.append(status)
                fetched_count += 1  # Increment the counter
            elif created_at < start_date:
                break

        max_id = statuses[-1]["id"]

    return filtered_statuses

# searched for toots containing one or more keywords (not in use)
def search_statuses(query, limit=40):
    url = "https://mastodon.social/api/v2/search"
    headers = {
        "Authorization": "Bearer D5u3t_naCNonkImCD19nuM-CW5O2yX8cdtwmuejr-ss"
    }

    params = {
        "q": query,
        "type": "statuses",
        "min_id": 107958478641707878,
        "max_id": None,
        "limit": limit,
    }

    response = requests.get(url, headers=headers, params=params)

    if response.status_code != 200:
        print(f"Error fetching data: {response.status_code}")
        return []

    search_results = response.json()
    return search_results["statuses"]

# Main function
def main():
    # date range for fetching data
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2023, 5, 3)
    
#     # search for statuses
#     search_query = "cat"  # Replace this with your desired search query
    
#     count = 0
#     while count < 250:
#         searched_statuses = search_statuses(search_query)
#         print(searched_statuses)
#         for status in searched_statuses:
#     #         print('yes')
#             created_at = datetime.strptime(status["created_at"], "%Y-%m-%dT%H:%M:%S.%fZ")
#             print(f"Status created at: {created_at}")  # Debugging: Print created_at for each status
#             print(json.dumps(status, indent=2))
#         count += 1

    # Get legacy data
    legacy_data = get_legacy_data(start_date, end_date)
    for status in legacy_data:
        print(json.dumps(status, indent=2))
        
#     # TESTING - Get legacy data and save locally
#     legacy_data = get_legacy_data(start_date, end_date)
#     json_list = []
#     for status in legacy_data:      
#         json_list.append(status)
        
#     with open("mastodon_data_sample.json", "w") as outfile: 
#         json.dump(json_list, outfile)

if __name__ == "__main__":
    main()
