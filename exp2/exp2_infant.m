
curdir = pwd;


addpath('../aux/');
addpath('../CMF/');
addpath('../aux/k-means/');

cbsize = 64;
n_iters = 15;               

perf = zeros(3,2,n_iters,3);

refcorrect = zeros(n_iters,1);
refwrong = zeros(n_iters,1);

ptot = zeros(3,4);

for stream = 1:2
    for iter = 1:n_iters
    if(stream == 1)
        exp1_train_words = {'pabiku';'tibudo';'golatu';'daropi'};
        exp1_test_words = {'pabiku';'tibudo';'tudaro';'pigola'};
    else
        exp1_train_words = {'tudaro';'pigola';'bikuti';'budopa'};
        exp1_test_words = {'tudaro';'pigola';'pabiku';'tibudo';};
    end
    
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
    TRAIN = cell(4,1);
    for w = 1:length(exp1_train_words)
        word = [];
        for syl = 1:3
            ss = exp1_train_words{w}(2*(syl-1)+1:2*syl);
            a = find(strcmp(names,ss));
            word = [word;wavs{a}];
        end
        TRAIN{w} = word;
    end
    
    TEST = cell(4,1);
    for w = 1:length(exp1_test_words)
        word = [];
        for syl = 1:3
            ss = exp1_test_words{w}(2*(syl-1)+1:2*syl);
            a = find(strcmp(names,ss));
            word = [word;wavs{a}];
        end
        TEST{w} = word;
    end
    
    % Exp 1: subject pool B
    
    % Get random order for familiarization stimuli
    wordorder1 = generateOrder();
    wordorder_rand = generateOrder();
    
    % Concatenate words into full fam stream
    wordseq_train = [];
    labels_train = [];
    labels_train_rand = [];
    
    for j = 1:length(wordorder1)
        wordseq_train = [wordseq_train;TRAIN{wordorder1(j)}];
        labels_train = [labels_train;ones(length(TRAIN{wordorder1(j)}),1).*wordorder1(j)];
        labels_train_rand = [labels_train_rand;ones(length(TRAIN{wordorder1(j)}),1).*wordorder_rand(j)];
    end
    
    labels_train = circshift(labels_train(1:160:end),0);
    labels_train_rand = circshift(labels_train_rand(1:160:end),0);
    
    audiowrite('data/fam_exp1_train.wav',wordseq_train,16000);
    
    % Generate test tokens
    for w = 1:4
        sil = randn(2000,1).*0.00001;
        tmp = sil;
        
        for rep = 1:1
            tmp = [tmp;TEST{w};sil];
        end
        
        audiowrite(sprintf('data/exp1_test_w%d.wav',w),tmp,16000);
    end
    
    % Generate 4 AFC tokens
    
    for w = 1:4
        sil = randn(8000,1).*0.00001;
        tmp = sil;
        
        for rep = 1:1
            tmp = [tmp;TRAIN{w};sil];
        end
        
        audiowrite(sprintf('data/exp1_4AFC_test_w%d.wav',w),tmp,16000);
    end
    
    
    filenames = {'data/fam_exp1_train.wav';'data/exp1_test_w1.wav';'data/exp1_test_w2.wav';'data/exp1_test_w3.wav';'data/exp1_test_w4.wav';...
        'data/exp1_4AFC_test_w1.wav';'data/exp1_4AFC_test_w2.wav';'data/exp1_4AFC_test_w3.wav';'data/exp1_4AFC_test_w4.wav'};
    
    F = getMFCCs(filenames,1,'white',1000,0.025,0.01); % This has to be without CMVN
    %% Run experiment
        
    
        
        cb = createCodebook(F,cbsize,10000); % Makes codebook
        data_train = runVQ(F,cb,1); % Quantizes data
        data_train{1}(1) = cbsize;
        
        % Prepare data
         
        for cond = 1:2              % Two conditions: synch and non-synch
            [bounds,tags] = getSegments(labels_train);
            training_vqs = cell(length(bounds),1);
            
            training_tags = tags;
            for k = 1:length(bounds)
                if(cond == 1)
                    
                    spread = 20; % Put +200 and -200 ms shift to boundaries (infant version)                    
                    training_vqs{k} = data_train{1}(max(1,bounds(k,1)-spread):min(length(data_train{1}),bounds(k,2)+spread));
                elseif(cond == 2)                    
                    %spread = randi(20); % Put 0-200 ms random shift to boundaries (adult version)
                    spread = randi(40); % Put 0-400 ms random shift to boundaries (infant version)
                    
                    training_vqs{k} = data_train{1}(max(1,bounds(k,1)-spread):min(length(data_train{1}),bounds(k,2)+spread));
                end
            end
            
            for viscond = 1:3
                
                correct = 0;
                wrong = 0;
                
                if(viscond == 1)                    
                    tS = formatCMF(data_train(1),1,1:25,1);
                    tS = runCMF(tS,1);                    
                elseif(viscond == 2) % Consitent visuals                    
                    tS = formatCMF(training_vqs,training_tags',1:25,cbsize);
                    tS = runCMF(tS,1);                    
                elseif(viscond == 3) % Scrambled visuals                    
                    tS = formatCMF(training_vqs,[randi(4,size(training_tags'))],1:25,cbsize);
                    tS = runCMF(tS,1);
                end
                
                % Run forced-choice segmentation task by playing pairs of words
                
                fullwords = 1:2;
                partwords = 3:4;
                
                p = zeros(4,1);
                for w = 1:4
                    tmp = testaaCMF(data_train{w+1},tS);                    
                    [val,winner] = max(sum(tmp)); 
                    p(w) = mean(tmp(:,winner));
                    ptot(viscond,w) = ptot(viscond,w)+p(w);
                end
                                
                for trueword = 1:2
                    for partword = 3:4
                        if(p(trueword) >= p(partword))
                            correct = correct+1;
                        else
                            wrong = wrong+1;
                        end
                    end
                end
                
                if(viscond == 2) % Only in systematic visual info
                    % 4-alternative FC task
                    for w = 1:4                        
                        tmp = testaaCMF(data_train{w+5},tS);
                        
                        tmp = sum(tmp);
                        [val,winner] = max(tmp);
                        
                        if(winner == w)
                            refcorrect(iter) = refcorrect(iter)+1;
                        else
                            refwrong(iter) = refwrong(iter)+1;
                        end
                    end
                end
                perf(cond,stream,iter,viscond) = correct./(correct+wrong);
            end
        end
    end
end

res = cell(2,1);
for cond = 1:2
    tmp = [squeeze(perf(cond,1,:,:));squeeze(perf(cond,2,:,:))]; % Combine across the two streams
    res{cond} = tmp;
end

thies_results = [8.9 12 9.8]./16.*100;
thies_devs = [2 2.6 3]./16.*100/sqrt(20);

shift1 = 0.225;
b = figure('Position',[500 300 600 350]);
bar([mean(res{1})'.*100 mean(res{2})'.*100 thies_results']);

drawstds(b,(1:3)-shift1,mean(res{1}).*100,std(res{1}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3),mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3)+shift1,thies_results,thies_devs,0.05,2,'red');
set(gca,'XTickLabel',{'no visual';'consistent visual';'random visual'});
line([0 4],[50 50],'LineStyle','--','LineWidth',2','Color','black');
grid;
legend({'+-200 ms','+-400 ms rand','adults'},'Location','NorthEast');
xlim([0.5 3.5])
xlabel('condition');
ylabel('performance (%)');
colormap([0.3 0.3 0.3;0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3])
save([curdir '/results/' sprintf('thiessen_task_results_%d_infant.mat',cbsize)],'perf','res');

