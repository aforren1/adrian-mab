
# single batch (for debugging/sanity check)
import numpy as np


def bandit_mcmc(action_payoff_mat, blocks, beta=0.2, p_stay=0.75,
                random_state=None):
    if action_payoff_mat.shape[0] != blocks.shape[0]:
        raise ValueError('Mismatch between the action/payoff matrix & block labels.')

    random_state = random_state or np.random
    num_actions = action_payoff_mat.shape[1]
    qq = (1 - p_stay) / (num_actions - 1)
    p = np.full((num_actions, num_actions), qq)
    np.fill_diagonal(p, p_stay)

    actions_per_block = []
    for i in np.unique(blocks):
        sub_block_index = blocks == i
        sub_action_payoff = action_payoff_mat[sub_block_index]
        num_trials, num_actions = sub_action_payoff.shape

        selected_actions = np.zeros(num_trials, dtype=int)
        accepted_actions = np.zeros_like(selected_actions)
        value_selected_actions = np.zeros_like(selected_actions)
        value_accepted_actions = np.zeros_like(selected_actions)
        # first step
        selected_actions[0] = random_state.choice(num_actions, size=1)
        accepted_actions[0] = selected_actions[0]
        value_selected_actions[0] = sub_action_payoff[0, selected_actions[0]]
        value_accepted_actions[0] = value_selected_actions[0]

        trial_accepted = np.zeros(num_trials, dtype=bool)

        for j in range(1, num_trials):
            # pick proposed action
            # in the batched case, this ends up being awkward (.rvs only takes a 1d array)
            p_each_action = p[accepted_actions[j - 1]]
            proposal = random_state.choice(num_actions, replace=True, p=p_each_action)
            selected_actions[j] = proposal
            value_selected_actions[j] = sub_action_payoff[j, proposal]
            tmp = np.exp(beta * value_selected_actions[j]) / np.exp(beta * value_accepted_actions[j - 1])
            aa = np.minimum(1, tmp)
            trial_accepted[j] = random_state.uniform(size=1) < aa
            accepted_actions[j] = proposal if trial_accepted[j] else accepted_actions[j - 1]
            value_accepted_actions[j] = value_selected_actions[j] if trial_accepted[j] else value_accepted_actions[j - 1]
        actions_per_block.append(selected_actions)
    return np.hstack(actions_per_block)

# batch version (should get the same result with same seed & batch_size = 1)


def bandit_mcmc_batch(action_payoff_mat, blocks, beta=0.2, p_stay=0.75,
                      batch_size=1, random_state=None):
    if action_payoff_mat.shape[0] != blocks.shape[0]:
        raise ValueError('Mismatch between the action/payoff matrix & block labels.')

    random_state = random_state or np.random
    num_actions = action_payoff_mat.shape[1]
    # difference: we expect arrays of parameters
    beta = np.asanyarray(beta).reshape((-1, 1))
    p_stay = np.asanyarray(p_stay).reshape((-1, 1))
    qq = (1 - p_stay) / (num_actions - 1)
    p = np.repeat(qq, num_actions * num_actions).reshape(batch_size, num_actions, num_actions)
    # fill the diagonal of each array (probably slow, but how to improve?)
    for sub_p, sub_p_stay in zip(p, p_stay):
        np.fill_diagonal(sub_p, sub_p_stay)

    actions_per_block = []
    for i in np.unique(blocks):
        sub_block_index = blocks == i
        sub_action_payoff = action_payoff_mat[sub_block_index]
        num_trials, num_actions = sub_action_payoff.shape
        # difference: now we have 2D arrays here (batch_size x num_trials)
        selected_actions = np.zeros((batch_size, num_trials), dtype=int)
        accepted_actions = np.zeros_like(selected_actions)
        value_selected_actions = np.zeros_like(selected_actions)
        value_accepted_actions = np.zeros_like(selected_actions)
        # first step (uniform prob over all choices)
        selected_actions[:, 0] = random_state.choice(num_actions, size=batch_size)
        accepted_actions[:, 0] = selected_actions[:, 0]
        value_selected_actions[:, 0] = sub_action_payoff[0, selected_actions[:, 0]]
        value_accepted_actions[:, 0] = value_selected_actions[:, 0]

        trial_accepted = np.zeros((batch_size, num_trials), dtype=bool)
        trial_accepted[:, 0] = True
        for j in range(1, num_trials):
            # pick proposed action
            # get row per batch (i.e. should be shape (batch_size, num_choices))
            # accepted_actions used to index per dim 1 of p
            # blah, I can't figure out fancy indexing and the multinomial stuff doesn't take 2D arrays
            # https://github.com/numpy/numpy/issues/5023
            for m in range(batch_size):
                p_each_action = p[m, accepted_actions[m, j - 1]]
                proposal = random_state.choice(num_actions, replace=True, p=p_each_action)
                selected_actions[m, j] = proposal
            # try to jump back to vectorized stuff
            value_selected_actions[:, j] = sub_action_payoff[j, selected_actions[:, j]]
            tmp = np.exp(beta.T * value_selected_actions[:, j]) / np.exp(beta.T * value_accepted_actions[:, j - 1])
            aa = np.minimum(1, tmp.flatten())  # sanity check: should be shape (5,) (one per batch)
            trial_accepted[:, j] = random_state.uniform(size=batch_size) < aa
            # fill in results (check each batch for accept/reject)
            accept_inds = trial_accepted[:, j]
            reject_inds = np.logical_not(accept_inds)
            accepted_actions[accept_inds, j] = selected_actions[accept_inds, j]
            accepted_actions[reject_inds, j] = accepted_actions[reject_inds, j - 1]
            value_accepted_actions[accept_inds, j] = value_selected_actions[accept_inds, j]
            value_accepted_actions[reject_inds, j] = value_accepted_actions[reject_inds, j - 1]
        actions_per_block.append(selected_actions)
    return np.hstack(actions_per_block)


if __name__ == '__main__':
    import re
    import time

    import elfi
    import matplotlib.pyplot as plt
    import numpy as np
    import pandas as pd

    data = pd.read_csv('cleaned_data.csv', index_col=False)

    sub_100_4_choice = data.query('subject == 100 and choices == 4')
    search_dig = re.compile(r'\d+')
    reward_cols = [col for col in sub_100_4_choice if search_dig.search(col) and not sub_100_4_choice[col].isnull().values.any()]

    action_payoff_mat = sub_100_4_choice[reward_cols].values
    blocks = sub_100_4_choice['block'].values
    seed = 10
    rs = np.random.RandomState(seed=seed)

    res1 = bandit_mcmc(action_payoff_mat, blocks, random_state=rs)
    rs.seed(seed)
    res2 = bandit_mcmc_batch(action_payoff_mat, blocks, random_state=rs)

    print((res1 == res2[0]).all())
