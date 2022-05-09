%function wordlearningexps_final_with_noise

clear all

experiments = 1;    % Which experiments to run?
talker = 1;         % Talkers 1-4
cbsize = 64;        % VQ codebook size


curdir = pwd;

filename = [curdir sprintf('results/yurovsky_data_%d_cb%d.mat',talker,cbsize)];

% Get features and vector quantize (or load from file if already exists).
if(~exist(filename))
    [filenames,~,tags,~,tagnames,anno_train,anno_test] = definedataset(5,2,talker); % loads caregiver Y2 data
    
    F_train = getMFCCs(filenames,1,'white',1000); % Gets MFCC features
    
    cb = createCodebook(F_train,cbsize,10000); % Makes codebook
    data = runVQ(F_train,cb,1); % Quantizes data
    
    save(filename,'data','tagnames','tags','filenames');    
else
    load(filename);
end

% Get annotation for word boundaries
if(exist([curdir '/data/annoinfo.mat']))
    load([curdir '/data/annoinfo.mat']);
else    
    annoinfo = haeannotaatiot(2);
    save([curdir '/data/annoinfo.mat'],'annoinfo');
end

annotated_bounds = annoinfo.bounds((talker-1)*2397+1:talker*2397,:);
annotated_words = annoinfo.wordtag((talker-1)*2397+1:talker*2397,:);
annotated_wordnames = annoinfo.wordtag_list;


%% Three algorithm variants: global+local competititon (CM + Heikki's mod), global only (standard CM), no competition (transition probabilities only).

variants = {'basic model','attention-constrained'};

perf = cell(length(experiments),1);
SEG = cell(length(experiments),1);
SEG_CORRECT = cell(length(experiments),1);
SEGLEN = cell(length(experiments),1);

perf_con = {};
perf_basic = {};
indices_con = {};


noiselevels = [0 0.5];

n_iters = 50;

tagcounts = zeros(n_iters,50);

for iter = 1:n_iters    % Run through multiple iterations as the data set varies between runs (different subset, different tags, different noise)
    % Load experiment data
    [data_train,tags_train,data_test,tags_test,taginds,train_filenames,test_filenames,testpoints,testinds]  = getExperimentData_wordlearningexp_final_v2(1,tags,data,filenames,tagnames,0);
    for k = 1:50
        tagcounts(iter,k) = sum(tags_train(:)== k);
    end    
end


   