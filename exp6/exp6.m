% Exp 6 of Räsänen & Rasilo (2015)

clear all

addpath('../aux_scripts/');
addpath('../CMF/');
addpath('../aux_scripts/k-means/');

curdir = pwd;

experiments = 1;    % Which experiments to run?
n_iters = 5;       % How many iterations per experiment

cbsize = 64;        % VQ codebook size

filename = [sprintf('data/all_talkers_cg_cb%d.mat',cbsize)];

% Get features and vector quantize (or load from file if already exists).
if(~exist(filename))
    [filenames,~,tags,~,tagnames,anno_train,anno_test] = definedataset(5,2,5); % loads caregiver Y2 data

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


fscore = zeros(4,4,n_iters);

for iter = 1:n_iters
    for n_to_train = 1:3
        for totest = 1:4

            if(n_to_train < 4)
                totrain = setdiff(1:4,totest);
                totrain = circshift(totrain',randi(10));
                totrain = totrain(1:n_to_train);
            else
                totrain = 1:4;
            end
            data_train = [];
            tags_train = [];
            train_filenames = [];

            for j = 1:length(totrain)
                [tmp,tmp2,data_test,tags_test,taginds,tmp3,test_filenames,testpoints,testinds]  = getExperimentData_generalization_Exp(1,tags((2397*(totrain(j)-1))+1:2397*totrain(j),:),data((2397*(totrain(j)-1))+1:2397*totrain(j)),filenames((2397*(totrain(j)-1))+1:2397*totrain(j)),tagnames,n_to_train);

                data_train = [data_train;tmp];
                tags_train = [tags_train;tmp2];
                train_filenames = [train_filenames;tmp3];
            end

            size(data_train)

            if(n_to_train ~= 4)
                [~,~,data_test,tags_test,taginds,~,test_filenames,testpoints,testinds]  = getExperimentData_generalization_Exp(1,tags((2397*(totest-1))+1:2397*totest,:),data((2397*(totest-1))+1:2397*totest),filenames((2397*(totest-1))+1:2397*totest),tagnames,n_to_train);
            end
            talker = totest;
            annotated_bounds = annoinfo.bounds((talker-1)*2397+1:talker*2397,:);
            annotated_words = annoinfo.wordtag((talker-1)*2397+1:talker*2397,:);
            annotated_wordnames = annoinfo.wordtag_list;

            tS = formatCMF(data_train,tags_train,1:15,50,0);
            tS = runCMF(tS); % Run standard CM (global)

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
            fscore(totest,n_to_train,iter) = 2.*precision*recall/(precision+recall);
        end
    end
end

fscore_baseline = fscore;

set(0,'defaultaxesfontsize',20);
set(0,'defaulttextfontsize',20);
b = figure('Position',[500 300 600 350]);
bar(mean(mean(fscore,3)));
drawstds(b,1:4,mean(mean(fscore,3)),mean(std(fscore,[],3))./sqrt(5),0.3,2,'red');
ylabel('F-score');
set(gca,'XTickLabel',{'1','2','3','3+self'});
xlabel('number of unique talkers in training data')
grid;
colormap([0.3 0.3 0.3;0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3]);
ylim([0.3 0.9])


%% Version 2:

for cond = 1:2

    n_iters = 5;

    fscore = zeros(4,4,n_iters);

    for iter = 1:n_iters
        for n_to_train = 1:3
            for totest = 1:4

                if(n_to_train < 4)
                    totrain = setdiff(1:4,totest);
                    totrain = circshift(totrain',randi(10));
                    totrain = totrain(1:n_to_train);
                else
                    totrain = 1:4;
                end


                data_train = [];
                tags_train = [];
                train_filenames = [];
                for j = 1:length(totrain)
                    if(cond == 1)
                        [tmp,tmp2,data_test,tags_test,taginds,tmp3,test_filenames,testpoints,testinds]  = getExperimentData_generalization_Exp(1,tags((2397*(totrain(j)-1))+1:2397*totrain(j),:),data((2397*(totrain(j)-1))+1:2397*totrain(j)),filenames((2397*(totrain(j)-1))+1:2397*totrain(j)),tagnames,1);
                    else
                        [tmp,tmp2,data_test,tags_test,taginds,tmp3,test_filenames,testpoints,testinds]  = getExperimentData_generalization_Exp(1,tags((2397*(totrain(j)-1))+1:2397*totrain(j),:),data((2397*(totrain(j)-1))+1:2397*totrain(j)),filenames((2397*(totrain(j)-1))+1:2397*totrain(j)),tagnames,1);
                    end

                    data_train = [data_train;tmp];
                    tags_train = [tags_train;tmp2];
                    train_filenames = [train_filenames;tmp3];
                end

                cut = length(data_train)/length(totrain);
                tS = formatCMF(data_train(1:cut),tags_train(1:cut,:),1:15,50,0);
                tS = runCMF(tS); % Run standard CM (global)

                for k = cut+1:length(data_train)

                    p = testaaCMF(data_train{k},tS,1);
                    [hypos,locs] = decodeCMFthr(p,0.6);   % Get word hypotheses


                    %truetags = tags_train(k,:);
                    %ntags = sum(truetags > 0);
                    %newtags = hypos(1:ntags);

                    tags_train(k,1:length(hypos)) = hypos;
                end

                tS = formatCMF(data_train,tags_train,1:15,50,0);
                tS = runCMF(tS); % Run standard CM (global)

                [~,~,data_test,tags_test,taginds,~,test_filenames,testpoints,testinds]  = getExperimentData_generalization_Exp(1,tags((2397*(totest-1))+1:2397*totest,:),data((2397*(totest-1))+1:2397*totest),filenames((2397*(totest-1))+1:2397*totest),tagnames,n_to_train);

                talker = totest;

                annotated_bounds = annoinfo.bounds((talker-1)*2397+1:talker*2397,:);
                annotated_words = annoinfo.wordtag((talker-1)*2397+1:talker*2397,:);
                annotated_wordnames = annoinfo.wordtag_list;

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

                    [hypos,locs] = decodeCMFthr(p,1);   % Get word hypotheses

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
                fscore(totest,n_to_train,iter) = 2.*precision*recall/(precision+recall);
            end
        end
    end
    if(cond == 1)
        fscore_control_split = fscore;
    else
        fscore_control_full = fscore;
    end
end

save results/results_64.mat fscore_baseline fscore_control_split fscore_control_full



set(0,'defaultaxesfontsize',20);
set(0,'defaulttextfontsize',20);
b = figure('Position',[500 300 600 350]);
shift = 0.225;
bardata = [mean(mean(fscore_baseline,3));mean(mean(fscore_control_split,3));mean(mean(fscore_control_full,3))];
bardata = bardata(1:3,1:3);
bardata(2:3,1) = bardata(1,1);
devs = [mean(std(fscore_baseline,[],3));mean(std(fscore_control_split,[],3));mean(std(fscore_control_full,[],3))];
devs(2:3,1) = devs(1,1);
bar(bardata');
legend('Location','NorthWest',{'full-ref','part-ref-small','part-ref-large'});
for k = 1:3
    if(k == 1)
        drawstds(b,(1:3)-shift,bardata(k,:),devs(k,:)./sqrt(5),0.03,2,'red');
    elseif(k == 2)
        drawstds(b,(1:3),bardata(k,:),devs(k,:)./sqrt(5),0.03,2,'red');
    else
        drawstds(b,(1:3)+shift,bardata(k,:),devs(k,:)./sqrt(5),0.03,2,'red');
    end
end
ylabel('F-score');
set(gca,'XTickLabel',{'M = 1','M = 2','M = 3',});
xlabel('number of unique talkers in training data')
grid;
colormap([0.3 0.3 0.3;0.1 0.3 0.5;255/256 165/256 0;89/256 154/256 211/256]);
ylim([0.3 0.6])
