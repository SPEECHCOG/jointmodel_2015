function tS = activetrainCMF(tS,alpha)

VQ_train = tS.VQ_train;
labels_train = tS.labels_train;

max_lag = length(tS.L);

if nargin <2
   alpha = 0.66;
end

for signal = 1:length(VQ_train)

    tag = labels_train(signal,:);
    tag(tag == 0) = [];

    seq = VQ_train{signal};

    p = testaaCMF(seq,tS,1);


    for t = 1:length(tag)
        F = zeros(max_lag,tS.alphabet_size,tS.alphabet_size);

        L = length(tS.L);
        for lag = 1:L     % Go through all lags
            for k = 1:length(seq)-tS.L(lag)
                F(lag,seq(k),seq(k+tS.L(lag))) = F(lag,seq(k),seq(k+tS.L(lag)))+p(k,tag(t));
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



    procbar(signal,length(VQ_train));

end
