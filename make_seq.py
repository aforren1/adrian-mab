import numpy as np
import pandas as pd


def make_seq(filename='foo.csv', num_resp=4, warmup=200, num_trials=150, seed=1):
    # 1-100, Gaussian (sigma=4)
    # t0 = 50?
    rng = np.random.RandomState(seed=seed)
    vals = [list() for i in range(num_resp)]
    for i in range(num_resp):
        # run the process for n trials, so everything's asymptotic
        mu = 50
        lam = 0.9836  # decay parameter
        sig_o = 4
        sig_d = 2.8  # decay gaussian
        theta = 50
        for j in range(warmup):
            mu = lam * mu + (1 - lam) * theta + rng.normal(0, sig_d)
        for j in range(num_trials):
            mu = lam * mu + (1 - lam) * theta + rng.normal(0, sig_d)
            new_val = round(rng.normal(mu, 4))
            new_val = max(new_val, 1)
            new_val = min(new_val, 100)
            vals[i].append(new_val)
    vals = np.transpose(np.array(vals))
    df = pd.DataFrame(vals)
    if filename:
        df.to_csv(filename, header=False, sep=',', index=False)
    return df


if __name__ == '__main__':
    import argparse
    import matplotlib.pyplot as plt

    parser = argparse.ArgumentParser()
    parser.add_argument('--filename', type=str, default='foo.csv')
    parser.add_argument('--seed', type=int, default=1)
    parser.add_argument('--trials', type=int, default=150)
    parser.add_argument('--plot', type=bool, default=False)
    args = parser.parse_args()

    x = make_seq(args.filename, num_trials=args.trials, seed=args.seed)

    if args.plot:
        plt.plot(pd.DataFrame(x))
        plt.show()
