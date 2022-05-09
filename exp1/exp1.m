% Experiment code for jointmod-paper Rasanen & Rasilo, Experiment 1.
%
% last update 21.4.2015
%
% 

addpath('../aux_scripts/');
addpath('../CMF/');
addpath('../aux_scripts/k-means/');
curdir = pwd;

exp1_train_words_A = {'tupiro';'golabu';'bidaku';'padoti'};
exp1_train_words_B = {'dapiku';'tilado';'buropi';'pagotu'};

exp1_test_words = {'tupiro';'golabu';'dapiku';'tilado'};

n_iters = 12;

tmp = dir([curdir '/stimuli/*.wav']);
filenames = [];
for k = 1:length(tmp)
    filenames{k} = tmp(k).name;
end

wavs = cell(length(filenames),1);
names = cell(length(filenames),1);
for k = 1:length(filenames)
    [wavs{k},fs] = audioread([curdir '/stimuli/' filenames{k}]);
    names{k} = filenames{k}(1:2);
end

% Generate words from syllable pieces

% Exp 1: subject pool A
E1A = cell(4,1);
for w = 1:length(exp1_train_words_A)
    word = [];
    for syl = 1:3
        ss = exp1_train_words_A{w}(2*(syl-1)+1:2*syl);
        a = find(strcmp(names,ss));
        word = [word;wavs{a}];
    end
    E1A{w} = word;
end

% Exp 1: subject pool B

E1B = cell(4,1);
for w = 1:length(exp1_train_words_B)
    word = [];
    for syl = 1:3
        ss = exp1_train_words_B{w}(2*(syl-1)+1:2*syl);
        a = find(strcmp(names,ss));
        word = [word;wavs{a}];
    end
    E1B{w} = word;
end

% Get random order for familiarization stimuli
wordorder1 = generateOrder();
wordorder2 = generateOrder();

% Concatenate words into full fam stream
wordseq_A = [];
wordseq_B = [];
for j = 1:min(length(wordorder1),length(wordorder2))
    wordseq_A = [wordseq_A;E1A{wordorder1(j)}];
    wordseq_B = [wordseq_B;E1B{wordorder2(j)}];
end

audiowrite('data/fam_exp1_A.wav',wordseq_A,16000);
audiowrite('data/fam_exp1_B.wav',wordseq_B,16000);

% Generate test tokens, 3 reps with 500 ms silence
for w = 1:4
    sil = randn(8000,1).*0.00001;
    tmp = sil;
    if(w == 1)
        ww = E1A{1};
    elseif(w == 2)
        ww = E1A{2};
    elseif(w == 3)
        ww = E1B{1};
    else
        ww = E1B{2};
    end
    
    for rep = 1:3
        tmp = [tmp;ww;sil];
    end
    
    audiowrite(sprintf('data/exp1_test_w%d.wav',w),tmp,16000);
end

filenames = {'data/fam_exp1_A.wav';'data/fam_exp1_B.wav';'data/exp1_test_w1.wav';'data/exp1_test_w2.wav';'data/exp1_test_w3.wav';'data/exp1_test_w4.wav'};

F = getMFCCs(filenames,1,'white',1000,0.025,0.01); % CMVN MUST BE TURNED OFF

%% Run experiment


cbsizes = [4 16 64];

totprob_fam_exp1 = cell(length(cbsizes),1);
totprob_novel_exp1 = cell(length(cbsizes),1);

j = 1;
for cbsize = cbsizes
    
    p = cell(2,4,1);
    totprob = zeros(2,4,1);
    maxprob = zeros(2,4,1);
    
    for iter = 1:n_iters
        
        cb = createCodebook(F,cbsize,10000); % Makes codebook
        data_train = runVQ(F,cb,1); % Quantizes data
        data_train{1}(1) = cbsize;
        data_train{2}(1) = cbsize;
        tags_train = 1;
        for cond = 1:2
            if(cond == 1)
                tS = formatCMF(data_train(1),tags_train,1:25,1,0);
            else
                tS = formatCMF(data_train(2),tags_train,1:25,1,0);
            end
            
            tS = runCMF(tS,1); % Run standard CM (global)
            
            for w = 1:4
                p{cond,w,iter} = testaaCMF(data_train{w+2},tS);
                totprob(cond,w,iter) = mean(p{cond,w,iter});
                maxprob(cond,w,iter) = max(p{cond,w,iter});
            end
        end
    end
    
    totprob_fam_exp1{j} = (totprob(1,1:2,:)+totprob(2,3:4,:));
    totprob_fam_exp1{j} = sum(totprob_fam_exp1{j},2)./4;
    totprob_novel_exp1{j} = (totprob(1,3:4,:)+totprob(2,1:2,:));
    totprob_novel_exp1{j} = sum(totprob_novel_exp1{j},2)./4;
    j = j+1;
end


%% Experiment 2 of Saffran et al. (1996) (same as exp1 but with part-words instead of non-words)

exp2_train_words_A = {'pabiku';'tibudo';'golatu';'daropi'};
exp2_train_words_B = {'tudaro';'pigola';'bikuti';'budopa'};

exp2_test_words = {'pabiku';'tibudo';'tudaro';'pigola'};

% Run the actual experiment

tmp = dir([curdir '/stimuli/*.wav']);
filenames = [];
for k = 1:length(tmp)
    filenames{k} = tmp(k).name;
end

wavs = cell(length(filenames),1);
names = cell(length(filenames),1);
for k = 1:length(filenames)
    [wavs{k},fs] = audioread([curdir '/stimuli/' filenames{k}]);
    names{k} = filenames{k}(1:2);
end

% Generate words

E1A = cell(4,1);
for w = 1:length(exp2_train_words_A)
    word = [];
    for syl = 1:3
        ss = exp2_train_words_A{w}(2*(syl-1)+1:2*syl);
        a = find(strcmp(names,ss));
        word = [word;wavs{a}];
    end
    E1A{w} = word;
end

E1B = cell(4,1);
for w = 1:length(exp2_train_words_B)
    word = [];
    for syl = 1:3
        ss = exp2_train_words_B{w}(2*(syl-1)+1:2*syl);
        a = find(strcmp(names,ss));
        word = [word;wavs{a}];
    end
    E1B{w} = word;
end

wordorder1 = generateOrder();
wordorder2 = generateOrder();

wordseq_A = [];
wordseq_B = [];
for j = 1:min(length(wordorder1),length(wordorder2))
    wordseq_A = [wordseq_A;E1A{wordorder1(j)}];
    wordseq_B = [wordseq_B;E1B{wordorder2(j)}];
end


audiowrite('data/fam_exp2_A.wav',wordseq_A,16000);
audiowrite('data/fam_exp2_B.wav',wordseq_B,16000);

testsignals = cell(4,1);
for w = 1:4
    sil = randn(8000,1).*0.00001;
    tmp = sil;
    if(w == 1)
        ww = E1A{1};
    elseif(w == 2)
        ww = E1A{2};
    elseif(w == 3)
        ww = E1B{1};
    else
        ww = E1B{2};
    end
    
    for rep = 1:3
        tmp = [tmp;ww;sil];
    end
    
    audiowrite(sprintf('data/exp2_test_w%d.wav',w),tmp,16000);
end

filenames = {'data/fam_exp2_A.wav';'data/fam_exp2_B.wav';'data/exp2_test_w1.wav';'data/exp2_test_w2.wav';'data/exp2_test_w3.wav';'data/exp2_test_w4.wav'};

F = getMFCCs(filenames,1,'white',1000,0.025,0.01);
%% Run experiment

cbsizes = [4 16 64];

totprob_fam_exp2 = cell(length(cbsizes),1);
totprob_novel_exp2 = cell(length(cbsizes),1);

j = 1;
for cbsize = cbsizes
    
    p = cell(2,4,1);
    totprob = zeros(2,4,1);
    maxprob = zeros(2,4,1);
    
    for iter = 1:n_iters
        
        cb = createCodebook(F,cbsize,10000); % Makes codebook
        data_train = runVQ(F,cb,1); % Quantizes data
        data_train{1}(1) = cbsize;
        data_train{2}(1) = cbsize;
        tags_train = 1;
        
        for cond = 1:2
            if(cond == 1)
                tS = formatCMF(data_train(1),tags_train,1:25,1,0);
            else
                tS = formatCMF(data_train(2),tags_train,1:25,1,0);
            end
            
            tS = runCMF(tS,1); % Run standard CM (global)
            
            for w = 1:4
                p{cond,w,iter} = testaaCMF(data_train{w+2},tS);
                totprob(cond,w,iter) = mean(p{cond,w,iter});
                maxprob(cond,w,iter) = max(p{cond,w,iter});
            end
        end
    end
    
    totprob_fam_exp2{j} = (totprob(1,1:2,:)+totprob(2,3:4,:));
    totprob_fam_exp2{j} = sum(totprob_fam_exp2{j},2)./4;
    totprob_novel_exp2{j} = (totprob(1,3:4,:)+totprob(2,1:2,:));
    totprob_novel_exp2{j} = sum(totprob_novel_exp2{j},2)./4;
    j = j+1;
end
%[a,b] = ttest(squeeze(totprob_fam_exp2),squeeze(totprob_novel_exp2),0.05,'right');

% Draw pictures

set(0,'defaultaxesfontsize',20);
set(0,'defaulttextfontsize',20);
difs_exp1 = {};
devs_exp1 = [];
means_exp1 = [];
devs_exp2 = [];
means_exp2 = [];
for k = 1:length(totprob_fam_exp1)
    difs_exp1{k} = totprob_fam_exp1{k}-totprob_novel_exp1{k};
    difs_exp2{k} = totprob_fam_exp2{k}-totprob_novel_exp2{k};
    devs_exp1(k) = std(difs_exp1{k});
    means_exp1(k) = mean(difs_exp1{k});
    devs_exp2(k) = std(difs_exp2{k});
    means_exp2(k) = mean(difs_exp2{k});
end

b = figure('Position',[500 300 1400 400]);
subplot(1,2,1);
bar(cellfun(@mean,totprob_fam_exp1)-cellfun(@mean,totprob_novel_exp1))
drawstds(b,1:length(cbsizes),means_exp1,devs_exp1./sqrt(n_iters),0.2,2,'red',0);
set(gca,'XTickLabel',cbsizes);
xlabel('acoustic alphabet size');
ylabel('p_t_r_u_e-p_n_o_n');
grid;
ylim([-0.002 0.032]);
subplot(1,2,2);
bar(cellfun(@mean,totprob_fam_exp2)-cellfun(@mean,totprob_novel_exp2))
drawstds(b,1:length(cbsizes),means_exp2,devs_exp2./sqrt(n_iters),0.2,2,'red',0);
set(gca,'XTickLabel',cbsizes);
xlabel('acoustic alphabet size');
ylabel('p_t_r_u_e-P_p_a_r_t');
ylim([-0.002 0.032]);
grid;

save([curdir '/results/saffran96_results.mat'],'totprob_novel_exp1','totprob_novel_exp2','totprob_fam_exp1','totprob_fam_exp2','cbsizes');

%% Draw surprisal

set(0,'defaultaxesfontsize',20);
set(0,'defaulttextfontsize',20);
difs_exp1 = {};
devs_exp1 = [];
means_exp1 = [];
devs_exp2 = [];
means_exp2 = [];
for k = 1:length(totprob_fam_exp1)
    difs_exp1{k} = totprob_fam_exp1{k}-totprob_novel_exp1{k};
    difs_exp2{k} = totprob_fam_exp2{k}-totprob_novel_exp2{k};
    devs_exp1(k) = std(difs_exp1{k});
    means_exp1(k) = mean(difs_exp1{k});
    devs_exp2(k) = std(difs_exp2{k});
    means_exp2(k) = mean(difs_exp2{k});
end


surprisal_exp1 = zeros(length(totprob_fam_exp1),2);
surprisal_exp2 = zeros(length(totprob_fam_exp1),2);
surprisal_exp1_dev = zeros(length(totprob_fam_exp1),2);
surprisal_exp2_dev = zeros(length(totprob_fam_exp1),2);
for k = 1:length(totprob_fam_exp1)
    surprisal_exp1(k,1) = mean(-log(totprob_fam_exp1{k}));
    surprisal_exp1(k,2) = mean(-log(totprob_novel_exp1{k}));
    surprisal_exp2(k,1) = mean(-log(totprob_fam_exp2{k}));
    surprisal_exp2(k,2) = mean(-log(totprob_novel_exp2{k}));
    
    surprisal_exp1_dev(k,1) = std(-log(totprob_fam_exp1{k}));
    surprisal_exp1_dev(k,2) = std(-log(totprob_novel_exp1{k}));
    surprisal_exp2_dev(k,1) = std(-log(totprob_fam_exp2{k}));
    surprisal_exp2_dev(k,2) = std(-log(totprob_novel_exp2{k}));
end


b = figure('Position',[500 300 1400 400]);
subplot(1,2,1);
bar(surprisal_exp1);

shifts = [-0.14;0.14];
for k = 1:2
    drawstds(b,(1:length(cbsizes))+shifts(k),surprisal_exp1(:,k),surprisal_exp1_dev(:,k)./sqrt(n_iters),0.075,2,'red',0);
end
colormap([0.3 0.3 0.3;89/256 154/256 211/256])
set(gca,'XTickLabel',cbsizes);
legend({'true words';'non-words'},'Location','NorthWest');
xlabel('acoustic alphabet size');
ylabel('surprisal');
title('condition 1');
grid;
ylim([1 2.5])
subplot(1,2,2);
bar(surprisal_exp2);
shifts = [-0.14;0.14];
for k = 1:2
    drawstds(b,(1:length(cbsizes))+shifts(k),surprisal_exp2(:,k),surprisal_exp2_dev(:,k)./sqrt(n_iters),0.075,2,'red',0);
end
set(gca,'XTickLabel',cbsizes);
xlabel('acoustic alphabet size');
ylabel('surprisal');
ylim([1 2.5])
legend({'true words';'part-words'},'Location','NorthWest');
colormap([0.3 0.3 0.3;89/256 154/256 211/256])
title('condition 2');
grid;
