function tS = activetrainCMF_referent(tS,noiselevel)

if nargin<2
    noiselevel = 0;
end

train_labels = tS.train_labels;
tags_train = tS.tags_train;

max_lag = length(tS.L);

for signal = 1:length(train_labels)

    tag = tags_train(signal,:);
    tag(tag == 0) = [];

    seq = train_labels{signal};

    p = testaaCMF(seq,tS,0);

    tagprobs = sum(p(:,tag))./size(p,1);


    if(sum(tagprobs > 0))
        [daa,tmp] = sort(tagprobs,'ascend');
        tag = tag(tmp(1:1));
    else
        tag = tag(randi(length(tag)));
    end

    for t = 1:length(tag)
        F = zeros(max_lag,tS.alphabet_size,tS.alphabet_size);

        L = length(tS.L);
        for lag = 1:L     % Go through all lags
            for k = 1:length(seq)-tS.L(lag)
                F(lag,seq(k),seq(k+tS.L(lag))) = F(lag,seq(k),seq(k+tS.L(lag)))+1;
            end
        end

        tS.T{tag(t)} = tS.T{tag(t)}+F;
    end




    for t=1:tS.number_of_tags
        S=squeeze((sum(tS.T{t},3)));
        tS.P{t}=bsxfun(@rdivide,tS.T{t},S);
        tS.P{t}(isnan(tS.P{t}))=0;
    end


    sum_mat=zeros(max_lag,tS.alphabet_size,tS.alphabet_size);

    for t=1:tS.number_of_tags
        sum_mat=sum_mat+tS.P{t};
    end

    for t=1:tS.number_of_tags
        tS.P{t}=tS.P{t}./sum_mat;
        tS.P{t}(isnan(tS.P{t}))=0;
    end


    procbar(signal,length(train_labels));

end
