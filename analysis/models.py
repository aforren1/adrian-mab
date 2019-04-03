import numpy as np
import scipy.stats as ss
# only intended for 1 subject/ 1 block
# simulate response, given a action-payoff matrix
# https://elfi.readthedocs.io/en/latest/usage/tutorial.html
# TODO: fit per section per subject (i.e. include all blocks for the section to get the most data)
# TODO: allow proper batching


def bandit_mcmc(action_payoff_mat, beta=0.08, p_stay=0.9,  # our params
                batch_size=1, random_state=None):  # ELFI kwargs
    beta = np.asanyarray(beta).reshape((-1, 1))
    p_stay = np.asanyarray(p_stay).reshape((-1, 1))
    random_state = random_state or np.random
    num_trials, num_actions = action_payoff_mat.shape

    selected_actions = np.zeros(num_trials, dtype=int)
    accepted_actions = np.zeros_like(selected_actions)
    value_selected_action = np.zeros_like(selected_actions)
    value_accepted_action = np.zeros_like(selected_actions)
    selected_actions[0] = random_state.choice(num_actions)
    accepted_actions[0] = selected_actions[0]
    value_selected_action[0] = action_payoff_mat[0, int(selected_actions[0])]
    value_accepted_action[0] = value_selected_action[0]
    # ??
    aa = np.zeros(num_trials)
    accepted = np.zeros(num_trials, dtype=bool)  # whether the current step accepted or not

    # uniform distribution on other targets (?)
    qq = (1 - p_stay) / (num_actions - 1)

    # proposal distribution P_ij = P(a_pr = j|a_c = i)
    p = np.full((num_actions, num_actions), qq)
    p[np.eye(num_actions) > 0] = p_stay[0][0]
    # for j in unique(blocks):
    for i in range(1, num_trials):
        a_proposal = np.argwhere(ss.multinomial.rvs(1, p[accepted_actions[i - 1], :]) > 0)[0][0]
        selected_actions[i] = a_proposal
        value_selected_action[i] = action_payoff_mat[i, a_proposal]
        aa[i] = min(1, np.exp(beta * value_selected_action[i]) / np.exp(beta * value_selected_action[i - 1]))
        accepted[i] = random_state.uniform() < aa[i]

        if accepted[i]:
            accepted_actions[i] = a_proposal
            value_accepted_action[i] = value_selected_action[i]
        else:
            accepted_actions[i] = accepted_actions[i - 1]
            value_accepted_action[i] = value_accepted_action[i - 1]

    return selected_actions, value_accepted_action
