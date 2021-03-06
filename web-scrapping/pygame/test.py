import pygame

pygame.init()

display_width = 800
display_height = 600

black = (0,0,0)
white = (255,255,255)
red = (255,0,0)

gameDisplay = pygame.display.set_mode((display_width,display_height))
pygame.display.set_caption('Test game')
clock = pygame.time.Clock()

carImg = pygame.image.load('images/racecar1.png')

def car(x,y):
    gameDisplay.blit(carImg,(x,y))
    
x = (display_width * 0)
y = (display_height * 0.7)

x_change = 0

crashed = False

while not crashed:

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            crashed = True

        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_LEFT:
                x_change = -5
            elif event.key == pygame.K_RIGHT:
                x_change = 5

        if event.type == pygame.KEYUP:
            if event.key == pygame.K_LEFT or event.key == pygame.K_RIGHT:
                x_change = 0
            
            

    x += x_change
    
    gameDisplay.fill(white)
    car(x,y)
    pygame.display.update()
    clock.tick(60)


pygame.quit()
quit()

