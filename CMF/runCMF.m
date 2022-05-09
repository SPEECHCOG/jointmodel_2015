function tS = runCMF(tS,nonorm)

if nargin <2
    nonorm = 0;
end

train_labels = tS.train_labels;
tags_train = tS.tags_train;

max_lag = length(tS.L);


%% Training if weights for each model at each moment of time exists
if(isfield(tS,'W'))


    for signal = 1:length(train_labels)

        tag = tags_train(signal,:);
        tag(tag == 0) = [];

        seq = train_labels{signal};

        for t = 1:length(tag)
            F = zeros(max_lag,tS.alphabet_size,tS.alphabet_size);
            weights = tS.W{signal}(:,tag(t));

            L = length(tS.L);
            for lag = 1:L     % Go through all lags
                for k = 1:length(seq)-tS.L(lag)
                    F(lag,seq(k),seq(k+tS.L(lag))) = F(lag,seq(k),seq(k+tS.L(lag)))+weights(k);
                end
            end

            tS.T{tag(t)} = tS.T{tag(t)}+F;

        end
    end


    %% Normal training
else

    for signal = 1:length(train_labels)

        tag = tags_train(signal,:);
        tag(tag == 0) = [];

        seq = train_labels{signal};

        F = zeros(max_lag,tS.alphabet_size,tS.alphabet_size);

        L = length(tS.L);
        for lag = 1:L     % Go through all lags
            for k = 1:length(seq)-tS.L(lag)
                F(lag,seq(k),seq(k+tS.L(lag))) = F(lag,seq(k),seq(k+tS.L(lag)))+1;
            end
        end

        for t = 1:length(tag)
            tS.T{tag(t)} = tS.T{tag(t)}+F;
        end
    end
end


for t=1:tS.number_of_tags
    S=squeeze((sum(tS.T{t},3)));
    tS.P{t}=bsxfun(@rdivide,tS.T{t},S);
    tS.P{t}(isnan(tS.P{t}))=0;
end



if(nonorm == 0)

    sum_mat=zeros(max_lag,tS.alphabet_size,tS.alphabet_size);

    for t=1:tS.number_of_tags
        sum_mat=sum_mat+tS.P{t};
    end;

    for t=1:tS.number_of_tags
        tS.P{t}=tS.P{t}./sum_mat;
        tS.P{t}(isnan(tS.P{t}))=0;
    end
end
