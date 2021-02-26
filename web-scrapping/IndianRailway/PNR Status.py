import requests

# variables
PNR = '6149478514'
API_KEY = 'xxkoy9154'


RUN_URL = 'http://api.railwayapi.com/pnr_status/pnr/'+PNR+'/apikey/'+API_KEY+'/'

r = requests.get(RUN_URL)
result = r.json()

print 'Train-Number: ', result['train_num']
print 'Train-Name: ', result['train_name']
print 'Class: ', result['class']
print '-----------------------------------------'
print 'Date of Journey: ', result['doj']
print 'From: ', result['from_station']['name'] + '('+result['from_station']['code']+')'
print 'To: ', result['reservation_upto']['name'] + '('+result['reservation_upto']['code']+')'
print '-----------------------------------------'
print 'PNR: ',PNR
print 'Current status: ', result['passengers'][0]['current_status']
print 'Chart Prepared: ', result['chart_prepared']





