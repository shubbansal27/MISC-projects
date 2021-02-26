import requests

# variables
TRAIN_NO = '12987'
SOURCE = 'CNB'
DEST = 'JP'
DATE = '05-03-2016'
CLASS = '3A'
QUOTA = 'GN'


API_KEY = 'xxkoy9154'
RUN_URL = 'http://api.railwayapi.com/check_seat/train/'+TRAIN_NO+'/source/'+SOURCE+'/dest/'+DEST+'/date/'+DATE+'/class/'+CLASS+'/quota/'+QUOTA+'/apikey/'+API_KEY+'/'

noAttempt = 5
flag = False
for i in range(noAttempt):
    print 'Checking seat availability, attempt#'+ str(i+1)
    r = requests.get(RUN_URL)
    result = r.json()['availability']

    if len(result) > 0:
        for item in result:
            print item
        flag = True
        break
    

if not flag:
    print 'Error: Server might be busy.'
    








