### https://automatetheboringstuff.com/chapter18/
##https://virtualpiano.net/
## play piano automatically
# first open https://virtualpiano.net/ in browser in maximize screen

import pyautogui, time

keys = ['1','2','3','4','5','6','7','8','9','0','q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m']
pos = {}
p = 79
q = 521
for item in keys: 
    pos[item] = (p,q)
    p += 35
    

# finding cursor position
'''
(x,y) =  pyautogui.position()
'''

#play all keys
'''
for item in keys: 
    print item, pos[item]
    #click at x,y
    (x,y) = pos[item]
    pyautogui.click(x, y)
    time.sleep(1)
'''

#play notes
# hum tere bin ab reh nhi sakte
notes = 'etuityr etuityr upooi iuyt yiuu'

for item in notes:
    if item in pos:
	(x,y) = pos[item]
	pyautogui.click(x, y)

    time.sleep(.300)


