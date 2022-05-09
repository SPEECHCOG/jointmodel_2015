function [class,loc] = decodeCMF(p,N)

p = p';
[pks,locs] = findpeaks(max(p),'MINPEAKDISTANCE',1);
[~,ind]=sort(pks,'descend');
locs=locs(ind);
ind=1;
class=[];
maxval = [];
for j=1:length(locs)
    [val,M]=max(p(:,locs(j)));
    if ~any(class==M) %
        class(ind)=M;
        maxval(ind) = val;
        loc(ind) = locs(j);
        ind=ind+1;
        if ind==N+1
            break
        end
    elseif(maxval(class == M) < val)
        maxval(class == M) = val;
        loc(class == M) = locs(j);
    end
end