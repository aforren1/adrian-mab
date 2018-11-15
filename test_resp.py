from psychopy import core, visual, event

win = visual.Window()

choices = ['a', 's', 'd', 'f']
while True:
    resp = event.getKeys(choices, timeStamped=True)
    if resp:
        break

print(resp)

core.quit()
