% A demo for basic functionality of the CM model

% Load data (vector quantized MFCCs and visual labels for CAREGIVER Y2 UK
% corpus). VQ codebook size is 64 unique elementary sounds.

load all_talkers_cg_cb64.mat


VQ = data;      % All VQ indices (i.e., the speech data)
labels = tags;  % all visual tags (i.e., the concurrent referents)

% select 2000 utterances for training 
VQ_train = VQ(1:2000);    
labels_train = labels(1:2000,:);

....and 200 for testing 
VQ_test = VQ(2001:2200);  
labels_test = labels(2001:2200,:);

lags = 1:15; % model transitions at lags 1...15 


% Initialize model
tS = formatCMF(VQ_train,labels_train,lags,50,0);

% Train model
tS = runCMF(tS);

% Plot activations on the held-out test data
h = figure(1);clf;
for k = 1:length(VQ_test)

    % get moment-by-moment probabilities of each visual referent, given the VQ speech
    p = testaaCMF(VQ_test{k},tS,1); 

    % plot activations
    h2 = plot(p,'LineWidth',2);
    xlabel('frame index');
    ylabel('activation');

    % Add legend for top 4 activations (based on peak value)
    tmp = max(p);
    [~,b] = sort(tmp,'descend');
    
    for j = 1:length(h2)
        if(~sum(b(1:4) == j))
            h2(j).Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
    end
    legend(tagnames(b(1:4)))     
    
    % Add ground truth visual referents to the plot title
    tmp = labels_test(k,:);
    tmp(tmp == 0) = [];
    s = '';
    for j = 1:length(tmp)
        s = [s sprintf( '%s ',tagnames{tmp(j)})];
    end    
    title(sprintf('ground truth: %s',s));

    pause;

end