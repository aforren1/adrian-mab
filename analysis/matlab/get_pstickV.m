function p_stick = get_pstickV(data)
% vectorized version of get_pstick
Nsamp = size(data.r,1);
bins = [0:10:100];
zz = zeros(Nsamp,1);

stick = [data.a zz] == [zz data.a];
for b=1:length(bins)-1
    inbin = [zz data.r>bins(b) & data.r<bins(b+1)];
    inbin(:,end) = 0;
    p_stick(b) = nanmean(sum(inbin.*stick,2)./sum(inbin,2));
end

