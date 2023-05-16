import json
from datetime import datetime
import nltk
from bs4 import BeautifulSoup
# from transformers import pipeline
# from nltk.tokenize import word_tokenize
# from nltk.corpus import stopwords
# import string

# model_path = "cardiffnlp/twitter-xlm-roberta-base-sentiment"
# sentiment_task = pipeline("sentiment-analysis", model=model_path, tokenizer=model_path)

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
                            'religious', 'الله', 'يسوع', 'الروح القدس', 'الكتاب المقدس', 'صلاة', 'صلّ', 'إيمان', 'عبادة', 
                            'كنيسة', 'قداس', 'سر', 'القربان المقدس', 'التشاركية', 'معمودية', 'عمد', 'عمد', 'اعتراف', 'آمين',
                            'يبارك', 'الله أكبر', 'كاثوليكي', 'مسيحي', 'المسيحية', 'خلاص', 'جنة', 'دين', 'ديني', 'chúa', 
                            'chúa giêsu', 'thánh linh', 'kinh thánh', 'lời cầu nguyện', 'cầu nguyện', 'niềm tin', 'sùng bái', 
                            'nhà thờ', 'thánh lễ', 'bí tích', 'thánh thể', 'lễ thông', 'bí tích rửa tội', 'rửa tội', 'rửa tội', 
                            'sự xưng tội', 'amen', 'chúc lành', 'hallelujah', 'công giáo', 'cơ đốc', 'ki tô giáo', 'sự cứu rỗi', 
                            'thiên đàng', 'tôn giáo', 'tôn giáo', 'ਪਰਮੇਸ਼ੁਰ', 'ਯਿਸੂ', 'ਪਵਿੱਤਰ ਆਤਮਾ', 'ਬਾਇਬਲ', 'ਅਰਦਾਸ', 'ਪ੍ਰਾਰਥਨਾ', 'ਧਰਮ', 
                            'ਪੂਜਾ', 'ਚਰਚ', 'ਮਿਸਾ','ਸਕਰਾਮੈਂਟ', 'ਯੂਕਰਿਸਟ', 'ਸੰਗਤ', 'ਬੈਪਤਿਸਮਾ', 'ਬੈਪਤਿਸਾ', 'ਬੈਪਤਿਸਾ', 'ਇਤਿਫਾਕ', 'ਏਮੇਨ','ਅਸੀਸ', 'ਹੈਲੇਲੂਯਾਹ', 
                            'ਕੈਥੋਲਿਕ', 'ਈਸਾਈ', 'ਈਸਾਈ ਧਰਮ', 'ਮੁਕਤੀ', 'ਸਵਰਗ', 'ਧਰਮ','ਧਾਰਮਿਕ', 'gesù', 'spirito santo', 'bibbia', 
                            'preghiera', 'pregare', 'adorazione', 'chiesa', 'messa', 'sacramento', 'eucaristia', 'comunione', 
                            'battesimo', 'battezzare', 'battezzare', 'confessione', 'amen', 'benedire', 'alleluia', 'cattolico', 
                            'cristiano', 'cristianesimo', 'salvezza', 'paradiso', 'religione', 'religioso', 'diyos', 'hesus', 
                            'banal na espiritu', 'banal na kasulatan', 'dasal', 'manalangin', 'pananampalataya', 'pagsamba', 
                            'simbahan', 'misa', 'sakramento', 'eukaristiya', 'komunyon', 'binyag', 'binyagan', 'binyagan', 
                            'pagpapahayag', 'amen', 'basbasan', 'aleluya', 'katoliko', 'kristiyano', 'kristiyanismo', 'kaligtasan', 
                            'langit', 'relihiyon', 'relihiyoso', 'भगवान', 'ईसा', 'पवित्र आत्मा', 'बाइबल', 'प्रार्थना', 'प्रार्थना करना', 'विश्वास', 
                            'आराधना', 'चर्च', 'मिसा', 'संस्कार', 'यूकरिस्ट', 'संयोग', 'बप्तिस्मा', 'बप्तिस्मा', 'बप्तिस्मा', 'विश्वासघात', 'आमेन', 
                            'आशीर्वाद', 'हैलीलूया', 'कैथोलिक', 'ईसाई', 'ईसाई धर्म', 'मोक्ष', 'स्वर्ग', 'धर्म', 'धार्मिक', 'jesús', 
                            'espíritu santo', 'biblia', 'oración', 'rezar', 'adoración', 'iglesia', 'misa', 'sacramento', 
                            'eucaristía', 'comunión', 'bautismo', 'bautizar', 'bautizar', 'confesión', 'amén', 
                            'bendecir', 'aleluya', 'católico', 'cristiano', 'cristianismo', 'salvación', 'cielo', 'religión',
                            'religioso', '하나님', '예수', '성령', '성경', '기도', '기도하다', '믿음', '예배', '교회', '미사', '성사', '성체', 
                            '성찬', '세례', '세례하다', '세례하다', '고백', '아멘', '축복하다', '할렐루야', '가톨릭', '기독교인', '기독교', '구원', 
                            '천국', '종교', '종교적', 'θεός', 'ιησούς', 'άγιο πνεύμα', 'βίβλος', 'προσευχή', 'προσεύχομαι', 'πίστη', 
                            'λατρεία', 'εκκλησία', 'μάζα', 'μυστήριο', 'ευχαριστία', 'κοινωνία', 'βάπτιση', 'βαπτίζω', 'βαπτίζω', 
                            'εξομολόγηση', 'αμήν', 'ευλογώ', 'αλληλούια', 'καθολικός', 'χριστιανός', 'χριστιανισμός', 'σωτηρία', 
                            'παράδεισος', 'θρησκεία', 'θρησκευτικός', '上帝', '耶稣', '圣灵', '圣经', '祈祷', '信仰', '教堂', 
                            '弥撒', '圣事', '圣餐', '洗礼', '施洗', '忏悔', '阿门', '哈利路亚', '天主教', '基督', '保佑', 
                            '救赎', '天堂', '宗教', 'イエス', '聖霊', '聖書', 'ミサ', '聖体', 'アーメン', 'キリスト', 'ハレルヤ', '天国', '教徒']

    # mental health - depression
    # simplified chinese, arabic, vietnamese, punjabi, greek, italian, filipino, hindi, spanish, japanese, korean
    keyword_depression = ['sad', 'lonely', 'isolated', 'hopeless', 'helpless', 'tired', 'exhausted', 'miserable', 'anxious', 'stressed', 'overwhelmed',
                              'worthless', 'guilty', 'suicidal', 'suicide', 'numb', 'desperate', 'broken', 'lost', 'hopeless', '伤心', '孤独', '孤立', '绝望', 
                              '无助', '疲倦', '筋疲力尽', '痛苦', '焦虑', '紧张', '不堪重负', '内疚', '自杀', '麻木', '迷失', 'حزين', 'وحيد', 'معزول', 'يائس', 
                              'عاجز', 'تعب', 'منهك', 'بائس', 'قلق', 'مضغوط', 'غير قادر على تحمل', 'لا قيمة له', 'مذنب', 'انتحاري', 'انتحار', 'خامل', 'يائس', 
                              'مكسور', 'ضائع', 'buồn', 'cô đơn', 'tách biệt', 'tuyệt vọng', 'bất lực', 'mệt mỏi', 'kiệt sức', 'khốn khổ', 'lo lắng', 'căng thẳng', 
                              'quá tải', 'vô giá trị', 'cảm thấy có lỗi', 'tự tử', 'tự sát', 'tê liệt', 'tuyệt vọng', 'tan vỡ', 'lạc lối', 'ਦੁੱਖੀ', 'ਇਕੱਲਾ', 'ਅਲੱਗ', 
                              'ਨਿਰਾਸ਼ਾਵਾਦੀ', 'ਬੇਸਹਾਰਾ', 'ਥੱਕਿਆ', 'ਥੱਕੇ', 'ਪੀੜਿਤ', 'ਚਿੰਤਾਵਾਂ', 'ਤਣਾਓ', 'ਬੇਹਦ ਪਰੇਸ਼ਾਨ', 'ਬੇਮੂਲ', 'ਦੋਸ਼ੀ', 'ਆਤਮਘਾਤੀ', 'ਆਤਮਘਾਤ', 'ਸੁਨ', 'ਮਾਯੂਸ', 'ਟੁੱਟਿਆ ਹੋਇਆ', 
                              'ਖੋਇਆ ਹੋਇਆ', 'λυπημένος', 'μοναχικός', 'απομονωμένος', 'απελπισμένος', 'αβοήθητος', 'κουρασμένος', 'εξαντλημένος', 'δυστυχισμένος', 
                              'ανήσυχος', 'αγχωμένος', 'συντετριμμένος', 'άνευ αξίας', 'ένοχος', 'αυτοκτονικός', 'αυτοκτονία', 'νωχελικός', 'απεγνωσμένος', 
                              'σπασμένος', 'χαμένος', 'triste', 'solitario', 'isolato', 'senza speranza', 'impotente', 'stanco', 'esausto', 'miserabile', 
                              'ansioso', 'stressato', 'sopraffatto', 'inutile', 'colpevole', 'suicida', 'suicidio', 'intorpidito', 'disperato', 'rotto', 'perso',
                              'malungkot', 'nalulumbay', 'inaalis', 'walang pag-asa', 'walang magawa', 'pagod', 'sa wakas', 'hindi masaya', 'nababahala', 
                              'na-stress', 'napupuno', 'walang halaga', 'nagkasala', 'pakikipagpakamatay', 'pagpapatiwakal', 'manhid', 'napakahilig', 'sira', 
                              'naligaw', 'दुखी', 'अकेला', 'अलग़', 'निराश', 'लाचार', 'थका हुआ', 'हरा हुआ', 'दु:खी', 'चिंतित', 'तनावग्रस्त', 'अधिकता', 'निरर्थक', 'दोषी', 'आत्मघाती', 
                              'आत्महत्या', 'सुना', 'निराश', 'टूटा हुआ', 'खोया हुआ', 'triste', 'solitario', 'aislado', 'desesperanzado', 'impotente', 'cansado', 'agotado', 
                              'miserable', 'ansioso', 'estresado', 'abrumado', 'sin valor', 'culpable', 'suicida', 'suicidio', 'insensible', 'desesperado', 'roto', 
                              'perdido', '悲しい', '孤独', '孤立', '絶望的', '無力', '疲れた', '疲れ果てた', '惨めな', '不安', 'ストレス', '圧倒された', '無価値', '罪悪感', '自殺', 
                              '無感覚', '必死', '壊れた', '失われた', '슬프다', '외로운', '고립된', '절망적인', '무력한', '피곤한', '지친', '비참한', '불안한', '스트레스 받는', '이기적인', 
                              '가치 없는', '죄책감', '자살적인', '자살', '마비된', '절망적인', '부서진', '잃어버린']
    
    # Ukraine vs. Russia
    # simplified chinese, arabic, vietnamese, punjabi, greek, italian, filipino, hindi, spanish, japanese, korean
    keyword_RU = ['russia', 'ukraine', 'putin', 'zelenskyy', 'kyjv', '俄罗斯', '乌克兰', '普京', '泽连斯基', '基辅', 'روسيا', 'أوكرانيا', 'بوتين', 'زيلينسكي', 
                    'كييف', 'ਰੂਸ', 'ਯੂਕਰੇਨ', 'ਪੁੱਤਿਨ', 'ਜ਼ੈਲੇਨਸਕੀ', 'ਕੀਵ', 'ρωσία', 'ουκρανία', 'πούτιν', 'ζελένσκι', 'κίεβο',
                    'ucraina', 'kiev', 'rusya', 'ukrayna', 'रूस', 'यूक्रेन', 'पुतिन', 'ज़ेलेंस्की', 'कीव', 'rusia', 'ucrania', 'ロシア', 
                    'ウクライナ', 'プーチン', 'ゼレンスキー', 'キエフ', '러시아', '우크라이나', '푸틴', '젤렌스키', '키예프']


    # Parse date format into YYYY-MM-DD HH:MM:SS
    DATE_FORMAT = '%Y-%m-%dT%H:%M:%S.%fZ'

    # note - toots do not contain location information
    toot_id = one_toot['id']
    toot_time = datetime.strptime(one_toot['created_at'], DATE_FORMAT)
    toot_time = toot_time.strftime('%Y-%m-%d %H:%M:%S')
    content_string = one_toot['content'].lower()
    soup = BeautifulSoup(content_string, 'html.parser')
    toot_content = soup.get_text()
    tags_list = one_toot['tags']
    toot_tags = [tag["name"] for tag in tags_list]
    toot_language = one_toot['language']
    # toot_sentiment = sentiment_task(toot_content)

    # classify toots into categories
    toot_category = []
    if any(kw in toot_content for kw in keyword_religion):
        toot_category.append('religion')
    if any(kw in toot_content for kw in keyword_depression):
        toot_category.append('depression')
    if any(kw in toot_content for kw in keyword_RU):
        toot_category.append('RU')
    

    simplified_toot = {
        'toot_id': toot_id,
        'toot_time': toot_time,
        'toot_language': toot_language,
        'toot_content': toot_content,
        'toot_tags': toot_tags,
        'toot_category': toot_category
        # 'toot_sentiment': toot_sentiment
    }

    return simplified_toot