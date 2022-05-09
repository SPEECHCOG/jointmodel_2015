b = figure('Position',[500 300 1000 350]);

subplot(1,2,1);

load results_64.mat fscore_baseline fscore_control_split fscore_control_full

set(0,'defaultaxesfontsize',20);
set(0,'defaulttextfontsize',20);


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

subplot(1,2,2);

load results.mat fscore_baseline fscore_control_split fscore_control_full

set(0,'defaultaxesfontsize',20);
set(0,'defaulttextfontsize',20);


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
