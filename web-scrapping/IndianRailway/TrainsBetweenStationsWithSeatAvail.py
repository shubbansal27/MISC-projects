import requests

def checkSeatAvailability(TRAIN_NO, SOURCE, DEST, DATE, CLASS, QUOTA):
    RUN_URL = 'http://api.railwayapi.com/check_seat/train/'+TRAIN_NO+'/source/'+SOURCE+'/dest/'+DEST+'/date/'+DATE+'/class/'+CLASS+'/quota/'+QUOTA+'/apikey/'+API_KEY+'/'
    noAttempt = 3
    flag = False
    for i in range(noAttempt):
         
        r = requests.get(RUN_URL)
        result = r.json()['availability']

        if len(result) > 0:
            print '   >>' + CLASS + ':' + result[0]['status']
            flag = True
            break
        

    if not flag:
        print '   >>' + CLASS + ':' + 'Error in fetching details, server might be busy.'





#### main #####

# variables
SOURCE = 'JP'
DEST = 'DEE'
DATE = '27-03-2016'  #DD-MM-YYYY format
QUOTA = 'GN'

API_KEY = 'xxkoy9154'
RUN_URL = 'http://api.railwayapi.com/between/source/'+SOURCE+'/dest/'+DEST+'/date/'+DATE+'/apikey/'+API_KEY+'/'

r = requests.get(RUN_URL)
result = r.json()['train']
count = 1

print 'Date: ' + DATE, '   From: ' + SOURCE, '   To: ' + DEST
for item in result:
    TRAIN_NO = item['number']
    print 'Train#'+ str(count), item['name'] + ' (' + TRAIN_NO + ')', '   dept_time: ' + item['src_departure_time'], '   arrival_time: ' + item['dest_arrival_time'], '   travel_time: ' + item['travel_time']  
    count = count + 1
    classes = item['classes']

    for cl in classes:
        if cl['available'] == 'Y':
            CLASS =  cl['class-code']
            #check seat availability
            checkSeatAvailability(TRAIN_NO, SOURCE, DEST, DATE, CLASS, QUOTA)

    print('\n')







