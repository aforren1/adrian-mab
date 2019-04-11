import numpy as np
import scipy.stats as ss
# only intended for 1 subject/ 1 block
# simulate response, given a action-payoff matrix
# https://elfi.readthedocs.io/en/latest/usage/tutorial.html
# TODO: fit per section per subject (i.e. include all blocks for the section to get the most data)
# TODO: allow proper batching

# action_payoff_mat is 2D array of reward corresponding to an action on that trial (row=trial, col=action)
# blocks is 1D array of blocks


def bandit_mcmc(action_payoff_mat, blocks, beta=0.2, p_stay=0.75,  # our params
                batch_size=1, random_state=None):  # ELFI kwargs
    if action_payoff_mat.shape[0] != blocks.shape[0]:
        raise ValueError('Mismatch between the action/payoff matrix & block labels.')
    #
    random_state = random_state or np.random
    xx, num_actions = action_payoff_mat.shape
    beta = np.asanyarray(beta).reshape((-1, 1))
    # uniform distribution on other targets (?)
    qq = (1 - p_stay) / (num_actions - 1)
    # proposal distribution P_ij = P(a_pr = j|a_c = i)
    # p = np.full((batch_size, num_actions, num_actions), qq)
    p = np.repeat(qq, num_actions * num_actions).reshape(batch_size, num_actions, num_actions)
    i = np.eye(num_actions)
    i = np.stack([i] * batch_size, axis=0)
    p[i > 0] = np.repeat(p_stay, num_actions)

    actions = []
    for j in np.unique(blocks):
        # subset of action/payoff matrix for this block
        # this is a copy (so need to re-copy the data bac)
        subblock_idx = blocks == j
        sub_action_payoff = action_payoff_mat[subblock_idx]
        num_trials, num_actions = sub_action_payoff.shape

        selected_actions = np.zeros((batch_size, num_trials), dtype=int)
        accepted_actions = np.zeros_like(selected_actions)
        value_selected_action = np.zeros_like(selected_actions)
        value_accepted_action = np.zeros_like(selected_actions)
        selected_actions[:, 0] = random_state.choice(num_actions, size=batch_size)
        accepted_actions[:, 0] = selected_actions[:, 0]
        value_selected_action[:, 0] = sub_action_payoff[0, selected_actions[:, 0]]
        value_accepted_action[:, 0] = value_selected_action[:, 0]
        # ??
        aa = np.zeros((batch_size, num_trials))
        accepted = np.zeros((batch_size, num_trials), dtype=bool)  # whether the current step accepted or not

        for i in range(1, num_trials):
            # get the proposed action for the trial
            proposals = []
            for k in range(accepted_actions.shape[0]):
                proposals.append(np.argwhere(ss.multinomial.rvs(1, p[k, accepted_actions[k, i - 1], :]) > 0)[0][0])

            selected_actions[:, i] = proposals
            value_selected_action[:, i] = sub_action_payoff[i, proposals]
            aas = []
            for k in range(value_selected_action.shape[0]):
                aas.append(min(np.array([1]), np.exp(beta[k] * value_selected_action[k, i]) / np.exp(beta[k] * value_accepted_action[k, i - 1])))
            aas = np.array(aas).T
            accepted[:, i] = random_state.uniform(size=len(aas)) < aas
            for k in range(accepted.shape[0]):
                if accepted[k, i]:
                    accepted_actions[k, i] = proposals[k]
                    value_accepted_action[k, i] = value_selected_action[k, i]
                else:
                    accepted_actions[k, i] = accepted_actions[k, i-1]
                    value_accepted_action[k, i] = value_accepted_action[k, i-1]
        actions.append(selected_actions)

    return np.hstack(actions)
