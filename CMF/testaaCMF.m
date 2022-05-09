function p = testaaCMF(seq,tS,filt)

if nargin <3
    filt = 0;
end

L = length(tS.L);

cons = 1/tS.number_of_tags;

p = zeros(length(seq),tS.number_of_tags);
A = 1:L;
timeinds = (1:length(seq)-tS.L(end))';

tmp = timeinds(:,ones(1,L));         % Aikaindeksit joka lagille
i1 = A(ones(1,length(seq)-L),:);    % Paljonko shiftataan indeksi?
i2 = seq(tmp);                      % Sekvenssiindeksit joka lagille
i3 = seq(tmp+i1);

B3=i1 + (i2-1)*L + (i3-1)*L*tS.alphabet_size; % Indeksit joilla haetaan datapisteet matriisista

for tag = 1:tS.number_of_tags
    p(timeinds,tag)=sum(tS.P{tag}(B3),2);
end

p = p./L;

if(filt == 1)
    p = filter(ones(26,1)./26,1,p);
    p = [p(14:end,:);zeros(13,size(p,2))];
end
