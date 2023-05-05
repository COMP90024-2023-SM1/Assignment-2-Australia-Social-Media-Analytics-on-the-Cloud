import couchdb
import json

from tweet_preprocess_utils import *

MASTER_NODE = '172.26.134.229'
ADMIN = 'admin'
PASSWORD = 'admin'

class DataStore():

    def __init__(self, db_name, url=f'http://{ADMIN}:{PASSWORD}@{MASTER_NODE}:5984/'):
        try:
            self.server = couchdb.Server(url=url)
            self.db = self.server.create(db_name)
            # self._create_views()
        except couchdb.http.PreconditionFailed:
            self.db = self.server[db_name]

    def save_record(self, record_batch):
        self.db.update(record_batch)

    # def _create_views(self):
    #     count_map = 'function(doc) { emit(doc.id, 1); }'
    #     count_reduce = 'function(keys, values) { return sum(values); }'
    #     view = couchdb.design.ViewDefinition('twitter', 
    #                                          'count_tweets', 
    #                                          count_map, 
    #                                          reduce_fun=count_reduce)
    #     view.sync(self.db)

    # def count_tweets(self):
    #     for doc in self.db.view('twitter/count_tweets'):
    #         return doc.value

    def tweet_processor(self, tweet_path, block_start, block_end):
        # religion - catholic & christian
        # english, simplified chinese, arabic, vietnamese, punjabi, greek, italian, filipino, hindi, spanish, japanese, korean
        keyword_religion = ['god', 'jesus', 'holy spirit', 'bible', 'prayer', 'pray', 'faith', 'worship', 'church', 'mass',
                            'sacrament', 'eucharist', 'communion', 'baptism', 'baptise', 'baptize', 'confession', 'amen',
                            'bless', 'hallelujah', 'catholic', 'christian', 'christianity', 'salvation', 'heaven', 'religion',
                            'religious', '上帝', '保佑', '耶稣', '天主', '基督', 'الله', 'يُبارِك', 
                            'يسوع', 'كاثوليكي', 'مسيحي', 'chúa', 'ban phước', 'giêsu', 'công giáo', 'kitô giáo', 'ਰੱਬ', 'ਆਸ਼ੀਰਵਾਦ ਦੇਣਾ', 'ਜੀਸਸ', 'ਕੈਥੋਲਿਕ',
                            'ਈਸਾਈ', 'Θεός', 'ευλογώ', 'Ιησούς', 'καθολικός', 'Χριστιανός', 'dio', 'benedire', 'gesù', 'cattolico', 'cristiano',
                            'diyos', 'pagpalain', 'hesus', 'katoliko', 'kristiyano', 'भगवान', 'आशीर्वाद', 'यीशु', 'कैथोलिक', 'ईसाई', 'dios', 'bendecir',
                            'jesús', 'católico', 'cristiano', '神', 'イエス', 'カトリック', 'キリスト', '하나님', '축복하다', '예수', '가톨릭', '기독교인']


        # mental health - depression
        # english, simplified chinese, arabic, vietnamese, punjabi, greek, italian, filipino, hindi, spanish, japanese, korean
        keyword_depression = ['sad', 'lonely', 'isolated', 'hopeless', 'helpless', 'tired', 'exhausted', 'miserable', 'anxious', 'stressed', 'overwhelmed',
                              'worthless', 'guilty', 'suicidal', 'suicide', 'numb', 'desperate', 'broken', 'lost', '焦虑', '抑郁', 
                              '想死', '自杀', '焦躁', 'القلق', 'الاكتئاب', 'مكتئب', 'انتحار', 'أريد الموت', 'اضطراب نفسي', 'محبط', 'lo âu', 'trầm cảm', 
                              'chán nản', 'tự tử', 'muốn chết', 'rối loạn tâm thần', 'nản lòng', 'ਚਿੰਤਾ', 'ਡਿਪ੍ਰੈਸ਼ਨ', 'ਉਦਾਸ', 'ਆਤਮਘਾਤੀ', 'ਮਰਨਾ ਚਾਹੁੰਦੇ', 'ਮਾਨਸਿਕ ਬਿਮਾਰੀ', 
                              'ਮਾਯੂਸ', 'αγχος', 'κατάθλιψη', 'καταθλιπτικός', 'αυτοκτονία', 'αυτοκτονικός', 'θέλω να πεθάνω', 'ψυχική διαταραχή',
                              'απογοητευμένος', 'ansia', 'depressione', 'depresso', 'suicidio', 'suicida', 'voglio morire', 'disturbo mentale', 'frustrato'
                              'pagkabalisa', 'depresyon', 'deprimido', 'pagpapakamatay', 'nais mamatay', 'gusto mamatay', 'sakit sa isip', 'चिंता', 'अवसाद',
                              'उदास', 'आत्महत्या', 'आत्मघाती', 'मरना चाहते हैं', 'मानसिक विकार', 'परेशान', 'ansiedad', 'depresión', 'deprimido/a', 'quiero morir', 
                              'trastorno mental', 'frustrado/a', '抑うつ', '鬱症状', '自殺', '死にたい', '精神障害', '挫折した', '불안', '우울증', '우울한', '자살', 
                              '죽고 싶다', '정신 장애', '좌절감']
        

        # crime
        # simplified chinese, arabic, vietnamese, punjabi, greek, italian, filipino, hindi, spanish, japanese, korean
        keyword_crime = ['robbery', 'police', 'murder', 'kill', 'suicide', 'corpse', 'violence', 'theft', 'assault', 'felony', 'terrorism', '抢劫', 
                        '警察', '谋杀', '自杀', '尸体', '暴力', '盗窃', '袭击', '重罪', '恐怖主义', '犯罪', 'سرقة', 'شرطة', 'قتل', 'يقتل', 'انتحار', 
                        'جثة', 'عنف', 'سرقة', 'اعتداء', 'جناية', 'إرهاب', 'cướp bóc', 'cảnh sát', 'giết người', 'giết', 'tự tử', 'xác chết', 'bạo lực', 
                        'trộm cắp', 'tấn công', 'tội ác', 'khủng bố', 'ਡਾਕਾ', 'ਪੁਲਿਸ', 'ਕਤਲ', 'ਮਾਰਨਾ', 'ਆਤਮਘਾਤੀ', 'ਲਾਸ਼', 'ਹਿੰਸਾ', 'ਚੋਰੀ', 'ਹਮਲਾ', 'ਗੰਭੀਰ ਅਪਰਾਧ', 
                        'ਆਤੰਕਵਾਦ', 'ληστεία', 'αστυνομία', 'δολοφονία', 'σκοτώνω', 'αυτοκτονία', 'πτώμα', 'βία', 'κλοπή', 'επίθεση', 'κακούργημα', 
                        'τρομοκρατία', 'rapina', 'polizia', 'omicidio', 'uccidere', 'suicidio', 'cadavere', 'violenza', 'furto', 'aggressione', 
                        'crimine', 'terrorismo', 'pagnanakaw', 'pulis', 'pagpatay', 'pumatay', 'pagpapakamatay', 'bangkay', 'karahasan', 'pagnanakaw', 
                        'pagsalakay', 'kasalanang mabigat', 'terorismo', 'डकैती', 'पुलिस', 'हत्या', 'मारना', 'आत्महत्या', 'लाश', 'हिंसा', 'चोरी', 'हमला', 'अपराध', 
                        'आतंकवाद', 'policía', 'asesinato', 'matar', 'suicidio', 'cadáver', 'violencia', 'robo', 'asalto', 'delito', 'terrorismo',
                        '強盗', '殺人', '自殺', '死体', '窃盗', '暴行', 'テロ', '강도', '경찰', '살인', '죽이다', '자살', '시체', '폭력', '절도', '폭행', '중범죄', '테러']
        
        
        docs_to_insert = []
        with open(tweet_path, 'rb') as file:
            file.seek(block_start)
            while file.tell() != block_end:
                line = file.readline().splitlines()[0].decode('utf-8')
                if line[-1] == ',': # Check if current line has trailing comma
                    line = line[:-1] # Remove trailing comma

                try:
                    tweet = json.loads(line)
                    if tweet['doc']['data']['geo'] != {} and tweet['doc']['data']['lang'] != 'und':
                        if is_within_australia([tweet['doc']['includes']['places'][0]['geo']['bbox'][1], tweet['doc']['includes']['places'][0]['geo']['bbox'][0]]):
                            tweet = extract_tweet_info(tweet)
                            if any(kw in tweet['tweet_text']for kw in keyword_religion):
                                tweet['category'] = 'religion'
                            elif any(kw in tweet['tweet_text']for kw in keyword_depression):
                                tweet['category'] = 'depression'
                            elif any(kw in tweet['tweet_text']for kw in keyword_crime):
                                tweet['category'] = 'crime'
                            else:
                                tweet['category'] = ''

                            if tweet['category'] != '':
                                tweet = json.dumps(tweet)
                                tweet = json.loads(tweet)
                                docs_to_insert.append(tweet)

                except (KeyError, ValueError, TypeError) as e:
                    pass

                # Inserting tweets by batch to speed up the process
                if len(docs_to_insert) == 1000:
                    self.save_record(docs_to_insert)
                    docs_to_insert = []

            # Insert the remaining tweets
            if len(docs_to_insert) != 0:
                self.save_record(docs_to_insert)