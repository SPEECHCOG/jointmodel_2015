function [class,loc] = decodeCMF(p,N)

               p = p';
[pks,locs] = findpeaks(max(p),'MINPEAKDISTANCE',1); % Tsekkaa t‰m‰ funktio
[~,ind]=sort(pks,'descend');
locs=locs(ind); % Piikkien sijainnit j‰rejstettyn‰ suurimmasta pienimp‰‰n
ind=1;
class=[];
maxval = [];
for j=1:length(locs) % K‰yd‰‰n l‰pi maksimit
    [val,M]=max(p(:,locs(j)));  % Katsotaan maksimin arvo pisteess‰ kaikille tageille
    if ~any(class==M) % Jos ei ole jo joukossa, lis‰t‰‰n M joukkoon
        class(ind)=M;
        maxval(ind) = val;
        loc(ind) = locs(j);
        ind=ind+1;
        if ind==N+1
            break
        end;
    elseif(maxval(class == M) < val)        
        maxval(class == M) = val;        
        loc(class == M) = locs(j);
    end;
end;