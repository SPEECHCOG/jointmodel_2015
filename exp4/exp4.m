
clear all


curdir = pwd;

experiments = [1,2,3];
n_iters = 20;       % How many iterations per experiment (20 in paper)
talker = 1;         % Talkers 1-4
cbsize = 64;        % VQ codebook size (64 in paper)


filename = [curdir '/data/' sprintf('yurovsky_data_%d_cb%d.mat',talker,cbsize)];

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

%% Datasetit

%% Three algorithm variants: global+local competititon (CM + Heikki's mod), global only (standard CM), no competition (transition probabilities only).

%% Experiment 1: Yurovsky xp 1

variants = {'basic model','attention-constrained model'};

perf_single = cell(length(experiments),1);
perf_either = cell(length(experiments),1);
perf_both = cell(length(experiments),1);
correct_single_all = cell(length(experiments),1);
total_single_all = cell(length(experiments),1);
correct_either_all = cell(length(experiments),1);
correct_both_all = cell(length(experiments),1);
total_double_all = cell(length(experiments),1);
   
correct_single_real = cell(length(experiments),1);
correct_both_real = cell(length(experiments),1);
correct_either_real = cell(length(experiments),1);

perf_single_real = cell(length(experiments),1);
perf_either_real = cell(length(experiments),1);
perf_both_real = cell(length(experiments),1);

for experiment_number = 1:length(experiments)
    
    perf_single{experiment_number} = zeros(n_iters,3);
    perf_either{experiment_number} = zeros(n_iters,3);
    perf_both{experiment_number} = zeros(n_iters,3);
    correct_both_all{experiment_number} = zeros(n_iters,3);
    correct_either_all{experiment_number} = zeros(n_iters,3);
    correct_single_all{experiment_number} = zeros(n_iters,3);
    total_single_all{experiment_number} = zeros(n_iters,3);
    total_double_all{experiment_number} = zeros(n_iters,3);
    
    for iter = 1:n_iters    % Run through multiple iterations as the data set varies between runs (different subset, different tags, different noise)
        
        % Load experiment data
        for realwords = 0:1
        clear data_train
        while(~exist('data_train'))
            try
                [data_train,tags_train,data_test,tags_test,taginds,train_filenames,test_filenames,testpoints,taginds_double,taginds_single] = getYurovskyDataset(experiments(experiment_number),tags,data,filenames,tagnames,annotated_bounds,annotated_words,annotated_wordnames,iter,realwords);
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
                    %tS = activetrainCMF_referent(tS); 
                end
                
                % Measure performance at different points in time
                
                wrong_single = 0;
                correct_single = 0;
                correct_either = 0;
                correct_both = 0;
                total_double_signals = 0;
                
                for k = 1:length(data_test)
                    truetags = tags_test(k,1);
                    
                    truetags_single = intersect(truetags,taginds_single);
                    truetags_double = intersect(truetags,taginds_double(:,1));
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
                        
                        %% Single-word evaluation ends
                                                
                        %% Double-word evaluation starts
                    elseif(length(truetags_double) == 1)% If contains a double word

                        refset = tags_test(k,1:4);
                        
                        p_tot = sum(p(:,refset))./size(p,1);
                        
                        [prob,hypo] = sort(p_tot,'descend');
                        
                        if(prob(2) > 0)
                            hypo = hypo(1:2);
                        elseif(prob(1) > 0)
                            
                            hypo = [hypo(1) hypo(randi(3)+1)];
                        else
                            hypo = randi(4,1,2);
                        end
                        
                        if(length(intersect(hypo(1),1:2)) > 0)
                            correct_either = correct_either+1;
                        end
                        if(length(intersect(hypo,1:2)) == 2)
                            correct_both = correct_both+1;
                        end
                        total_double_signals = total_double_signals + 1;
                    end
                    
                    %% Double-word evaluation ends
                    
                end
                
                % Evaluate performance using only the selected word tokens
                perf_single{experiment_number,realwords+1}(iter,variant,tt) = correct_single./(correct_single+wrong_single);
                fprintf('Single correct: %0.2f%%.\n',perf_single{experiment_number,realwords+1}(iter,variant,tt)*100);
                
                fprintf('Both correct: %0.2f%%.\n',correct_both./total_double_signals.*100);
                fprintf('Either correct: %0.2f%%.\n',correct_either./total_double_signals.*100);
                perf_both{experiment_number,realwords+1}(iter,variant,tt) = correct_both./total_double_signals;
                perf_either{experiment_number,realwords+1}(iter,variant,tt) = correct_either./total_double_signals;
                
                correct_single_all{experiment_number,realwords+1}(iter,variant,tt) = correct_single;
                total_single_all{experiment_number,realwords+1}(iter,variant,tt) = correct_single+wrong_single;
                
                correct_either_all{experiment_number,realwords+1}(iter,variant,tt) = correct_either;
                correct_both_all{experiment_number,realwords+1}(iter,variant,tt) = correct_both;
                
                total_double_all{experiment_number,realwords+1}(iter,variant,tt) = total_double_signals;
                
            end
        end
        end
    end
    
    % Overall results
    
    mean_single = mean(perf_single{experiment_number,realwords+1});
    mean_correct_both = mean(perf_both{experiment_number,realwords+1});
    mean_correct_either = mean(perf_either{experiment_number,realwords+1});
    
    std_single = std(perf_single{experiment_number,realwords+1});
    std_correct_both = std(perf_both{experiment_number,realwords+1});
    std_correct_either = std(perf_either{experiment_number,realwords+1});
    
    results = [mean_single;mean_correct_either;mean_correct_both].*100;
    result_devs = [std_single;std_correct_either;std_correct_both].*100;
    
    chancelevs = [25,50,16.67];

    set(0,'defaultaxesfontsize',20);
    set(0,'defaulttextfontsize',20);
    
    se_factor_yu = sqrt(48);
    se_factor = sqrt(n_iters);
    
    yuvmean_xp1 = [0.454 0.698 0.301].*100;
    yuvstd_xp1 = [0.264 0.210 0.146].*100./se_factor_yu;
    yuvmean_xp2 = [0.4 0.58 0.24].*100;
    yuvstd_xp2 = [0.247 0.277 0.203].*100./se_factor_yu;
    yuvmean_xp3 = [0.45 0.73 0.40].*100;
    yuvstd_xp3 = [0.30 0.24 0.30].*100./se_factor_yu;
    
    
    for variant = 1:2
        fprintf('TALKER %d. EXP%d, %s: Single: %0.1f, (+-%0.1f), either: %0.1f, (+-%0.1f), both: %0.1f, (+-%0.1f).\n',talker,experiment_number,variants{variant},mean_single(variant).*100,std_single(variant).*100,mean_correct_either(variant).*100,std_correct_either(variant).*100,mean_correct_both(variant).*100,std_correct_both(variant).*100);
    end
    
    % Make result matrix
    
    % basic, variant x single either both + stds
    
    resultmatrix = zeros(2,6);
    for variant = 1:2
    resultmatrix(variant,1) = mean_single(variant).*100;
    resultmatrix(variant,2) = std_single(variant).*100;
    resultmatrix(variant,3) = mean_correct_either(variant).*100;
    resultmatrix(variant,4) = std_correct_either(variant).*100;
    resultmatrix(variant,5) = mean_correct_both(variant).*100;
    resultmatrix(variant,6) = std_correct_both(variant).*100;
    end
        
    filename = [curdir '/results/' sprintf('resultmatrix_talker%d_exp%d_cbsize%d.mat',talker,experiments(experiment_number),cbsize)];
     
    save(filename,'resultmatrix');
        
    h = figure('Position',[500 300 1400 400]);
    clf;
    
    subplot(1,3,1);
    if(experiments(experiment_number) == 1)
        bardata = [results(:,1,end) results(:,2,end) yuvmean_xp1'];
    elseif(experiments(experiment_number) == 2)
        bardata = [results(:,1,end) results(:,2,end) yuvmean_xp2'];
    elseif(experiments(experiment_number) == 3)
        bardata = [results(:,1,end) results(:,2,end)  yuvmean_xp3'];
    end
    bar(bardata);
    colormap([0.6 0.6 0.6;0.3 0.3 0.3;0 0 0])
    
    
    drawstds(h,(1:3)-0.22,results(:,1,end),result_devs(:,1,end)./se_factor,0.1,2,'red');
    drawstds(h,(1:3),results(:,2,end),result_devs(:,2,end)./se_factor,0.1,2,'red');
    if(experiments(experiment_number) == 1)
        drawstds(h,(1:3)+0.22,yuvmean_xp1,yuvstd_xp1,0.1,3,'red');
    elseif(experiments(experiment_number) == 2)
        drawstds(h,(1:3)+0.22,yuvmean_xp2,yuvstd_xp2,0.1,3,'red');
    elseif(experiments(experiment_number) == 3)
        drawstds(h,(1:3)+0.22,yuvmean_xp3,yuvstd_xp3,0.1,3,'red');
    end
    
    grid;
    set(gca,'XTickLabel',{'single','either','both'});
    ylabel('% correct');
    %title(sprintf('%s',experiments(experiment_number),variants{variant}));
    title('all results');
    line([0.5 1.5],[chancelevs(1) chancelevs(1)],'LineWidth',2,'Color','black','LineStyle','--');
    line([1.5 2.5],[chancelevs(2) chancelevs(2)],'LineWidth',2,'Color','black','LineStyle','--');
    line([2.5 3.5],[chancelevs(3) chancelevs(3)],'LineWidth',2,'Color','black','LineStyle','--');
    ylim([0 100]);
        
    
    for realwords = 0:1
        for iter = 1:n_iters
            for variant = 1:2
                for tt = 1:length(testpoints)
                    [correct_single_real{experiment_number,realwords+1}(iter,variant,tt),correct_either_real{experiment_number,realwords+1}(iter,variant,tt),correct_both_real{experiment_number,realwords+1}(iter,variant,tt)] ...
                        = testNcorrect(correct_single_all{experiment_number,realwords+1}(iter,variant,tt),total_single_all{experiment_number,realwords+1}(iter,variant,tt),correct_either_all{experiment_number,realwords+1}(iter,variant,tt),...
                        correct_both_all{experiment_number,realwords+1}(iter,variant,tt),total_double_all{experiment_number,realwords+1}(iter,variant,tt));
                end
            end
        end
        
        for iter = 1:n_iters
            for variant = 1:2
                for tt = 1:length(testpoints)
                    perf_single_real{experiment_number,realwords+1}(iter,variant,tt) = correct_single_real{experiment_number,realwords+1}(iter,variant,tt)./total_single_all{experiment_number,realwords+1}(iter,variant,tt);
                    perf_either_real{experiment_number,realwords+1}(iter,variant,tt) = correct_either_real{experiment_number,realwords+1}(iter,variant,tt)./total_double_all{experiment_number,realwords+1}(iter,variant,tt);
                    perf_both_real{experiment_number,realwords+1}(iter,variant,tt) = correct_both_real{experiment_number,realwords+1}(iter,variant,tt)./total_double_all{experiment_number,realwords+1}(iter,variant,tt);
                end
            end
        end
    end
    
    mean_single = mean(perf_single_real{experiment_number,realwords+1});
    mean_correct_both = mean(perf_both_real{experiment_number,realwords+1});
    mean_correct_either = mean(perf_either_real{experiment_number,realwords+1});
    
    std_single = std(perf_single_real{experiment_number,realwords+1});
    std_correct_both = std(perf_both_real{experiment_number,realwords+1});
    std_correct_either = std(perf_either_real{experiment_number,realwords+1});
    
    results = [mean_single;mean_correct_both].*100;
    result_devs = [std_single;std_correct_both].*100;
    
    %h = figure('Position',[500 300 1400 400]);
            
    for variant = 1:2
        subplot(1,3,variant+1);
        if(variant == 1)
        bar(results(:,variant,end),'FaceColor',[0.6 0.6 0.6]);
        else
            bar(results(:,variant,end),'FaceColor',[0.3 0.3 0.3]);
        end
        
        drawstds(h,1:2,results(:,variant,end),result_devs(:,variant,end)./se_factor,0.25,3,'red');
        grid;
        set(gca,'XTickLabel',{'single','both'});
        ylabel('% correct by knowledge');
        title(sprintf('%s',variants{variant}));
        
        [p12,s12] = ranksum(perf_single_real{experiment_number,realwords+1}(:,variant,end),perf_both_real{experiment_number,realwords+1}(:,variant,end),0.05);
        if(p12 <= 0.05)
            sigstar({[1,2]},p12);
        end
        %title(sprintf('%s',experiments(experiment_number),variants{variant}));
        fprintf('experiment %d, variant %s: p = %0.4f.\n',experiments(experiment_number),variants{variant},p12);
        ylim([0 120]);
        set(gca,'YTickLabel',{'0','20','40','60','80','100',''});
    end
    
    filename = sprintf('yurovsky_exp%d_talker%d_cb%d_func_cmvariant_normalized',experiments(experiment_number),talker,cbsize);
    saveFigure(filename,1);        
end


filename = [curdir '/results/' sprintf('yurovsky_talker%d_cb%d_results_normalized.mat',talker,cbsize)];
save(filename,'perf_single_real','perf_both_real','perf_either_real','perf_single','perf_both','perf_either','correct_either_all','correct_single_all','correct_both_all','total_double_all','total_single_all',...
    'correct_single_real','correct_either_real','correct_both_real');


% LIS?? 

h = figure('Position',[500 300 1400 400]);
clf;
for experiment_number = 1:3
    
    mean_single_novar = mean(perf_single{experiment_number,1});
    mean_correct_both_novar = mean(perf_both{experiment_number,1});
    mean_correct_either_novar = mean(perf_either{experiment_number,1});
    
    mean_single = mean(perf_single{experiment_number,2});
    mean_correct_both = mean(perf_both{experiment_number,2});
    mean_correct_either = mean(perf_either{experiment_number,2});
    
    std_single_novar = std(perf_single{experiment_number,1});
    std_correct_both_novar = std(perf_both{experiment_number,1});
    std_correct_either_novar = std(perf_either{experiment_number,1});
        
    std_single = std(perf_single{experiment_number,2});
    std_correct_both = std(perf_both{experiment_number,2});
    std_correct_either = std(perf_either{experiment_number,2});
    
    results = [mean_single;mean_correct_either;mean_correct_both].*100;
    result_devs = [std_single;std_correct_either;std_correct_both].*100;
    
    results_novar = [mean_single_novar;mean_correct_either_novar;mean_correct_both_novar].*100;
    result_devs_novar = [std_single_novar;std_correct_either_novar;std_correct_both_novar].*100;
        
    subplot(1,3,experiment_number);
    if(experiments(experiment_number) == 1)
        bardata = [results_novar(:,1,end) results(:,1,end) results_novar(:,2,end) results(:,2,end) yuvmean_xp1'];
    elseif(experiments(experiment_number) == 2)
        bardata = [results_novar(:,1,end) results(:,1,end) results_novar(:,2,end) results(:,2,end) yuvmean_xp2'];
    elseif(experiments(experiment_number) == 3)
        bardata = [results_novar(:,1,end) results(:,1,end) results_novar(:,2,end) results(:,2,end)  yuvmean_xp3'];
    end
    bar(bardata);
    legend({'basic','basic+var','attention','attention+var','adults'},'Location','NorthWest');
    %colormap([0.6 0.6 0.6;255/256 165/256 0;0.3 0.3 0.3])
    %colormap([0.6 0.6 0.6;255/256 165/256 0;89/256 255/256 0.3])
    colormap([0.3 0.3 0.3;0.6 0.6 0.6;0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3])
        
    drawstds(h,(1:3)-0.31,results_novar(:,1,end),result_devs_novar(:,1,end)./se_factor,0.03,2,'red');
    drawstds(h,(1:3)-0.15,results(:,1,end),result_devs(:,1,end)./se_factor,0.03,2,'red');
    drawstds(h,(1:3),results_novar(:,2,end),result_devs_novar(:,1,end)./se_factor,0.03,2,'red');
    drawstds(h,(1:3)+0.15,results(:,2,end),result_devs(:,2,end)./se_factor,0.03,2,'red');
    if(experiments(experiment_number) == 1)
        drawstds(h,(1:3)+0.31,yuvmean_xp1,yuvstd_xp1,0.03,2,'red');
    elseif(experiments(experiment_number) == 2)
        drawstds(h,(1:3)+0.31,yuvmean_xp2,yuvstd_xp2,0.03,2,'red');
    elseif(experiments(experiment_number) == 3)
        drawstds(h,(1:3)+0.31,yuvmean_xp3,yuvstd_xp3,0.03,2,'red');
    end
    
    grid;
    set(gca,'XTickLabel',{'single','either','both'});
    ylabel('% correct');
    %title(sprintf('%s',experiments(experiment_number),variants{variant}));
    title(sprintf('condition #%d',experiment_number));
    line([0.5 1.5],[chancelevs(1) chancelevs(1)],'LineWidth',2,'Color','black','LineStyle','--');
    line([1.5 2.5],[chancelevs(2) chancelevs(2)],'LineWidth',2,'Color','black','LineStyle','--');
    line([2.5 3.5],[chancelevs(3) chancelevs(3)],'LineWidth',2,'Color','black','LineStyle','--');
    ylim([0 100]);
end

filename = sprintf('yurovsky_all_exps_talker%d_cb%d',talker,cbsize);
saveFigure(filename,1);
