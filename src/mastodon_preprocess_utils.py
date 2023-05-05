import json
from datetime import datetime
import nltk
from bs4 import BeautifulSoup
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
import string

# def tokenize_toot_content(content, min_word_length = 2):
#     soup = BeautifulSoup(content, 'html.parser')
#     text = soup.get_text()
    
#     words = word_tokenize(text)
    
#     # Remove punctuation and convert to lowercase
#     words = [word.lower() for word in words if word.isalnum()]
    
#     # Remove stopwords
#     stop_words = set(stopwords.words('english'))
#     words = [word for word in words if word not in stop_words]
    
#     # Filter out short words
#     words = [word for word in words if len(word) >= min_word_length]
    
#     return words
        

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
        'toot_category': toot_category
    }

    return simplified_toot