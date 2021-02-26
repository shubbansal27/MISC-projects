import facebook

def main():
  
  cfg = {
    "access_token" : "ffdfdfdd"   
    }


  graph = facebook.GraphAPI(cfg['access_token'])
  data = graph.get_object('me?fields=albums{id,name}')

  count = 1
  for album in data['albums']['data']:
    print count,')Album: ',album['name'],' (',album['id'],')'
    count = count + 1
    print '----------------------------------------------'
    query = album['id']+'?fields=photos{link}'
    dataAlbum = graph.get_object(query)
    for photo in dataAlbum['photos']['data']:
      print photo['link']
    print ''


if __name__ == "__main__":
  main()



#try query from graph explorer
#https://developers.facebook.com/tools/explorer
