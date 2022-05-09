function tS = formatCMF(VQ_train,labels_train,lags,maxtag,random)
% function tS = formatCMF(VQ_train,labels_train,lags,maxtag,random)
% 
% Initializes CMF model before training.

tS.L = lags; % lags to model

tS.VQ_train = VQ_train;
tS.labels_train = labels_train;

tS.alphabet_size = max(cellfun(@(x) max(x), VQ_train));


tS.number_of_tags = maxtag;

tS.T = cell(tS.number_of_tags,1);
tS.P = cell(tS.number_of_tags,1);
if nargin <5 || random == 0
    for tag = 1:tS.number_of_tags
        tS.T{tag} = zeros(length(tS.L),tS.alphabet_size,tS.alphabet_size);
        tS.P{tag} = zeros(length(tS.L),tS.alphabet_size,tS.alphabet_size);
    end
else
    for tag = 1:tS.number_of_tags
        tS.T{tag} = rand(length(tS.L),tS.alphabet_size,tS.alphabet_size);
        tS.P{tag} = rand(length(tS.L),tS.alphabet_size,tS.alphabet_size);
    end

    for t=1:tS.number_of_tags
        S=squeeze((sum(tS.T{t},3)));
        tS.P{t}=bsxfun(@rdivide,tS.T{t},S);
        tS.P{t}(isnan(tS.P{t}))=0;
    end

    max_lag = length(tS.L);
    sum_mat=zeros(max_lag,tS.alphabet_size,tS.alphabet_size);

    for t=1:tS.number_of_tags
        sum_mat=sum_mat+tS.P{t};
    end

    for t=1:tS.number_of_tags
        tS.P{t}=tS.P{t}./sum_mat;
        tS.P{t}(isnan(tS.P{t}))=0;
    end

    tS.T{tag} = zeros(length(tS.L),tS.alphabet_size,tS.alphabet_size);
end
