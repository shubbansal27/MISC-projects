from apiclient.discovery import build
import webbrowser

def main():


  #browser parameters
  chrome_path = 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe %s'

  
  # the Google APIs Console <http://code.google.com/apis/console>
  # to get an API key/developer key for your own application.
  service = build("customsearch", "v1",
            developerKey="vsvsvvsvsvsvsv")


  #Query
  query = 'gate2015 Viable prefixes'
  #set number of results 
  numResults = 3


  res = service.cse().list(
      q=query,
      cx='svsvsvvsvsv',     #search-engine-ID
                                                  #https://cse.google.com/cse/manage/all  
      num = numResults,                           
    ).execute()
 
  results = res['items']
  for item in results:
    url = item['link']
    print url
    
    #open url
    #webbrowser.open_new_tab(url)    #will open in Internet explorer
    #opening url in chrome
    #for non-blocking access, keep chrome open already..
    webbrowser.get(chrome_path).open_new_tab(url)
    

if __name__ == '__main__':
  main()
