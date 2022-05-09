function [data_train,tags_train,data_test,tags_test,taginds,train_filenames,test_filenames,testpoints,taginds_double,taginds_single,SWORD,DWORD] = ...
    getSmithDataset(exp_number,tags,data,filenames,tagnames,annotated_bounds,annotated_words,annotated_wordnames,iter,realwords)


train_filenames = {};
test_filenames = {};

word_minlen = 25;
noiselength = 26;

if(exp_number == 1)        
    n_words = 2;
    trials = 54;        
    unique_words = 18;
elseif(exp_number == 2)    
    n_words = 3;
    trials = 36;      
    unique_words = 18;
elseif(exp_number == 3)    
    n_words = 4;
    trials = 27;    
    unique_words = 18;
elseif(exp_number == 4)
    n_words = 4;
    trials = 18;
    unique_words = 9;
elseif(exp_number == 5)
    n_words = 4;
    trials = 27;
    unique_words = 9;
elseif(exp_number == 6)
    n_words = 4;
    trials = 27;
    unique_words = 18;    
end

repetitions = trials.*n_words/unique_words;
    
available_words = 1:50;  % Keywords 1-50

% Choose single words
tmp = randperm(length(available_words));
single_words = available_words(tmp(1:18));


% Extract single words
SWORD = cell(unique_words,repetitions+2);
word = 1;
while word < unique_words+1
    [rows,cols] = find(tags == single_words(word));
    rows = unique(rows);
    token = 1;
    j = 1;
    while token < repetitions+3
        bounds = round(annotated_bounds{rows(j),1}.*100);
        reftags = annotated_words(rows(j),:);
        reftags(reftags == 0) = [];
        reftags = annotated_wordnames(reftags);
        truetag_name = tagnames(single_words(word));
        tmp = find(strncmp(reftags,truetag_name,length(truetag_name)) == 1);
        starttime = bounds(tmp);
        endtime = bounds(tmp+1);
        if(endtime-starttime > word_minlen)
            SWORD{word,token} = data{rows(j)}(starttime:endtime);
            token = token+1;
        end
        j = j+1;
    end
    word = word+1;
end

tags_train = zeros(trials,5);
data_train = cell(trials,1);

singlecounts = ones(unique_words,1);

count = 1;

% Randomize SWORD set

SWORD_N = cell(size(SWORD));
orderi = randperm(size(SWORD,2));

for j = 1:size(SWORD,1)
    for k = 1:size(SWORD,2)
       SWORD_N{j,k} = SWORD{j,orderi(k)}; 
    end    
end

SWORD = SWORD_N;

% Generate single word utterances

for utterance = 1:trials
    wordstoadd = cell(n_words,1);
    tagstoadd = [];
    
    scount = 0;
    j = 1;
    while length(tagstoadd) < n_words % Run until four words are chosen
                
        if(utterance ~= trials && scount ~= n_words-1)
            o_single = randi(unique_words);
        else
            [meh,o_single] = min(singlecounts);
        end
        % Check that the word does not already exist in the set
        if(isempty(intersect(single_words(o_single),tagstoadd)) && scount < n_words)
            if(singlecounts(o_single(1)) < repetitions+1)
                if(realwords)
                    wordstoadd{j} = SWORD{o_single(1),singlecounts(o_single(1))};
                else
                    wordstoadd{j} = SWORD{o_single(1),1};
                end
                singlecounts(o_single(1)) = singlecounts(o_single(1))+1;
                tagstoadd = [tagstoadd single_words(o_single(1))];
                j = j+1;
                scount = scount+1;
            end
        end
                
        count = count+1;
        if(count > 2000) % Stop iterating if does not end up with proper set. Retry at calling level.
            error('fail')
        end        
    end
    
    % Concatenate words by adding white noise sequence in the
    % beginning, between, and after words.
    cbsize = max(cellfun(@max,data));
    o = randperm(n_words);
    data_train{utterance} = randi(cbsize,noiselength,1);
    for k = 1:n_words        
        data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1);wordstoadd{o(k)}];
    end
    data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1)];
    tags_train(utterance,1:n_words) = tagstoadd;
end

dataorder = randperm(length(data_train));

data_train = data_train(dataorder);
tags_train = tags_train(dataorder,:);

%% Generate test set
% 4 tokens of each word type
data_test = cell(72,1);
tags_test= zeros(72,4);
utterance = 1;
for word = 1:unique_words
    for token = 1:2
        if(realwords)
            data_test{utterance} = SWORD{word,token+repetitions};
        else            
            data_test{utterance} = SWORD{word,1};
        end
        tags_test(utterance,1) = single_words(word);
        
        tmp = setxor(1:unique_words,word);
        daa = randperm(unique_words-1);
        tags_test(utterance,2:4) = single_words(tmp(daa(1:3)));
        utterance = utterance+1;
    end
end

taginds_single = single_words;
DWORD = {};
taginds_double = [];
taginds = taginds_single;

testpoints = length(tags_train);

