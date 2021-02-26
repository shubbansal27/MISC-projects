import requests

# variables
SOURCE = 'JP'
DEST = 'NDLS'
DATE = '28-03'   #DD-MM format


API_KEY = 'xxkoy9154'
RUN_URL = 'http://api.railwayapi.com/between/source/'+SOURCE+'/dest/'+DEST+'/date/'+DATE+'/apikey/'+API_KEY+'/'

r = requests.get(RUN_URL)
result = r.json()['train']
count = 1

print 'Date: ' + DATE, '   From: ' + SOURCE, '   To: ' + DEST
for item in result:
    print 'Train#'+ str(count), item['name'] + ' (' + item['number'] + ')', '   dept_time: ' + item['src_departure_time'], '   arrival_time: ' + item['dest_arrival_time'], '   travel_time: ' + item['travel_time']  
    count = count + 1
    classes = item['classes']

    print '           >> Availability in:  ',
    for cl in classes:
        if cl['available'] == 'Y':
            print cl['class-code'],
    print(' ')
    print('\n')







