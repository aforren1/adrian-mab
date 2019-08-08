function dataAv = average_data(data)
% compute average across runs and participants

dataAv_blocks.p_stick = squeeze(nanmean(data.p_stick,3));
dataAv_blocks.ar = squeeze(nanmean(data.ar,3));
%dataAv_blocks.r = squeeze(nanmean(data.r,3));

dataAv.p_stick = squeeze(nanmean(dataAv_blocks.p_stick,1));
dataAv.ar = squeeze(nanmean(dataAv_blocks.ar,1));
%dataAv.r = squeeze(nanmean(dataAv_blocks.r,1));

