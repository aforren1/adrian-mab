
# softmax parameters under https://www.nature.com/articles/nature04766
# supplementary materials
sigma_o = 4  # fixed by Daw 2006
lambd = .924  # decay parameter
theta = 50.5  # decay center
sigma_d = 51.3  # diffusion noise

alpha = 0  # stickiness
beta = .112  # exploration parameter

# priors (estimated??)
mu_0 = 85.7  # starting mean?
sigma2_0 = 4.61  # starting scale; TODO: why is this squared already?

for j in np.unique(blocks):

    for i in range(1, num_trials):
        # update priors
        if i == 1:
            # TODO
            pass
        else:
            pass

        # select action, do softmax

        # kalman update
