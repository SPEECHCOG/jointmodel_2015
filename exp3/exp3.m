
% Test CM model in XSL experiment of Yu & Smith (2007).

clear all


addpath('../aux/');
addpath('../CMF/');
addpath('../aux/k-means/');
curdir = pwd;


experiments = [1,2,3,4,5];
n_iters = 20;       % How many iterations per experiment (default 7 to match with yurovsky data).
talker = 1;         % Talkers 1-4
cbsize = 64;        % VQ codebook size 

filename = [curdir '/data/'  sprintf('exp3_data_%d_cb%d.mat',talker,cbsize)];

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
if(exist([curdir '/data/annoinfo_smithexp.mat']))
    load([curdir '/data/annoinfo_smithexp.mat']);
else
    annoinfo = haeannotaatiot(2);
    save([curdir '/data/annoinfo_smithexp.mat'],'annoinfo');
end

annotated_bounds = annoinfo.bounds((talker-1)*2397+1:talker*2397,:);
annotated_words = annoinfo.wordtag((talker-1)*2397+1:talker*2397,:);
annotated_wordnames = annoinfo.wordtag_list;


%% Three algorithm variants: global+local competititon (CM + Heikki's mod), global only (standard CM), no competition (transition probabilities only).


variants = {'basic model','attention-constrained model'};

perf_single = cell(length(experiments),2);
correct_single_all = cell(length(experiments),2);
total_single_all = cell(length(experiments),2);

for experiment_number = 1:length(experiments)
    
    perf_single{experiment_number} = zeros(n_iters,3);
    correct_single_all{experiment_number} = zeros(n_iters,3);
    total_single_all{experiment_number} = zeros(n_iters,3);
    
    for iter = 1:n_iters    % Run through multiple iterations as the data set varies between runs (different subset, different tags, different noise)
        
        % Load experiment data
        for realwords = 0:1
            clear data_train
            while(~exist('data_train'))
                try
                    [data_train,tags_train,data_test,tags_test,taginds,train_filenames,test_filenames,testpoints,taginds_double,taginds_single] = getSmithDataset_v2(experiments(experiment_number),tags,data,filenames,tagnames,annotated_bounds,annotated_words,annotated_wordnames,iter,realwords);
                catch
                end
            end
            
            for variant = 1:2
                for tt = 1:length(testpoints)
                    
                    if(variant == 1)
                        tS = formatCMF(data_train(1:testpoints(tt)),tags_train(1:testpoints(tt),:),1:25,50,0);
                        tS = runCMF(tS); % Run CM without normalization
                    elseif(variant == 2)
                        tS = formatCMF(data_train(1:testpoints(tt)),tags_train(1:testpoints(tt),:),1:25,50,0);
                        tS = activetrainCMF_referent_smith(tS);
                    end
                    
                    % Measure performance at different points in time
                    
                    wrong_single = 0;
                    correct_single = 0;
                    
                    for k = 1:length(data_test)
                        truetags = tags_test(k,1);
                        
                        truetags_single = intersect(truetags,taginds_single);
                        seq = data_test{k};
                        
                        p = testaaCMF(seq,tS,1);
                                                
                        
                        %% Single-word evaluation starts
                        if(length(truetags_single) == 1)
                            
                            refset = tags_test(k,1:4);
                            
                            p_tot = sum(p(:,refset))./size(p,1);
                            
                            if(max(p_tot) > 0)
                                [maxprob,hypo] = max(p_tot);
                            else
                                hypo = randi(4,1);
                            end
                            
                            if(hypo == 1)
                                correct_single = correct_single+1;
                            else
                                wrong_single = wrong_single+1;
                            end
                            
                        end
                        
                        
                    end
                    
                    % Evaluate performance using only the selected word tokens
                    perf_single{experiment_number,realwords+1}(iter,variant,tt) = correct_single./(correct_single+wrong_single);
                    fprintf('Single correct: %0.2f%%.\n',perf_single{experiment_number,realwords+1}(iter,variant,tt)*100);
                    
                    correct_single_all{experiment_number,realwords+1}(iter,variant,tt) = correct_single;
                    total_single_all{experiment_number,realwords+1}(iter,variant,tt) = correct_single+wrong_single;
                    
                end
            end
        end
    end
    
    % Overall results
    
    mean_single = mean(perf_single{experiment_number,1});        
    std_single = std(perf_single{experiment_number,1});
    
    mean_single_real = mean(perf_single{experiment_number,2});        
    std_single_real = std(perf_single{experiment_number,2});
    

    set(0,'defaultaxesfontsize',20);
    set(0,'defaulttextfontsize',20);
           
    for variant = 1:2
        fprintf('TALKER %d. EXP%d, %s: Single: %0.1f, (+-%0.1f).\n',talker,experiment_number,variants{variant},mean_single(variant).*100,std_single(variant).*100);
    end

end

chancelevs = [25,25,25];
smithmean_xp1 = [0.8851 0.759 0.527 0.557 0.5958].*100;
smithstd_xp1 = [0.1441 0.1959 0.1689 0.19 0.23].*100./2;

mexp1 = zeros(3,2);
sexp1 = zeros(3,2);


normalizer = sqrt(n_iters);

for experiment_number = 1:5
    tmp =  mean(perf_single{experiment_number,1});
    tmp2 =  std(perf_single{experiment_number,1});
    for variant = 1:2
        mexp1(experiment_number,variant) = tmp(variant).*100;
        sexp1(experiment_number,variant) = tmp2(variant)./normalizer.*100;
    end    
end


mexp2 = zeros(3,2);
sexp2 = zeros(3,2);


normalizer = sqrt(n_iters);

for experiment_number = 1:5
    tmp =  mean(perf_single{experiment_number,2});
    tmp2 =  std(perf_single{experiment_number,2});
    for variant = 1:2
        mexp2(experiment_number,variant) = tmp(variant).*100;
        sexp2(experiment_number,variant) = tmp2(variant)./normalizer.*100;
    end    
end


% Plot

bardata = [mexp1(:,1) mexp2(:,1) mexp1(:,2:end) mexp2(:,2:end) smithmean_xp1'];

h = figure('Position',[500 300 1400 800]);
subplot(2,1,1);

bar(bardata(:,[1 2 5]));hold on;
legend({'no acoustic variation','with acoustic variation','human data'});
title('basic model')
colormap([0.3 0.3 0.3;0.6 0.6 0.6;89/256 255/256 0.3])

drawstds(h,(1:6)-0.225,mexp1(:,1),sexp1(:,1),0.04,2,'red');
drawstds(h,(1:6),mexp2(:,1),sexp2(:,1),0.04,2,'red');
drawstds(h,(1:6)+0.225,smithmean_xp1,smithstd_xp1,0.04,2,'red');
ylabel('% correct');
set(gca,'XTick',[]);
line([0 6.5],[25 25],'LineWidth',2,'Color','black','LineStyle','--');
grid;
xlim([0.5 5.5])
subplot(2,1,2);
bar(bardata(:,[3 4 5]));hold on;
title('selective attention variant')
colormap([0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3])
legend({'no acoustic variation','with acoustic variation','human data'});
drawstds(h,(1:6)-0.225,mexp1(:,2),sexp1(:,2),0.04,2,'red');
drawstds(h,(1:6),mexp2(:,2),sexp2(:,2),0.04,2,'red');
drawstds(h,(1:6)+0.225,smithmean_xp1,smithstd_xp1,0.04,2,'red');

ylabel('% correct');
line([0 6.5],[25 25],'LineWidth',2,'Color','black','LineStyle','--');
set(gca,'XTickLabel',{});
xlim([0.5 5.5])

text(1,-8,sprintf('2 X 2, 18 words\n6 repetitions'),'HorizontalAlignment','center')
text(2,-8,sprintf('3 X 3, 18 words\n6 repetitions'),'HorizontalAlignment','center')
text(3,-8,sprintf('4 X 4, 18 words\n6 repetitions'),'HorizontalAlignment','center')
text(4,-8,sprintf('4 X 4, 9 words\n8 repetitions'),'HorizontalAlignment','center')
text(5,-8,sprintf('4 X 4, 9 words\n12 repetitions'),'HorizontalAlignment','center')
grid;
