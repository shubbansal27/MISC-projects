import facebook
import urllib

def main():
  
  cfg = {
    "access_token" : "dsdsdsdsd"   
    }


  graph = facebook.GraphAPI(cfg['access_token'])
  data = graph.get_object('me?fields=albums{id,name}')

  count = 1
  for album in data['albums']['data']:
    print count,')Album: ',album['name'],' (',album['id'],')'
    count = count + 1
    print '----------------------------------------------'
    query = album['id']+'?fields=photos{picture}'
    dataAlbum = graph.get_object(query)
    count = 1
    for photo in dataAlbum['photos']['data']:

      url = photo['picture']
      savepath = album['id']+'_'+str(count)+'.jpg'
      count = count + 1
      print url
      
      #download photo   
      urllib.urlretrieve(url, savepath)

    print ''


if __name__ == "__main__":
  main()



#try query from graph explorer
#https://developers.facebook.com/tools/explorer
