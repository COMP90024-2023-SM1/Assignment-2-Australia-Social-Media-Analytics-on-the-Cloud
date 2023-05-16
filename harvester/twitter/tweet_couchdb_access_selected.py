import couchdb
import json

from tweet_preprocess_utils import *

MASTER_NODE = '172.26.128.113'
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
                            tweet = extract_tweet_info_gcc(tweet)
                            
                            # if any(kw in tweet['tweet_text']for kw in keyword_religion):
                            #     tweet['category'] = 'religion'
                            # elif any(kw in tweet['tweet_text']for kw in keyword_depression):
                            #     tweet['category'] = 'depression'
                            # elif any(kw in tweet['tweet_text']for kw in keyword_crime):
                            #     tweet['category'] = 'crime'
                            # elif any(kw in tweet['tweet_text']for kw in keyword_RU):
                            #     tweet['category'] = 'RU'
                            # else:
                            #     tweet['category'] = ''

                            categories = []

                            if any(kw in tweet['tweet_text'] for kw in keyword_religion):
                                categories.append('religion')
                            if any(kw in tweet['tweet_text'] for kw in keyword_depression):
                                categories.append('depression')
                            # if any(kw in tweet['tweet_text'] for kw in keyword_crime):
                            #     categories.append('crime')
                            if any(kw in tweet['tweet_text'] for kw in keyword_RU):
                                categories.append('RU')

                            tweet['category'] = categories

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