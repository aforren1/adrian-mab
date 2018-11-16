from collections import OrderedDict
import numpy as np
import pandas as pd
import yaml
from psychopy.visual.rect import Rect
from psychopy import core, visual, event, gui
from slotmachine import SlotMachine

# settings
settings = OrderedDict({'subject': '001', 'file': 'foo.csv'})

try:
    with open('user_settings.yml', 'r') as f:
        potential_settings = yaml.load(f)
    if potential_settings.keys() == settings.keys():
        for i in settings.keys():
            settings[i] = potential_settings[i]
except (FileNotFoundError, AttributeError):
    pass

dlg = gui.DlgFromDict(settings, title='Experiment')
if not dlg.OK:
    sys.exit()

settings = dict(settings)
with open('user_settings.yml', 'w') as f:
    yaml.dump(settings, f, default_flow_style=False)

# all done settings, now onto the experiment
win = visual.Window(units='height', fullscr=True)

choices = ['a', 's', 'd', 'f']
#grid = [(-0.2, 0.2), (0.2, 0.2), (-0.2, -0.2), (0.2, -0.2)]
grid = [(-0.5, -0.1), (-0.166, -0.1), (0.166, -0.1), (0.5, -0.1)]
colors = ['yellow', 'blue', 'red', 'green']
slots = []
for i, j, k in zip(choices, grid, colors):
    slots.append(SlotMachine(win, id=i.upper(), colour=k, pos=j, size=0.2))

x_img = visual.ImageStim(win, image='x_small.png', pos=(0, 0), size=0.3, opacity=0.8)

# intro screen
info_text = visual.TextStim(win, text='Press any key to start.',
                            pos=(0, 0), alignHoriz='center', alignVert='center', height=0.08, color='white')

info_text.draw()
win.flip()

while not event.getKeys():
    pass

for i in slots:
    i.draw()

win.flip()


#trials = generate_trials(seed=1, trials=150)
trial_timer = core.Clock()


def reset_timer(trial_timer, val):
    trial_timer.reset(val)


for i in range(5):  # for i in trials
    # start with blank screen for 1s
    # draw all stim
    for i in slots:
        i.draw()
    win.callOnFlip(reset_timer, trial_timer, 0)
    win.callOnFlip(event.clearEvents)
    win.flip()
    while trial_timer.getTime() <= 1.5:
        resp = event.getKeys(choices, timeStamped=trial_timer)
        if resp:
            break

    if trial_timer.getTime() > 1.5:  # 2s penalty
        # show big red X
        x_img.draw()
        win.flip()
        core.wait(2)
    else:
        choice, val = resp[0]
        idx = choices.index(choice)
        slots[idx].toggle_id(False)
        slots[idx].toggle_ani(True)
        slots[idx].toggle_arm(30)
        trial_timer.reset(0)
        while trial_timer.getTime() <= 1:
            for i in slots:
                i.draw()
            win.flip()
        slots[idx].toggle_ani(False)
        slots[idx].toggle_points(True)
        slots[idx].update_points_text(np.random.randint(100))
        for i in slots:
            i.draw()
        win.flip()
        core.wait(1 - 1/60)
        slots[idx].toggle_arm(-30)
        slots[idx].toggle_points(False)
        slots[idx].toggle_id(True)
        win.flip()
        print((choice, val))
        core.wait(0.5 - 1/60)

        # timeout=1.5s
        # no choice=2s time penalty
        # 3s animation, then points displayed for 1s
        # screen cleared, then ~2s delay before next trial
