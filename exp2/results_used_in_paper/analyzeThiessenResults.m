function analyzeThiessenResults

b = figure('Position',[500 300 1200 350]);
load thiessen_task_results_32.mat
res = cell(2,1);
for cond = 1:2
    tmp = [squeeze(perf(cond,1,:,:));squeeze(perf(cond,2,:,:))]; % Combine across the two streams
    res{cond} = tmp;
end

perf = tmp;

thies_results = [8.9 12 9.8]./16.*100;
thies_devs = [2 2.6 3]./16.*100/sqrt(20);

%shift1 = 0.275;
%shift2 = 0.275/3;
shift1 = 0.225;

subplot(1,2,1);
%bar([mean(res{1})'.*100 mean(res{2})'.*100 mean(res{3})'.*100 thies_results']);
bar([mean(res{1})'.*100 mean(res{2})'.*100 thies_results']);
legend('Location','SouthEast',{'sync','async','adults'});
drawstds(b,(1:3)-shift1,mean(res{1}).*100,std(res{1}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)-shift2,mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3),mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)+shift2,mean(res{3}).*100,std(res{3}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3)+shift1,thies_results,thies_devs,0.05,2,'red');
set(gca,'XTickLabel',{'no visual';'consistent visual';'random visual'});
line([0 4],[50 50],'LineStyle','--','LineWidth',2','Color','black');
grid;
xlim([0.5 3.5])
xlabel('condition');
ylabel('performance (%)');
colormap([0.3 0.3 0.3;0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3])


load thiessen_task_results_64_new.mat
res = cell(2,1);
for cond = 1:2
    tmp = [squeeze(perf(cond,1,:,:));squeeze(perf(cond,2,:,:))]; % Combine across the two streams
    res{cond} = tmp;
end

perf = tmp;

thies_results = [8.9 12 9.8]./16.*100;
thies_devs = [2 2.6 3]./16.*100/sqrt(20);

%shift1 = 0.275;
%shift2 = 0.275/3;
shift1 = 0.225;

subplot(1,2,2);
%bar([mean(res{1})'.*100 mean(res{2})'.*100 mean(res{3})'.*100 thies_results']);
bar([mean(res{1})'.*100 mean(res{2})'.*100 thies_results']);
legend('Location','SouthEast',{'sync','async','adults'});
drawstds(b,(1:3)-shift1,mean(res{1}).*100,std(res{1}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)-shift2,mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3),mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)+shift2,mean(res{3}).*100,std(res{3}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3)+shift1,thies_results,thies_devs,0.05,2,'red');
set(gca,'XTickLabel',{'no visual';'consistent visual';'random visual'});
line([0 4],[50 50],'LineStyle','--','LineWidth',2','Color','black');
grid;
xlim([0.5 3.5])
xlabel('condition');
ylabel('performance (%)');
colormap([0.3 0.3 0.3;0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3])



%% V2

b = figure('Position',[500 300 1200 350]);
load thiessen_task_results_32_new.mat
res = cell(2,1);
for cond = 1:2
    tmp = [squeeze(perf(cond,1,:,:));squeeze(perf(cond,2,:,:))]; % Combine across the two streams
    res{cond} = tmp;
end

perf = tmp;

thies_results = [8.9 12 9.8]./16.*100;
thies_devs = [2 2.6 3]./16.*100/sqrt(20);

%shift1 = 0.275;
%shift2 = 0.275/3;
shift1 = 0.225;

subplot(1,3,1);
%bar([mean(res{1})'.*100 mean(res{2})'.*100 mean(res{3})'.*100 thies_results']);
bar([mean(res{1})'.*100 mean(res{2})'.*100 thies_results']);
title('|\itA\rm| = 32');
legend('Location','SouthEast',{'sync','async 0-200 ms','adults'});
drawstds(b,(1:3)-shift1,mean(res{1}).*100,std(res{1}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)-shift2,mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3),mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)+shift2,mean(res{3}).*100,std(res{3}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3)+shift1,thies_results,thies_devs,0.05,2,'red');
%set(gca,'XTickLabel',{'no visual';'consistent visual';'random visual'});
set(gca,'XTick',[]);
text(1,-8,sprintf('no\nvisual'),'HorizontalAlignment','center')
text(2,-8,sprintf('cons.\nvisual'),'HorizontalAlignment','center')
text(3,-8,sprintf('rand.\nvisual'),'HorizontalAlignment','center')
line([0 4],[50 50],'LineStyle','--','LineWidth',2','Color','black');
grid;
xlim([0.5 3.5])
%xlabel('condition');
ylabel('performance (%)');
colormap([0.3 0.3 0.3;0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3])


load thiessen_task_results_64_new.mat
res = cell(2,1);
for cond = 1:2
    tmp = [squeeze(perf(cond,1,:,:));squeeze(perf(cond,2,:,:))]; % Combine across the two streams
    res{cond} = tmp;
end

perf = tmp;

thies_results = [8.9 12 9.8]./16.*100;
thies_devs = [2 2.6 3]./16.*100/sqrt(20);

%shift1 = 0.275;
%shift2 = 0.275/3;
shift1 = 0.225;

subplot(1,3,2);
%bar([mean(res{1})'.*100 mean(res{2})'.*100 mean(res{3})'.*100 thies_results']);
bar([mean(res{1})'.*100 mean(res{2})'.*100 thies_results']);
title('|\itA\rm| = 64');
legend('Location','SouthEast',{'sync','async 0-200 ms','adults'});
drawstds(b,(1:3)-shift1,mean(res{1}).*100,std(res{1}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)-shift2,mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3),mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)+shift2,mean(res{3}).*100,std(res{3}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3)+shift1,thies_results,thies_devs,0.05,2,'red');
%set(gca,'XTickLabel',{'no visual';'consistent visual';'random visual'});
set(gca,'XTick',[]);
text(1,-8,sprintf('no\nvisual'),'HorizontalAlignment','center')
text(2,-8,sprintf('cons.\nvisual'),'HorizontalAlignment','center')
text(3,-8,sprintf('rand.\nvisual'),'HorizontalAlignment','center')
line([0 4],[50 50],'LineStyle','--','LineWidth',2','Color','black');
grid;
xlim([0.5 3.5])
%xlabel('condition');
ylabel('performance (%)');
colormap([0.3 0.3 0.3;0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3])





load thiessen_task_results_64_infant.mat
res = cell(2,1);
for cond = 1:2
    tmp = [squeeze(perf(cond,1,:,:));squeeze(perf(cond,2,:,:))]; % Combine across the two streams
    res{cond} = tmp;
end

perf = tmp;

thies_results = [8.9 12 9.8]./16.*100;
thies_devs = [2 2.6 3]./16.*100/sqrt(20);

%shift1 = 0.275;
%shift2 = 0.275/3;
shift1 = 0.15;

subplot(1,3,3);
%bar([mean(res{1})'.*100 mean(res{2})'.*100 mean(res{3})'.*100 thies_results']);
bar([mean(res{1})'.*100 mean(res{2})'.*100]); 
title('|\itA\rm| = 64 ("infant")');
legend('Location','SouthEast',{'async 200 ms','async 0-400 ms'});
drawstds(b,(1:3)-shift1,mean(res{1}).*100,std(res{1}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)-shift2,mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
drawstds(b,(1:3)+shift1,mean(res{2}).*100,std(res{2}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)+shift2,mean(res{3}).*100,std(res{3}).*100./sqrt(n_iters*2),0.05,2,'red');
%drawstds(b,(1:3)+shift1,thies_results,thies_devs,0.05,2,'red');
%set(gca,'XTickLabel',{'no visual';'consistent visual';'random visual'});
set(gca,'XTick',[]);
text(1,-8,sprintf('no\nvisual'),'HorizontalAlignment','center')
text(2,-8,sprintf('cons.\nvisual'),'HorizontalAlignment','center')
text(3,-8,sprintf('rand.\nvisual'),'HorizontalAlignment','center')
line([0 4],[50 50],'LineStyle','--','LineWidth',2','Color','black');
grid;
xlim([0.5 3.5])
%xlabel('condition');
ylabel('performance (%)');
colormap([0.3 0.3 0.3;0.1 0.3 0.5;255/256 165/256 0;89/256 255/256 0.3]);

% Statistical tests

load thiessen_task_results_32_new.mat
res = cell(2,1);
for cond = 1:2
    tmp = [squeeze(perf(cond,1,:,:));squeeze(perf(cond,2,:,:))]; % Combine across the two streams
    res{cond} = tmp;
end

perf = tmp;

[a,b,c,stats] = ttest(perf(:,1),perf(:,2))