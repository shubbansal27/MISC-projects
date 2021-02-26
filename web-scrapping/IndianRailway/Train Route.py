import requests

# variables
TRAIN_NO = '12985'
API_KEY = 'xxkoy9154'


RUN_URL = 'http://api.railwayapi.com/route/train/'+TRAIN_NO+'/apikey/'+API_KEY+'/'

r = requests.get(RUN_URL)
result = r.json()['route']


count = 1
for item in result:
    print '#'+str(count), item['fullname'], ',', item['state']
    count = count + 1








