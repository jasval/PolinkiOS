
import firebase_admin
from firebase_admin import firestore
from newsapi import NewsApiClient
import webhoseio

from datetime import datetime, timedelta, date
import flask


app = flask.Flask(__name__)

# Initialise the Firebase Admin SDK and references
firebase_admin.initialize_app()
db =  firestore.client()
CURRENTNEWS = db.collection('news')

# Initialise the news api client connection
newsapi = NewsApiClient(api_key='401e8ec817324c00bcf820b74b37ab18')

#Initialise the webhoseclient with the config
# webhoseio.config(token="b2ecce30-520d-49d0-bb5e-e73a16e6f81e")


class Article:
    def __init__(self, source_file):
        self.source = source_file['thread']['section_title']
        self.author = source_file['author']
        self.title = source_file['thread']['title']
        self.description = source_file['text']
        self.url = source_file['thread']['url']
        self.image_url = source_file['thread']['main_image']
        self.publishedAt = source_file['thread']['published']
    def __str__(self):
        return self.source + self.author + self.title

    # @staticmethod
    def to_dict(self):
        data = {
            u'source' : self.source,
            u'title' : self.title,
            u'author' : self.author,
            u'description' : self.description,
            u'url' : self.url,
            u'image_url' : self.image_url,
            u'publishedAt' : self.publishedAt
        }
        return data

    def __repr__(self):
        return (
            f'Headline(\
                source={self.source}, \
                title={self.title}, \
                published={self.publishedAt}, \
                description={self.description} \
            )'
        )

class Headline:
    def __init__(self, source_file):
        self.source = source_file['source']['name']
        self.author = source_file['author']
        self.title = source_file['title']
        self.description = source_file['description']
        self.url = source_file['url']
        self.image_url = source_file['urlToImage']
        self.publishedAt = source_file['publishedAt']
    def __str__(self):
        return self.source + self.author + self.title
    
    # @staticmethod
    def to_dict(self):
        data = {
            u'source' : self.source,
            u'title' : self.title,
            u'author' : self.author,
            u'description' : self.description,
            u'url' : self.url,
            u'image_url' : self.image_url,
            u'publishedAt' : self.publishedAt
        }
        return data

    def __repr__(self):
        return (
            f'Headline(\
                source={self.source}, \
                title={self.title}, \
                published={self.publishedAt}, \
                description={self.description} \
            )'
        )

@app.route('/news', methods=['POST'])
def update_news():
    today = date.today()
    datetime_today = datetime.now()
    news = CURRENTNEWS.document(str(today))
    TODAYSARTICLES = news.collection('articles')

    timestamp = int(datetime_today.timestamp() * 1000)
    timestamp_str = str(timestamp)
    yesterday = datetime_today - timedelta(days=1)
    yesterday_timestamp = int(yesterday.timestamp() * 1000)
    yesterday_timestamp_str = str(yesterday_timestamp)


    # query_params = {
    #     "q": f"language:english site_type:news thread.country:GB site:(bbc.co.uk OR theguardian.com) (\"Brexit\" OR \"Politics\" OR \"Labour\" OR \"Conservatives\" OR \"Parliament\" OR \"parliament\" OR \"immigration\" OR \"Immigration\" OR \"labour\" OR \"politics\") -Opinion -review -football thread.section_title:(-sport -stage -Books -Opinion -Film) published:>{yesterday_timestamp_str}",
    #     "ts": yesterday_timestamp_str,
    #     "sort": "published"
    # }

    today_data = {u'date': datetime_today}


    # output = webhoseio.query("filterWebContent", query_params)

    # todays_headlines = []
    # for post in output['posts']:
    #     headline = Article(post)
    #     todays_headlines.append(headline)
    #     print(repr(headline))

    # news.set(today_data)

    # # Delete previously stores articles to avoid duplicates
    # docs = TODAYSARTICLES.get()
    # for doc in docs:
    #     ref = doc.reference
    #     ref.delete()
    
    # for headline in todays_headlines:
    #     TODAYSARTICLES.add(headline.to_dict())

    # Define the pre-defined API requests to get latest news
    top_headlines = newsapi.get_top_headlines(sources='google-news-uk', language='en')
    
    # Create Array to hold each headline
    todays_headlines = []
    
    if top_headlines['status'] == 'ok':
        for article in top_headlines['articles']:
            headline = Headline(article)
            todays_headlines.append(headline)
            print(repr(headline))
    
    news.set(today_data)

    #Delete previous stored messages to avoid duplicates
    docs = TODAYSARTICLES.get()
    for doc in docs:
        ref = doc.reference
        ref.delete()

    for headline in todays_headlines:
        TODAYSARTICLES.add(headline.to_dict())

    return flask.jsonify(today_data), 201


    
if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)