import facebook

def main():
  
    cfg = {
    "access_token" : "dsdssdsds"   
    }


    graph = facebook.GraphAPI(cfg['access_token'])
    data = graph.get_object('me?fields=friends')

    for friend in data['friends']['data']:
        print friend[name]
  

if __name__ == "__main__":
  main()



#try query from graph explorer
#https://developers.facebook.com/tools/explorer
