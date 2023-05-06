import requests
import json
from datetime import datetime
import time
from transformers import pipeline
from bs4 import BeautifulSoup

MASTODON_BASE_URL = "https://mastodon.social"
ACCESS_TOKEN = "D5u3t_naCNonkImCD19nuM-CW5O2yX8cdtwmuejr-ss"

model_path = "cardiffnlp/twitter-xlm-roberta-base-sentiment"
sentiment_task = pipeline("sentiment-analysis", model=model_path, tokenizer=model_path)

def extract_toot_info(one_toot):
    """
    Extract necessary information of a toot and returns in
    JSON format

    Arguments:
    one_toot --- one toot JSON object
    """

    # religion - catholic & christian
    # simplified chinese, arabic, vietnamese, punjabi, greek, italian, filipino, hindi, spanish, japanese, korean
    keyword_religion = ['god', 'jesus', 'holy spirit', 'bible', 'prayer', 'pray', 'faith', 'worship', 'church', 'mass',
                        'sacrament', 'eucharist', 'communion', 'baptism', 'baptise', 'baptize', 'confession', 'amen',
                        'bless', 'hallelujah', 'catholic', 'christian', 'christianity', 'salvation', 'heaven', 'religion',
                        'religious', '上帝', '保佑', '耶稣', '天主', '基督', 'الله', 'يُبارِك', 
                        'يسوع', 'كاثوليكي', 'مسيحي', 'chúa', 'ban phước', 'giêsu', 'công giáo', 'kitô giáo', 'ਰੱਬ', 'ਆਸ਼ੀਰਵਾਦ ਦੇਣਾ', 'ਜੀਸਸ', 'ਕੈਥੋਲਿਕ',
                        'ਈਸਾਈ', 'Θεός', 'ευλογώ', 'Ιησούς', 'καθολικός', 'Χριστιανός', 'dio', 'benedire', 'gesù', 'cattolico', 'cristiano',
                        'diyos', 'pagpalain', 'hesus', 'katoliko', 'kristiyano', 'भगवान', 'आशीर्वाद', 'यीशु', 'कैथोलिक', 'ईसाई', 'dios', 'bendecir',
                        'jesús', 'católico', 'cristiano', '神', 'イエス', 'カトリック', 'キリスト', '하나님', '축복하다', '예수', '가톨릭', '기독교인']


    # mental health - depression
    # simplified chinese, arabic, vietnamese, punjabi, greek, italian, filipino, hindi, spanish, japanese, korean
    keyword_depression = ['sad', 'lonely', 'isolated', 'hopeless', 'helpless', 'tired', 'exhausted', 'miserable', 'anxious', 'stressed', 'overwhelmed',
                            'worthless', 'guilty', 'suicidal', 'suicide', 'numb', 'desperate', 'broken', 'lost', '焦虑', '抑郁', 
                            '想死', '自杀', '焦躁', 'القلق', 'الاكتئاب', 'مكتئب', 'انتحار', 'أريد الموت', 'اضطراب نفسي', 'محبط', 'lo âu', 'trầm cảm', 
                            'chán nản', 'tự tử', 'muốn chết', 'rối loạn tâm thần', 'nản lòng', 'ਚਿੰਤਾ', 'ਡਿਪ੍ਰੈਸ਼ਨ', 'ਉਦਾਸ', 'ਆਤਮਘਾਤੀ', 'ਮਰਨਾ ਚਾਹੁੰਦੇ', 'ਮਾਨਸਿਕ ਬਿਮਾਰੀ', 
                            'ਮਾਯੂਸ', 'αγχος', 'κατάθλιψη', 'καταθλιπτικός', 'αυτοκτονία', 'αυτοκτονικός', 'θέλω να πεθάνω', 'ψυχική διαταραχή',
                            'απογοητευμένος', 'ansia', 'depressione', 'depresso', 'suicidio', 'suicida', 'voglio morire', 'disturbo mentale', 'frustrato'
                            'pagkabalisa', 'depresyon', 'deprimido', 'pagpapakamatay', 'nais mamatay', 'gusto mamatay', 'sakit sa isip', 'चिंता', 'अवसाद',
                            'उदास', 'आत्महत्या', 'आत्मघाती', 'मरना चाहते हैं', 'मानसिक विकार', 'परेशान', 'ansiedad', 'depresión', 'deprimido', 'deprimida', 'quiero morir', 
                            'trastorno mental', 'frustrado', 'frustrada', '抑うつ', '鬱症状', '自殺', '死にたい', '精神障害', '挫折した', '불안', '우울증', '우울한', '자살', 
                            '죽고 싶다', '정신 장애', '좌절감']
    
    # Parse date format into YYYY-MM-DD HH:MM:SS
    DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.%fZ'

    # toots do not contain location information
    toot_id = one_toot['id']
    toot_time = datetime.strptime(one_toot['created_at'], DATE_FORMAT)
    toot_time = toot_time.strftime('%Y-%m-%d %H:%M:%S')
    content_string = one_toot['content']
    soup = BeautifulSoup(content_string, 'html.parser')
    toot_content = soup.get_text()
    tags_list = one_toot['tags']
    toot_tags = [tag["name"] for tag in tags_list]
    toot_language = one_toot['language']
    toot_sentiment = sentiment_task(toot_content)

    # classify toots into categories
    toot_category = []
    if any(kw in toot_content for kw in keyword_religion):
        toot_category.append('religion')
    if any(kw in toot_content for kw in keyword_depression):
        toot_category.append('depression')
    

    simplified_toot = {
        'toot_id': toot_id,
        'toot_time': toot_time,
        'toot_language': toot_language,
        'toot_content': toot_content,
        'toot_tags': toot_tags,
        'toot_category': toot_category,
        'toot_sentiment': toot_sentiment
    }

    return simplified_toot

def get_legacy_data(start_date, end_date, limit=40, total_limit=40):
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
                # preprocess toots and then save
                status = extract_toot_info(status)
                filtered_statuses.append(status)
                fetched_count += 1  # Increment the counter
            elif created_at < start_date:
                break

        max_id = statuses[-1]["id"]

    return filtered_statuses

# Main function
def main():
    # date range for fetching data
    start_date = datetime(2022, 2, 1)
    end_date = datetime(2023, 5, 7)

    # Get legacy data
    legacy_data = get_legacy_data(start_date, end_date)
    for status in legacy_data:
        print(json.dumps(status, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()