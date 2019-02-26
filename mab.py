import os
import sys
from string import ascii_lowercase
from datetime import datetime
from time import time

from collections import OrderedDict
from itertools import chain, permutations
import numpy as np
import pandas as pd
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
blocks_per_section = 4  # 4 for real
practice = 30  # 50 for real
trials = 200  # 200 for real
seeds = list(range(blocks_per_section))
seeds = [s + int(settings['subject']) for s in seeds]
print(seeds)
possible_amounts = []

blocks = []
# 4-choice
# warmup
# TODO: permute order of blocks
warmup = [(4, make_seq(filename=None, num_resp=4, num_trials=practice, seed=100))]

# match so that first subject (100) was permutation v0
permute_order = (int(settings['subject']) + 2) % 6
orderings = list(permutations([0, 1, 2]))
reordering = orderings[permute_order]

four_blocks = []
for i in seeds:
    four_blocks.append((4, make_seq(filename=None, num_resp=4, num_trials=trials, seed=i)))

# 8-choice
eight_blocks = []
for i in seeds:
    eight_blocks.append((8, make_seq(filename=None, num_resp=8, num_trials=trials, seed=i+10)))

# 26-choice
twosix_blocks = []
for i in seeds:
    twosix_blocks.append((26, make_seq(filename=None, num_resp=26, num_trials=trials, seed=i+10)))

tmp = [four_blocks, eight_blocks, twosix_blocks]
blocks = warmup + tmp[reordering[0]] + tmp[reordering[1]] + tmp[reordering[2]]

blocks = [(i, x.to_dict('records')) for i, x in blocks]
keys = {}
keys[4] = ['h', 'u', 'i', 'l']
keys[8] = ['a', 'w', 'e', 'f'] + keys[4]
keys[26] = list(ascii_lowercase)

# set up visuals
win = visual.Window(units='height', fullscr=True, allowGUI=False, waitBlanking=False)

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

wait = visual.Rect(win, width=0.4, height=0.1, pos=(0, -0.3), lineColor=None)
choice_txt = visual.TextStim(win, text='F', pos=(0, 0), alignHoriz='center',
                             alignVert='center', height=0.05, color='white')
intro_txt.draw()
win.flip()
event.waitKeys()

trial_timer = core.Clock()

total_points = 0
max_possible = 0
block_count = 0
time0 = time()

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
        choice_txt.setText(choice.upper())
        while trial_timer.getTime() <= 0.5:
            choice_txt.pos = (0.2, 0)
            choice_txt.draw()
            choice_txt.pos = (-0.2, 0)
            choice_txt.draw()
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
        feedback.draw()
        remind_txt[number_choices].draw()
        win.flip()
        # core.wait(0.2)

    prop_of_possible = round(float(total_points)/float(max_possible), 2)
    possible_amounts.append(prop_of_possible)
    intro_txt.text = ('Proportion of max score: %s\n'
                      'Take a break now.') % prop_of_possible
    intro_txt.draw()
    wait.fillColor = 'red'
    wait.draw()
    win.flip()
    core.wait(5)
    intro_txt.text = ('Proportion of max score: %s\n'
                      'Take a break now, and\n'
                      'press any key to continue.') % prop_of_possible
    intro_txt.draw()
    wait.fillColor = 'green'
    wait.draw()
    win.flip()

    directory = 'data/%s' % settings['subject']
    if not os.path.exists(directory):
        os.makedirs(directory)

    dat = pd.DataFrame(block_data)
    filename = '%s_subject%s_block%02i_%ichoice.csv' % (dt, settings['subject'],
                                                        block_count, number_choices)
    dat.to_csv(os.path.join(directory, filename), sep=',', index=False)
    block_count += 1
    total_points = 0
    max_possible = 0
    event.waitKeys()

# monies
# $12-18
brackets = [([0, 1./7], 12),
            ([1./7, 2./7], 13),
            ([2./7, 3./7], 14),
            ([3./7, 4./7], 15),
            ([4./7, 5./7], 16),
            ([5./7, 6./7], 17),
            ([6./7, 1], 18)]

cash_to_pay = 15
cash_to_pay = np.random.choice(possible_amounts)
print(possible_amounts)
print(cash_to_pay)
for fracs, val in brackets:
    if prop_of_possible >= fracs[0] and prop_of_possible < fracs[1]:
        cash_to_pay = val

time1 = np.ceil((time() - time0) / 60)
print('You made %i dollars per hour, and took %i minutes.' % (cash_to_pay, time1))
intro_txt.text = 'You made %i dollars per hour and took %i minutes.\nPress esc to exit.' % (cash_to_pay, time1)
intro_txt.draw()
win.flip()
event.waitKeys(keyList=['esc', 'escape'])


core.quit()
