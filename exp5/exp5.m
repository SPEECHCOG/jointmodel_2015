% Exp5 of Räsänen & Rasilo (2015)

clear all

curdir = pwd;

experiments = 1;    % Which experiments to run?
n_iters = 5;       % How many iterations per experiment
talker = 1;         % Talkers 1-4
cbsize = 64;        % VQ codebook size


filename = [curdir sprintf('/data/yurovsky_data_%d_cb%d.mat',talker,cbsize)];

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
PRC = cell(length(experiments),1);
RCL = cell(length(experiments),1);
F = cell(length(experiments),1);

perf_con = {};
perf_basic = {};
indices_con = {};

PRC_basic = {};
RCL_basic = {};
F_basic = {};
PRC_con = {};
RCL_con = {};
F_con = {};

noiselevels = [0 0.4 0.8];

for experiment_number = 1:length(experiments)
    perf{experiment_number} = zeros(n_iters,2);
    for noiseiter = 1:length(noiselevels)
        noiselevel = noiselevels(noiseiter);
        for iter = 1:n_iters    % Run through multiple iterations as the data set varies between runs (different subset, different tags, different noise)
            
            % Load experiment data
            [data_train,tags_train,data_test,tags_test,taginds,train_filenames,test_filenames,testpoints,testinds]  = getExperimentData_wordlearningexp_final_v2(experiments(experiment_number),tags,data,filenames,tagnames,noiselevel);
            
            %validateExpData(tags_train,tags_test,taginds,1)
            % Run through three variants (global+local, global, no-norm)
            for variant = 1:2
                
                for tt = 1:length(testpoints)
                    
                    tS = formatCMF(data_train(1:testpoints(tt)),tags_train(1:testpoints(tt),:),1:25,50,0);
                    if(variant == 1)
                        tS = runCMF(tS); % Run standard CM (global)
                    elseif(variant == 2)
                        tS = activetrainCMF_referent_smith(tS); % Run global+local
                    end
                    
                    % Measure performance at different points in time
                    
                    wrong = zeros(50,1);
                    correct = zeros(50,1);
                    total_seg_errors = zeros(0,2);
                    total_seg_errors_correct = zeros(0,2);
                    total_seglens = zeros(0,1);
                    ins = 0;
                    tothypos = 0;
                    for k = 1:length(data_test)
                        truetags = tags_test(k,:);
                        truetags = unique(truetags);
                        truetags(truetags == 0) = [];
                        seq = data_test{k};
                        if(max(seq) > size(tS.T{1},3))
                            seq(seq > size(tS.T{1},3)) = size(tS.T{1},3);
                        end
                        p = testaaCMF(seq,tS,1);                        
                        
                        [hypos,locs] = decodeCMFthr(p,0.6);   % Get word hypotheses
                        
                        for j = 1:length(truetags)
                            if(intersect(truetags(j),hypos))
                                correct(truetags(j)) = correct(truetags(j))+1;
                            else
                                wrong(truetags(j)) = wrong(truetags(j))+1;
                            end
                        end
                        
                        ins = ins+length(truetags)-length(hypos);
                        tothypos = tothypos+length(hypos);
                        
                        % Evaluate segmentation
                        bounds = [annotated_bounds{testinds(k),1} annotated_bounds{testinds(k),2}];
                        [seg_errors] = evaSeg(p,locs,bounds);
                        seg_errors = seg_errors+5;
                        
                        total_seg_errors = [total_seg_errors;seg_errors];
                        
                        [seg_errors_correct,seglens] = evaSegCorrect(p,locs,bounds,truetags);
                        total_seg_errors_correct = [total_seg_errors_correct;seg_errors_correct];
                        total_seglens = [total_seglens seglens];
                    end
                    
                    daa = correct./(correct+wrong);
                    precision = sum(correct)./tothypos;
                    recall = mean(daa);
                    fscore = 2.*precision*recall/(precision+recall);
                    
                    if(variant == 2)
                        indices_con{iter} = find(daa > 0);
                        perf_con{iter} = daa;
                        PRC_con{iter} = precision;
                        RCL_con{iter} = recall;
                        F_con{iter} = fscore;
                    else
                        perf_basic{iter} = daa;
                        PRC_basic{iter} = precision;
                        RCL_basic{iter} = recall;
                        F_basic{iter} = fscore;
                    end
                    
                    fprintf('mean segmentation error: %0.1fms (onset), mean segmentation error: %0.1fms (offset), mean: %0.1fms/%0.1fms.\n',...
                        mean(abs(total_seg_errors(:,1).*10)),mean(abs(total_seg_errors(:,2).*10)),mean((total_seg_errors(:,1).*10)),mean((total_seg_errors(:,2).*10)))
                    
                    % Evaluate performance using only the selected word tokens
                    perf{experiment_number}(iter,variant,tt,noiseiter) = sum(correct(taginds))./(sum(correct(taginds))+sum(wrong(taginds)));
                    SEG{experiment_number,iter,variant,tt,noiseiter} = total_seg_errors;
                    RCL{experiment_number}(iter,variant,tt,noiseiter) = recall;
                    PRC{experiment_number}(iter,variant,tt,noiseiter) = precision;
                    F{experiment_number}(iter,variant,tt,noiseiter) = fscore;
                    SEG_CORRECT{experiment_number,iter,variant,tt,noiseiter} = total_seg_errors_correct;
                    SEGLEN{experiment_number,iter,variant,tt,noiseiter} = total_seglens;
                    fprintf('Total correct: %0.2f%%.\n',perf{experiment_number}(iter,variant,tt,noiseiter)*100);
                    fprintf('F-score: %0.2f (PRC = %0.2f, RCL = %0.2f).\n',F{experiment_number}(iter,variant,tt,noiseiter),PRC{experiment_number}(iter,variant,tt,noiseiter),RCL{experiment_number}(iter,variant,tt,noiseiter));
                    
                end
            end
        end
    end
end


perf{experiment_number} = perf{experiment_number}.*100;

clear tS
save results/result_backup.mat 




if(experiments(experiment_number) == 2)
    chance_level = 4/50*100;
else
    chance_level = 4/36*100;
end

set(0,'defaultaxesfontsize',20);
set(0,'defaulttextfontsize',20);


b = figure('Position',[800 1000 1000.*1.3 700.*1.3]);
n = 1;
h = [];
for j = 1:3
    for variant = 1:2
        subplot(3,2,n);
        n = n+1;
        hold on;
        varit = {[0 0 0],'red','blue','magenta'};
        tyylit = {'-','--','-','--'};
        
        for noiseiter = 1:length(noiselevels)
            
            if(j == 1)
                h(noiseiter) = plot(testpoints,squeeze(mean(F{1}(:,variant,:,noiseiter))),'Linewidth',2,'Color',varit{noiseiter},'LineStyle',tyylit{noiseiter},'DisplayName',sprintf('%d%%',noiselevels(noiseiter).*100));
            elseif(j == 2)
                plot(testpoints,squeeze(mean(PRC{1}(:,variant,:,noiseiter))),'Linewidth',2,'Color',varit{noiseiter},'LineStyle',tyylit{noiseiter})
            else
                plot(testpoints,squeeze(mean(RCL{1}(:,variant,:,noiseiter))),'Linewidth',2,'Color',varit{noiseiter},'LineStyle',tyylit{noiseiter})
            end
            
            if(j == 1)
                drawstds(b,testpoints,squeeze(mean(F{1}(:,variant,:,noiseiter))),squeeze(std(F{1}(:,variant,:,noiseiter)))./sqrt(n_iters),10,2,varit{noiseiter});
                ylabel('F-score');
            elseif(j == 2)
                drawstds(b,testpoints,squeeze(mean(PRC{1}(:,variant,:,noiseiter))),squeeze(std(PRC{1}(:,variant,:,noiseiter)))./sqrt(n_iters),10,2,varit{noiseiter});
                ylabel('precision');
            else
                drawstds(b,testpoints,squeeze(mean(RCL{1}(:,variant,:,noiseiter))),squeeze(std(RCL{1}(:,variant,:,noiseiter)))./sqrt(n_iters),10,2,varit{noiseiter});
                ylabel('recall');
            end
            
            xlim([0 max(testpoints)+25]);            
                       
        end
        grid;
        set(gca,'xtick',0:250:1000)
            set(gca,'ytick',0:0.250:1)
        
    end
end
legend(h,'Location','NorthEast');
subplot(3,2,1);title('basic model');subplot(3,2,2);title('attention-constrained');
subplot(3,2,5);xlabel('utterances perceived');
subplot(3,2,6);xlabel('utterances perceived');

save results/results_all_noise.mat


varit = {[0 0 0],'red','blue','magenta'};
tyylit = {'-','--','-','--'};
markkerit = {'s','*'};
c = figure('Position',[500 300 1400 400]);
startpoint = 2;

for noiseiter = 1:1 %length(noiselevels)
%for noiseiter = [1,4]
    subplot(1,2,1);
    hold on;
    for variant = 1:2
        
        virhe = [];
        virhe_cor = [];
        for k = 1:size(SEG,4)
            for iter = 1:n_iters
                virhe(k,iter) = mean(mean(abs(SEG{1,iter,variant,k,noiseiter}(:,:))));                
            end
        end
        
        mean_seg_er = mean(virhe,2);
        std_seg_er = std(virhe,[],2)./sqrt(n_iters);
                
        if(variant == 1)        
            h1 = plot(testpoints(startpoint:end),mean_seg_er(startpoint:end).*10,'LineWidth',2,'Color','black','LineStyle','-');
            drawstds(c,testpoints(startpoint:end),mean_seg_er(startpoint:end).*10,std_seg_er(startpoint:end).*10,1.25,2,'black');
        else
            h2 = plot(testpoints(startpoint:end),mean_seg_er(startpoint:end).*10,'LineWidth',2,'Color','red','LineStyle','--');
            drawstds(c,testpoints(startpoint:end),mean_seg_er(startpoint:end).*10,std_seg_er(startpoint:end).*10,1.25,2,'red');
        end
                        
        xlabel('utterances perceived');
        ylabel('mean segmentation error (ms)');
        
        
    end
    
    if(noiseiter == 1)
        legend([h1 h2],'Location','NorthEast',{'basic';'constrained'});
    end
    
    
    %% Segment length
    subplot(1,2,2);hold on;
    
    for variant = 1:2
        pituus = [];
        
        for k = 1:size(SEG,4)
            for iter = 1:n_iters
                pituus(k,iter) = mean(mean(abs(SEGLEN{1,iter,variant,k,noiseiter}(:,:))));
            end
        end
        
        mean_seg_er = mean(pituus,2);
        std_seg_er = std(pituus,[],2)./sqrt(n_iters);
        

        if(variant == 1)
            h1= plot(testpoints(startpoint:end),mean_seg_er(startpoint:end).*10,'LineWidth',2,'Color','black','LineStyle','-');
             drawstds(c,testpoints(startpoint:end),mean_seg_er(startpoint:end).*10,std_seg_er(startpoint:end).*10,1.25,2,'black');
        else
            h2 = plot(testpoints(startpoint:end),mean_seg_er(startpoint:end).*10,'LineWidth',2,'Color','red','LineStyle','--');
            drawstds(c,testpoints(startpoint:end),mean_seg_er(startpoint:end).*10,std_seg_er(startpoint:end).*10,1.25,2,'red');
        end

        xlabel('utterances perceived');
        ylabel('mean word length (ms)');
    end
    
        
    if(noiseiter == 1)
        legend([h1 h2],'Location','SouthEast',{'basic';'constrained'});
    end
    
end
line([0 testpoints(end)+100],[0.3909 0.3909].*1000,'Color','black','LineStyle','--','LineWidth',2);
subplot(1,2,1);grid;xlim([0 testpoints(end)+25]);subplot(1,2,2);grid;xlim([0 testpoints(end)+25]);


filename = sprintf('results/wordlearningexps_exp%d_noise.mat',experiments(experiment_number));
save(filename,'SEG','SEGLEN','perf','SEG_CORRECT');

%% Plot example

figure('Position',[500 300 1400 900]);
[data_train,tags_train,data_test,tags_test,taginds,train_filenames,test_filenames,testpoints,testinds]  = getExperimentData_wordlearningexp_final_v2(experiments(experiment_number),tags,data,filenames,tagnames,0);
%plotindex = find(testinds == 1911);
plotindex = find(testinds == 1666);

[x,fs] = wavread(test_filenames{plotindex});
x = resample(x,16000,fs);
fs = 16000;
subplot(4,1,1);hold on;
t = 0:1/fs:length(x)/fs-1/fs;
plot(t,x);
xlim([0.22 2.2]);

bounds = [annotated_bounds{testinds(plotindex),1} annotated_bounds{testinds(plotindex),2}];
for k = 1:length(bounds)
    line([bounds(k) bounds(k)],[-1 1],'Color','black','LineWidth',1);
end
for k = 2:length(bounds)-1
    text(bounds(k)+0.01,0.7,sprintf(annoinfo.wordtag_list{annoinfo.wordtag(testinds(plotindex),k)}),'FontSize',16);
end
ylabel('amplitude')
subplot(4,1,2)
tS = formatCMF(data_train(1:testpoints(3)),tags_train(1:testpoints(3),:),1:25,50,0);
tS = runCMF(tS); % Run standard CM (global)
p = testaaCMF(data_test{plotindex},tS,1);

p = [zeros(7,size(p,2));p(1:end-7,:)];

[vals,winners] = sort(max(p),'descend');

winners(1:5)

t = 0:1/100:length(p)/100-1/100;
plot(t,p,'LineWidth',2)
xlim([0.22 2.2])
ylim([0.0 max(p(:))+0.003])
ylabel('A''(c|X)');
for k = 1:length(bounds)
    line([bounds(k) bounds(k)],[-1 1],'Color','black','LineWidth',1);
end

subplot(4,1,3);
tS = formatCMF(data_train(1:testpoints(end)),tags_train(1:testpoints(end),:),1:25,50,0);
tS = runCMF(tS); % Run standard CM (global)
p = testaaCMF(data_test{plotindex},tS,1);
p = [zeros(7,size(p,2));p(1:end-7,:)];
t = 0:1/100:length(p)/100-1/100;
plot(t,p,'LineWidth',2)
xlim([0.22 2.2])
ylim([0.012 max(p(:))+0.003])
xlabel('time (s)');
ylabel('A''(c|X)');
for k = 1:length(bounds)
    line([bounds(k) bounds(k)],[-1 1],'Color','black','LineWidth',1);
end
text(0.85,0.04,'to see');
text(1.3,0.04,'sad');
text(1.65,0.04,'telephone');
[vals,winners] = sort(max(p),'descend');

winners(1:5)


subplot(4,1,4);hold on;

tS2 = formatCMF(data_train,ones(size(tags_train,1),1),1:5,50,0);
tS2 = runCMF(tS2,1); % Run standard CM (global)
t = 0:1/100:length(p)/100-1/100;
p1 = testaaCMF(data_test{plotindex},tS2,0);
p1 = [zeros(7,size(p1,2));p1(1:end-7,:)];
plot(t,p1,'LineWidth',2)
p2 = testaaCMF(data_test{plotindex},tS2,1);
p2 = [zeros(7,size(p2,2));p2(1:end-7,:)];
plot(t,p1,'LineWidth',2)
plot(t,p2,'LineWidth',2,'Color','red')
xlim([0.22 2.2])
ylim([min(p1(:)) max(p1(:))])
xlabel('time (s)');
ylabel('P(X)');
for k = 1:length(bounds)
    line([bounds(k) bounds(k)],[-1 1],'Color','black','LineWidth',1);
end

%% Run detailed analysis


pcon = [];
pbas = [];

for iter = 1:n_iters
    pcon = [pcon;perf_con{iter}(indices_con{iter})];
    pbas = [pbas;perf_basic{iter}(indices_con{iter})];
end

pcon = pcon.*100;
pbas = pbas.*100;

fprintf('mean words learned: %0.1f, std words learned: %0.1f.\n',mean(cellfun(@length,indices_con)),std(cellfun(@length,indices_con)));
fprintf('CONSTRAINED: mean: %0.2f (+- %0.2f), min: %0.2f, max: %0.2f.\n',mean(pcon),std(pcon),min(pcon),max(pcon));
fprintf('BASIC: mean: %0.2f (+- %0.2f), min: %0.2f, max: %0.2f.\n',mean(pbas),std(pbas),min(pbas),max(pbas));

[h,p] = ttest(pcon,pbas,0.05,'right');
if(h == 1)
    fprintf('CONSTRAINED better than BASIC (p = %0.5f).\n',p);
else
    fprintf('CONSTRAINED and BASIC not different (p = %0.5f).\n',p);
end

save results/results_all_noise.mat