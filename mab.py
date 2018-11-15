import numpy as np
from psychopy.visual.rect import Rect
from psychopy import core, visual, event
from slotmachine import SlotMachine

win = visual.Window(units='height', fullscr=True)

choices = ['a', 's', 'd', 'f']
#grid = [(-0.2, 0.2), (0.2, 0.2), (-0.2, -0.2), (0.2, -0.2)]
grid = [(-0.5, -0.1), (-0.166, -0.1), (0.166, -0.1), (0.5, -0.1)]
colors = ['yellow', 'blue', 'red', 'green']
slots = []
for i, j, k in zip(choices, grid, colors):
    slots.append(SlotMachine(win, id=i.upper(), colour=k, pos=j, size=0.2))

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
