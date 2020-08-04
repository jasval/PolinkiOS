from datetime import datetime, timedelta, date

today = date.today()
datetime_today = datetime.now()

timestamp = int(datetime_today.timestamp() * 1000)
timestamp_str = str(timestamp)
yesterday = datetime_today - timedelta(days=1)
yesterday_timestamp = int(yesterday.timestamp() * 1000)
yesterday_timestamp_str = str(yesterday_timestamp)


print(f"language:english site_type:news thread.country:GB site:(bbc.co.uk OR theguardian.com) (\"Brexit\" OR \"Politics\" OR \"Labour\" OR \"Conservatives\" OR \"Parliament\" OR \"parliament\" OR \"immigration\" OR \"Immigration\" OR \"labour\" OR \"politics\") -Opinion -review -football thread.section_title:(-sport -stage -Books -Opinion -Film) published:>{yesterday_timestamp_str}")