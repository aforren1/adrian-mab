import os
import sys
from string import ascii_lowercase
from datetime import datetime

from collections import OrderedDict
import numpy as np
import pandas as pd
import yaml
from psychopy.visual.rect import Rect
from psychopy import core, visual, event, gui
from make_seq import make_seq
from feedback import Feedback

settings = OrderedDict({'subject': '001'})
dt = datetime.now().strftime('%Y%m%d-%H%M%S')
dlg = gui.DlgFromDict(settings, title='Experiment')

if not dlg.OK:
    sys.exit()

# generate tables
seeds = list(range(2))

blocks = []
practice = 3
trials = 3
# 4-choice
# warmup
blocks.append((4, make_seq(filename=None, num_resp=4, num_trials=practice, seed=100)))

for i in seeds:
    blocks.append((4, make_seq(filename=None, num_resp=4, num_trials=trials, seed=i)))

# 8-choice
for i in seeds:
    blocks.append((8, make_seq(filename=None, num_resp=8, num_trials=trials, seed=i+10)))

# 26-choice
for i in seeds:
    blocks.append((26, make_seq(filename=None, num_resp=26, num_trials=trials, seed=i+10)))

blocks = [(i, x.to_dict('records')) for i, x in blocks]
keys = {}
keys[4] = ['h', 'u', 'i', 'l']
keys[8] = ['a', 'w', 'e', 'f'] + keys[4]
keys[26] = list(ascii_lowercase)

# set up visuals
win = visual.Window(units='height', fullscr=True, allowGUI=False)

feedback = Feedback(win)

center_sets = {'pos': (0, 0), 'alignHoriz': 'center', 'alignVert': 'center',
               'height': 0.05, 'color': 'white'}
remind_sets = center_sets.copy()
remind_sets['pos'] = (0, -0.2)
intro_txt = visual.TextStim(win, text='Press any key to start.', **center_sets)

break_txt = visual.TextStim(win, text='Take a break. Press any key to continue.',
                            **center_sets)

instr_txt = {}
instr_txt[4] = visual.TextStim(win, text=('For this 4-choice section,'
                                          '\nuse the keys H, U, I, and L.'
                                          '\nGet the highest score you can.'
                                          '\nPress any key to start.'),
                               **center_sets)

instr_txt[8] = visual.TextStim(win, text=('For this 8-choice section,'
                                          '\nuse the keys A, W, E, F, H, U, I, and L.'
                                          '\nGet the highest score you can.'
                                          '\nPress any key to start.'),
                               **center_sets)

instr_txt[26] = visual.TextStim(win, text=('For this 26-choice section,'
                                           '\nuse all letters of the alphabet.'
                                           '\nGet the highest score you can.'
                                           '\nPress any key to start.'),
                                **center_sets)

remind_txt = {}
remind_txt[4] = visual.TextStim(win, text='H, U, I, L', **remind_sets)

remind_txt[8] = visual.TextStim(win, text='A, W, E, F, H, U, I, L',
                                **remind_sets)

remind_txt[26] = visual.TextStim(win, text='Entire Alphabet', **remind_sets)

intro_txt.draw()
win.flip()
event.waitKeys()

trial_timer = core.Clock()

total_points = 0
max_possible = 0
block_count = 0

for number_choices, block_table in blocks:
    # intro text
    instr_txt[number_choices].draw()
    win.flip()

    event.waitKeys()
    block_data = []
    # loop through trials within a block
    for trial in block_table:
        if event.getKeys(['esc', 'escape']):
            core.quit()
        feedback.state = 'idle'
        feedback.draw()
        remind_txt[number_choices].draw()
        win.callOnFlip(trial_timer.reset, 0)
        win.flip()

        choice, val = event.waitKeys(keyList=keys[number_choices],
                                     timeStamped=trial_timer,
                                     clearEvents=True)[0]
        idx = keys[number_choices].index(choice)
        trial_timer.reset(0)
        feedback.state = 'ani'
        while trial_timer.getTime() <= 0.5:
            feedback.draw()
            remind_txt[number_choices].draw()
            win.flip()
        feedback.state = 'points'
        feedback.points = trial[idx]
        total_points += trial[idx]
        max_possible += max(trial.values())
        trial_data = {'subject': settings['subject'],
                      'choice': idx,
                      'reaction_time': val,
                      'points': trial[idx],
                      'total_points': total_points,
                      'max_possible': max_possible}
        trial_data.update(trial)
        block_data.append(trial_data)

        feedback.draw()
        remind_txt[number_choices].draw()
        win.flip()
        core.wait(0.5 - 1/60)
        feedback.state = 'cooldown'
        remind_txt[number_choices].draw()
        win.flip()

    prop_of_possible = round(float(total_points)/float(max_possible), 2)
    intro_txt.text = ('Proportion of max score: %s\n'
                      'Take a break now, and\n'
                      'press any key to continue.') % prop_of_possible
    intro_txt.draw()
    win.flip()
    event.waitKeys()

    directory = 'data/%s' % settings['subject']
    if not os.path.exists(directory):
        os.makedirs(directory)

    dat = pd.DataFrame(block_data)
    filename = '%s_subject%s_block%i_%ichoice.csv' % (dt, settings['subject'],
                                                      block_count, number_choices)
    dat.to_csv(os.path.join(directory, filename), sep=',', index=False)
    block_count += 1
    total_points = 0
    max_possible = 0

# moneys
# $12-18
brackets = [([0, 1./7], 12),
            ([1./7, 2./7], 13),
            ([2./7, 3./7], 14),
            ([3./7, 4./7], 15),
            ([4./7, 5./7], 16),
            ([5./7, 6./7], 17),
            ([6./7, 1], 18)]

cash_to_pay = 15
print(prop_of_possible)
for fracs, val in brackets:
    if prop_of_possible >= fracs[0] and prop_of_possible < fracs[1]:
        cash_to_pay = val

print('You made %i dollars.' % cash_to_pay)
intro_txt.text = 'You made %i dollars. Press esc to exit.' % cash_to_pay
intro_txt.draw()
win.flip()
event.waitKeys(keyList=['esc', 'escape'])


core.quit()
