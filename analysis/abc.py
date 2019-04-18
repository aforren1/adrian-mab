import re
import time

import elfi
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from models import bandit_mcmc

data = pd.read_csv('cleaned_data.csv', index_col=False)

sub_100_4_choice = data.query('subject == 100 and choices == 4')
search_dig = re.compile(r'\d+')
reward_cols = [col for col in sub_100_4_choice if search_dig.search(col) and not sub_100_4_choice[col].isnull().values.any()]

action_payoff_mat = sub_100_4_choice[reward_cols].values
blocks = sub_100_4_choice['block'].values

res = bandit_mcmc(action_payoff_mat, blocks, batch_size=2)

# what are beta's actual bounds? seems like [0, inf)?
# seems like that's the case
beta = elfi.Prior('beta', 0.7, 0.9)
# p_stay should be [0, 1]
p_stay = elfi.Prior('beta', 0.9, 0.7)

sim = elfi.Simulator(bandit_mcmc, action_payoff_mat, blocks,
                     beta, p_stay, observed=sub_100_4_choice['choice'].values[np.newaxis, :])


# best possible value
best_reward = np.amax(action_payoff_mat, axis=1)
# index of best value (i.e. action)
best_action = np.argmax(action_payoff_mat, axis=1)

action_payoff_mat[np.arange(len(action_payoff_mat)), res[0]]


# plt.plot(np.cumsum(best_reward))
# plt.plot(np.cumsum(sub_100_4_choice['points'].values))
# # from one batch
# plt.plot(np.cumsum(action_payoff_mat.values[np.arange(len(action_payoff_mat)), res[0]]))
# plt.show()

# np.mean(np.diff(best_action) == 0)


def stickiness(actions, lag=1):
    return np.mean(np.diff(actions, n=lag, axis=1) == 0, axis=1)


def average_reward(actions, action_payoff_mat=None):
    # average across all blocks
    return np.mean(action_payoff_mat[np.arange(len(action_payoff_mat)), actions])/100


stickiness(best_action[np.newaxis, :])
# probability of staying on the current action (regardless of reward)
# at lags of 1 and 2
S1 = elfi.Summary(stickiness, sim, 1)
S2 = elfi.Summary(stickiness, sim, 2)
S3 = elfi.Summary(average_reward, action_payoff_mat)

d = elfi.Distance('euclidean', S1, S2, S3)
# elfi.draw(d).view()
elfi.set_client('multiprocessing')
elfi.set_client(elfi.clients.multiprocessing.Client(num_processes=3))
smc = elfi.SMC(d, batch_size=10000, seed=1)
res = smc.sample(100, [0.7, 0.2, 0.01])
# rej = elfi.Rejection(d, batch_size=100, seed=1)
# res = rej.sample(1000, quantile=0.01)  # , vis=dict(xlim=[-1, 1], ylim=[-1, 1]))
print(res.summary())
res.plot_pairs()
plt.show()
