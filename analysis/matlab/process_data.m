function data = process_data(data)
% perform analyses on bandit data

data.r_av = nanmean(data.r,1);
[data.p_stick data.N_rwd] = get_pstick(data);
data.ar = nanmean(get_psame(data.a),1);