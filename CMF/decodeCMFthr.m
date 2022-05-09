function [class,loc] = decodeCMFthr(p,thr)

loc = [];
class = [];

p = p';

thr_zscore = thr.*std(max(p))+mean(max(p));

[pks,locs] = findpeaks(max(p),'MINPEAKDISTANCE',1);

[pks,ind]=sort(pks,'descend');

ind(pks < thr_zscore) = [];

locs=locs(ind); % Piikkien sijainnit j?rejstettyn? suurimmasta pienimp??n
ind=1;
class=[];
maxval = [];
for j=1:length(locs) % K?yd??n l?pi maksimit
    [val,M]=max(p(:,locs(j)));  % Katsotaan maksimin arvo pisteess? kaikille tageille
    if ~any(class==M) % Jos ei ole jo joukossa, lis?t??n M joukkoon
        class(ind)=M;
        maxval(ind) = val;
        loc(ind) = locs(j);
        ind=ind+1;
    elseif(maxval(class == M) < val)
        maxval(class == M) = val;
        loc(class == M) = locs(j);
    end
end
