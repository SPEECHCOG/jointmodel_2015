function p = testaaCMF(seq,tS,filt)

if nargin <3
    filt = 0;
end

L = length(tS.L);


p = zeros(length(seq),tS.number_of_tags);
A = 1:L;
timeinds = (1:length(seq)-tS.L(end))';

tmp = timeinds(:,ones(1,L));        % Lag-specific time indices
i1 = A(ones(1,length(seq)-L),:);    % How much shift per index?
i2 = seq(tmp);                      % Indices for each lag
i3 = seq(tmp+i1);

B3=i1 + (i2-1)*L + (i3-1)*L*tS.alphabet_size; % Indices to matrix

for tag = 1:tS.number_of_tags
    p(timeinds,tag)=sum(tS.P{tag}(B3),2);
end

p = p./L;

if(filt == 1)
    p = filter(ones(26,1)./26,1,p);
    p = [p(14:end,:);zeros(13,size(p,2))];
end
