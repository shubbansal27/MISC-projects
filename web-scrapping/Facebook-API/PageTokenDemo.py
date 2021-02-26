import facebook

def main():
  
  cfg = {
    "page_id"      : "1751216005114842",  
    "access_token" : "sdsdsdsdsd"   
    }


  graph = facebook.GraphAPI(cfg['access_token'])
  msg = "test test"
  status = graph.put_wall_post(msg)



if __name__ == "__main__":
  main()



#try query from graph explorer
#https://developers.facebook.com/tools/explorer
