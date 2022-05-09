

curdir = pwd;

talker = 1;
cbsize = 64;

redrawpics = 1;


filename = [curdir '/results/' sprintf('yurovsky_talker%d_cb%d_results_normalized.mat',talker,cbsize)];
load(filename);




n_iters = 20;

se_factor_yu = sqrt(48);
se_factor = sqrt(n_iters);
yuvmean_xp1 = [0.454 0.698 0.301].*100;
yuvstd_xp1 = [0.264 0.210 0.146].*100./se_factor_yu;
yuvmean_xp2 = [0.4 0.58 0.24].*100;
yuvstd_xp2 = [0.247 0.277 0.203].*100./se_factor_yu;
yuvmean_xp3 = [0.45 0.73 0.40].*100;
yuvstd_xp3 = [0.30 0.24 0.30].*100./se_factor_yu;

if(redrawpics == 1)
    experiments = [1,2,3];
    chancelevs = [25,50,16.67];

    set(0,'defaultaxesfontsize',20);
    set(0,'defaulttextfontsize',20);


    h = figure('Position',[500 300 1400 400]);
    clf;
    for experiment_number = 1:3

        mean_single = mean(perf_single{experiment_number});
        mean_correct_both = mean(perf_both{experiment_number});
        mean_correct_either = mean(perf_either{experiment_number});

        std_single = std(perf_single{experiment_number});
        std_correct_both = std(perf_both{experiment_number});
        std_correct_either = std(perf_either{experiment_number});

        results = [mean_single;mean_correct_either;mean_correct_both].*100;
        result_devs = [std_single;std_correct_either;std_correct_both].*100;

        subplot(1,3,experiment_number);
        if(experiments(experiment_number) == 1)
            bardata = [results(:,1,end) results(:,2,end) yuvmean_xp1'];
        elseif(experiments(experiment_number) == 2)
            bardata = [results(:,1,end) results(:,2,end) yuvmean_xp2'];
        elseif(experiments(experiment_number) == 3)
            bardata = [results(:,1,end) results(:,2,end)  yuvmean_xp3'];
        end
        bar(bardata);
        %colormap([0.6 0.6 0.6;255/256 165/256 0;0.3 0.3 0.3])
        colormap([0.6 0.6 0.6;255/256 165/256 0;89/256 255/256 0.3])


        drawstds(h,(1:3)-0.22,results(:,1,end),result_devs(:,1,end)./se_factor,0.1,2,'red');
        drawstds(h,(1:3),results(:,2,end),result_devs(:,2,end)./se_factor,0.1,2,'red');
        if(experiments(experiment_number) == 1)
            drawstds(h,(1:3)+0.22,yuvmean_xp1,yuvstd_xp1,0.1,2,'red');
        elseif(experiments(experiment_number) == 2)
            drawstds(h,(1:3)+0.22,yuvmean_xp2,yuvstd_xp2,0.1,2,'red');
        elseif(experiments(experiment_number) == 3)
            drawstds(h,(1:3)+0.22,yuvmean_xp3,yuvstd_xp3,0.1,2,'red');
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


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% START ANALYSIS


load results/yurovsky_talker1_cb64_results_normalized.mat
realwords = 1;

wordtypes = {'single','either','both'};
variants = {'basic','attention-constrained'};

for k = 1:3
    for realwords = 0:1
    perf_single{k,realwords+1} = perf_single{k,realwords+1}.*100;
    perf_either{k,realwords+1} = perf_either{k,realwords+1}.*100;
    perf_both{k,realwords+1} = perf_both{k,realwords+1}.*100;
    perf_single_real{k,realwords+1} = perf_single_real{k,realwords+1}.*100;
    perf_either_real{k,realwords+1} = perf_either_real{k,realwords+1}.*100;
    perf_both_real{k,realwords+1} = perf_both_real{k,realwords+1}.*100;
    end
end

    chancelevs = [25,50,16.67];

for experiment = 1:3
    
    filename = sprintf('results/resultmatrix_talker%d_exp%d_cbsize%d.mat',talker,experiment,cbsize);
    load(filename);
    
    % Test if significant
    
    R = resultmatrix;
    fprintf('########## EXPERIMENT %d ##########\n',experiment);
%     for wordtype = 1:3
%         fprintf('EXP %d, wordtype %s, Basic: %0.2f%% (+- %0.2f%%). Constrained: %0.2f%% (+- %0.2f%%).\n',experiment,wordtypes{wordtype},R(1,(wordtype-1)*2+1),R(1,(wordtype-1)*2+2),R(2,(wordtype-1)*2+1),R(2,(wordtype-1)*2+2));
%     end
    
    fprintf('## stat-tests ##\n');
    for variant = 1:2
        [h,p,~,stat] = ttest(perf_single{experiment,realwords+1}(:,variant),chancelevs(1),0.05,'right');
        if(h == 1)
            fprintf('SINGLE WORDS: %s (%0.2f%% +-%0.2f%%) better than chance (%0.2f%%) (t(%d) = %0.4f, p = %0.4f).\n',variants{variant},mean(perf_single{experiment,realwords+1}(:,variant)),std(perf_single{experiment,realwords+1}(:,variant)),chancelevs(1),stat.df,stat.tstat,p);
        else
            fprintf('SINGLE WORDS: %s (%0.2f%% +-%0.2f%%) NOT better than chance (%0.2f%%) (t(%d) = %0.4f, p = %0.4f).\n',variants{variant},mean(perf_single{experiment,realwords+1}(:,variant)),std(perf_single{experiment,realwords+1}(:,variant)),chancelevs(1),stat.df,stat.tstat,p);
        end        
        [h,p,~,stat] = ttest(perf_either{experiment,realwords+1}(:,variant),chancelevs(2),0.05,'right');
        if(h == 1)
            fprintf('EITHER WORDS: %s (%0.2f%% +-%0.2f%%) better than chance (%0.2f%%) (t(%d) = %0.4f, p = %0.4f).\n',variants{variant},mean(perf_either{experiment,realwords+1}(:,variant)),std(perf_either{experiment,realwords+1}(:,variant)),chancelevs(2),stat.df,stat.tstat,p);
        else
            fprintf('EITHER WORDS: %s (%0.2f%% +-%0.2f%%) NOT better than chance (%0.2f%%) (t(%d) = %0.4f, p = %0.4f).\n',variants{variant},mean(perf_either{experiment}(:,variant)),std(perf_either{experiment}(:,variant)),chancelevs(2),stat.df,stat.tstat,p);
        end
        
        [h,p,~,stat] = ttest(perf_both{experiment,realwords+1}(:,variant),chancelevs(3),0.05,'right');
        if(h == 1)
            fprintf('BOTH WORDS: %s (%0.2f%% +-%0.2f%%) better than chance (%0.2f%%) (t(%d) = %0.4f, p = %0.4f).\n',variants{variant},mean(perf_both{experiment,realwords+1}(:,variant)),std(perf_both{experiment,realwords+1}(:,variant)),chancelevs(3),stat.df,stat.tstat,p);
        else
            fprintf('BOTH WORDS: %s (%0.2f%% +-%0.2f%%) NOT better than chance (%0.2f%%) (t(%d) = %0.4f, p = %0.4f).\n',variants{variant},mean(perf_both{experiment,realwords+1}(:,variant)),std(perf_both{experiment,realwords+1}(:,variant)),chancelevs(3),stat.df,stat.tstat,p);
        end
    end    
end

%% Guessing analysis
fprintf('\n\n########## GUESSING ANALYSIS ##########\n\n');
for experiment = 1:3
    fprintf('########## EXPERIMENT %d ##########\n',experiment);
    for variant = 1:2        
        [p12,h12,dih] = ranksum(perf_single_real{experiment,realwords+1}(:,variant,end),perf_both_real{experiment,realwords+1}(:,variant,end),0.05);
        if(h12) 
           fprintf('EXP %d / %s: Single (%0.2f%%) better than both (%0.2f%%) (z = %0.4f, p = %0.4f).\n',experiment,variants{variant},mean(perf_single_real{experiment,realwords+1}(:,variant)),mean(perf_both_real{experiment,realwords+1}(:,variant)),dih.ranksum,p12);
        else
            fprintf('EXP %d / %s: Single (%0.2f%%) NOT better than both (%0.2f%%) (z = %0.4f, p = %0.4f).\n',experiment,variants{variant},mean(perf_single_real{experiment,realwords+1}(:,variant)),mean(perf_both_real{experiment,realwords+1}(:,variant)),dih.ranksum,p12);
        end
    end
end

%% Test if difference to yurovsky results is significant

variant = 2;
for experiment = 1:3
    fprintf('########## EXPERIMENT %d ##########\n',experiment);
    for wordtype = 1:3
        if(wordtype == 1)
            data = perf_single{experiment,realwords+1}(:,variant,end);
        elseif(wordtype == 2)
            data = perf_either{experiment,realwords+1}(:,variant,end);
        else
            data = perf_both{experiment,realwords+1}(:,variant,end);
        end
        if(experiment == 1)
            [h,p,~,stat] = ttest(data,yuvmean_xp1(wordtype),0.05);
        elseif(experiment == 2)
            [h,p,~,stat] = ttest(data,yuvmean_xp2(wordtype),0.05);
        else
            [h,p,~,stat] = ttest(data,yuvmean_xp3(wordtype),0.05);
        end
           
        if(h)
            fprintf('EXP %d / %s: Difference between algorithm and Yurovsky is significant (t(%d) = %0.4f, p = %0.4f).\n',experiment,wordtypes{wordtype},stat.df,stat.tstat,p);
        else
            fprintf('EXP %d / %s: Difference between algorithm and Yurovsky NOT significant (t(%d) = %0.4f, p = %0.4f).\n',experiment,wordtypes{wordtype},stat.df,stat.tstat,p);
        end
    end    
end

% Redo final pics
load results/yurovsky_talker1_cb64_results_normalized.mat
realwords = 1;

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
        
    subplot(2,3,experiment_number);
    if(experiments(experiment_number) == 1)
        bardata = [results_novar(:,1,end) results(:,1,end) results_novar(:,2,end) results(:,2,end) yuvmean_xp1'];
    elseif(experiments(experiment_number) == 2)
        bardata = [results_novar(:,1,end) results(:,1,end) results_novar(:,2,end) results(:,2,end) yuvmean_xp2'];
    elseif(experiments(experiment_number) == 3)
        bardata = [results_novar(:,1,end) results(:,1,end) results_novar(:,2,end) results(:,2,end)  yuvmean_xp3'];
    end
    bar(bardata(:,[1 2 5]));
    %legend('Location','NorthWest',{'basic','basic+var','attention','attention+var','adults'});
    legend({'no acoustic var.';'acoustic var.';'human data'});
    %colormap([0.6 0.6 0.6;255/256 165/256 0;0.3 0.3 0.3])
    %colormap([0.6 0.6 0.6;255/256 165/256 0;89/256 255/256 0.3])
    colormap([0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3])
        
    drawstds(h,(1:3)-0.225,results_novar(:,1,end),result_devs_novar(:,1,end)./se_factor,0.03,2,'red');
    drawstds(h,(1:3)-0,results(:,1,end),result_devs(:,1,end)./se_factor,0.03,2,'red');
    %drawstds(h,(1:3),results_novar(:,2,end),result_devs_novar(:,1,end)./se_factor,0.03,2,'red');
    %drawstds(h,(1:3)+0.15,results(:,2,end),result_devs(:,2,end)./se_factor,0.03,2,'red');
    if(experiments(experiment_number) == 1)
        drawstds(h,(1:3)+0.225,yuvmean_xp1,yuvstd_xp1,0.03,2,'red');
    elseif(experiments(experiment_number) == 2)
        drawstds(h,(1:3)+0.225,yuvmean_xp2,yuvstd_xp2,0.03,2,'red');
    elseif(experiments(experiment_number) == 3)
        drawstds(h,(1:3)+0.225,yuvmean_xp3,yuvstd_xp3,0.03,2,'red');
    end
    
    grid;
    %set(gca,'XTickLabel',{'single','either','both'});
    ylabel('% correct');
    %title(sprintf('%s',experiments(experiment_number),variants{variant}));
    title(sprintf('condition #%d',experiment_number));
    line([0.5 1.5],[chancelevs(1) chancelevs(1)],'LineWidth',2,'Color','black','LineStyle','--');
    line([1.5 2.5],[chancelevs(2) chancelevs(2)],'LineWidth',2,'Color','black','LineStyle','--');
    line([2.5 3.5],[chancelevs(3) chancelevs(3)],'LineWidth',2,'Color','black','LineStyle','--');
    ylim([0 100]);
end

subplot(2,1,2);

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
        
    subplot(2,3,experiment_number+3);
    if(experiments(experiment_number) == 1)
        bardata = [results_novar(:,1,end) results(:,1,end) results_novar(:,2,end) results(:,2,end) yuvmean_xp1'];
    elseif(experiments(experiment_number) == 2)
        bardata = [results_novar(:,1,end) results(:,1,end) results_novar(:,2,end) results(:,2,end) yuvmean_xp2'];
    elseif(experiments(experiment_number) == 3)
        bardata = [results_novar(:,1,end) results(:,1,end) results_novar(:,2,end) results(:,2,end)  yuvmean_xp3'];
    end
    bar(bardata(:,[3 4 5]));
    legend({'no acoustic var.';'acoustic var.';'human data'});    
    colormap([0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3])
       
    
    drawstds(h,(1:3)-0.225,results_novar(:,2,end),result_devs_novar(:,1,end)./se_factor,0.03,2,'red');
    drawstds(h,(1:3)+0,results(:,2,end),result_devs(:,2,end)./se_factor,0.03,2,'red');
    if(experiments(experiment_number) == 1)
        drawstds(h,(1:3)+0.225,yuvmean_xp1,yuvstd_xp1,0.03,2,'red');
    elseif(experiments(experiment_number) == 2)
        drawstds(h,(1:3)+0.225,yuvmean_xp2,yuvstd_xp2,0.03,2,'red');
    elseif(experiments(experiment_number) == 3)
        drawstds(h,(1:3)+0.225,yuvmean_xp3,yuvstd_xp3,0.03,2,'red');
    end
    
    grid;
    set(gca,'XTickLabel',{'single','either','both'});
    ylabel('% correct');    
    line([0.5 1.5],[chancelevs(1) chancelevs(1)],'LineWidth',2,'Color','black','LineStyle','--');
    line([1.5 2.5],[chancelevs(2) chancelevs(2)],'LineWidth',2,'Color','black','LineStyle','--');
    line([2.5 3.5],[chancelevs(3) chancelevs(3)],'LineWidth',2,'Color','black','LineStyle','--');
    ylim([0 100]);
end


