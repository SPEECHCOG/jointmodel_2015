function tS = activetrainCMF_referent_smith(tS)


train_labels = tS.train_labels;
tags_train = tS.tags_train;

max_lag = length(tS.L);

for signal = 1:length(train_labels)

    tag = tags_train(signal,:);
    tag(tag == 0) = [];

    seq = train_labels{signal};

    p = testaaCMF(seq,tS,1);

    p = p+rand(size(p)).*0.000001; % Add small noise floor to have random referent for zero-models

    pcum = p(:,tag);

    % Perform low-pass filtering of the probabilities
    filtlen = 24;
    pcum = filter(ones(filtlen,1)./filtlen,1,pcum);

    shiftsize = filtlen/2;
    pcum = [pcum(shiftsize:end,:);zeros(shiftsize,size(pcum,2))];

    updatew = zeros(size(p,1),length(tag));
    for k = 1:size(pcum,1)

        vals = pcum(k,:);
        [updates,winner] = sort(vals,'descend');
        for j = 1:min(1,length(updates))
            updatew(k,winner(j)) = 1;
        end
    end


    for t = 1:length(tag)
        F = zeros(max_lag,tS.alphabet_size,tS.alphabet_size);
        L = length(tS.L);
        for lag = 1:L     % Go through all lags
            for k = 1:length(seq)-tS.L(lag)
                F(lag,seq(k),seq(k+tS.L(lag))) = F(lag,seq(k),seq(k+tS.L(lag)))+updatew(k,t);
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

end
