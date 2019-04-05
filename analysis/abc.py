import re
import time

import elfi
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from models import bandit_mcmc

data = pd.read_csv('cleaned_data.csv', index_col=False)

# sub_100_block_1 = data.query('subject == 100')
# search_dig = re.compile(r'\d+')
# reward_cols = [col for col in sub_100_block_1 if search_dig.search(col) and not sub_100_block_1[col].isnull().values.any()]

# action_payoff_mat = sub_100_block_1[reward_cols]
# blocks = sub_100_block_1['block']
# # plt.plot(action_payoff_mat); plt.show()

# # TODO: better priors
# beta = elfi.Prior('beta', 0.5, 0.5)  # TODO: tend small
# p_stay = elfi.Prior('beta', 0.5, 0.5)  # TODO: tend big

# # TODO: define summary metrics
# # Adrian uses p_stick, p_same, average reward
# # https://github.com/aforren1/adrian-mab/blob/analysis/model/bandit_model_example.m

# sim = elfi.Simulator(bandit_mcmc, action_payoff_mat.values, blocks,
#                      beta, p_stay,  # params
#                      observed=sub_100_block_1['choice'].values)

# elfi.draw(sim).view()


# new scratch work

sub_100_4_choice = data.query('subject == 100 and choices == 4')
search_dig = re.compile(r'\d+')
reward_cols = [col for col in sub_100_4_choice if search_dig.search(col) and not sub_100_4_choice[col].isnull().values.any()]

action_payoff_mat = sub_100_4_choice[reward_cols]
blocks = sub_100_4_choice['block']

res = bandit_mcmc(action_payoff_mat.values, blocks.values, batch_size=1)
