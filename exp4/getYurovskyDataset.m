function [data_train,tags_train,data_test,tags_test,taginds,train_filenames,test_filenames,testpoints,taginds_double,taginds_single,SWORD,DWORD] = ...
    getYurovskyDataset(exp_number,tags,data,filenames,tagnames,annotated_bounds,annotated_words,annotated_wordnames,iter,realwords)


curdir = pwd;

train_filenames = {};
test_filenames = {};

word_minlen = 25;

noiselength = 26;

tokentouse = 1;
if(realwords == 0)
    samestimuli = 1;
else
    samestimuli = 0;
end

if(exp_number == 1)
    
     
    available_words = 1:50;  % Keywords 1-50
    
    % Choose single words
    tmp = randperm(length(available_words));
    single_words = available_words(tmp(1:6));
    available_words(single_words) = [];
    % Choose double words
    tmp = randperm(length(available_words));
    double_words = available_words(tmp(1:6));
    for k = 1:length(double_words)
        available_words(available_words == double_words(k)) = [];
    end    
    for j = 1:length(double_words)
        available_words(available_words == double_words(j)) = [];
    end
    
    % Choose noise words
    tmp = randperm(length(available_words));
    noise_words = available_words(tmp(1:6));
    for k = 1:length(noise_words)
        available_words(available_words == noise_words(k)) = [];
    end
    for j = 1:length(noise_words)
        available_words(available_words == noise_words(j)) = [];
    end
    
    
    % Get referent tags for new words
    for k = 1:6
        new_double_word_indices = available_words(1:6);
    end
    
    % Extract single words
    SWORD = cell(6,12);
    word = 1;
    while word < 7
        [rows,cols] = find(tags == single_words(word));
        rows = unique(rows);
        token = 1;
        j = 1;
        while token < 13
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
    
    % Extract double words
    DWORD = cell(6,18);
    word = 1;
    while word < 7
        [rows,cols] = find(tags == double_words(word));
        rows = unique(rows);
        token = 1;
        j = 1;
        while token < 19
            bounds = round(annotated_bounds{rows(j),1}.*100);
            reftags = annotated_words(rows(j),:);
            reftags(reftags == 0) = [];
            reftags = annotated_wordnames(reftags);
            truetag_name = tagnames(double_words(word));
            tmp = find(strncmp(reftags,truetag_name,length(truetag_name)) == 1);
            starttime = bounds(tmp);
            endtime = bounds(tmp+1);
            if(endtime-starttime > word_minlen)
                DWORD{word,token} = data{rows(j)}(starttime:endtime);
                token = token+1;
            end
            j = j+1;
        end
        word = word+1;
    end
    
      % Extract noise words
    NWORD = cell(6,18);
    word = 1;
    while word < 7
        [rows,cols] = find(tags == noise_words(word));
        rows = unique(rows);
        token = 1;
        j = 1;
        while token < 19
            bounds = round(annotated_bounds{rows(j),1}.*100);
            reftags = annotated_words(rows(j),:);
            reftags(reftags == 0) = [];
            reftags = annotated_wordnames(reftags);
            truetag_name = tagnames(noise_words(word));
            tmp = find(strncmp(reftags,truetag_name,length(truetag_name)) == 1);
            starttime = bounds(tmp);
            endtime = bounds(tmp+1);
            if(endtime-starttime > word_minlen)
                NWORD{word,token} = data{rows(j)}(starttime:endtime);
                token = token+1;
            end
            j = j+1;
        end
        word = word+1;
    end
    
    tags_train = zeros(27,5);
    data_train = cell(27,1);
        
    singlecounts = ones(6,1);
    doublecounts = ones(6,1);
    noisecounts = ones(6,1);
    count = 1;
        
    % Generate single word utterances
    for utterance = 1:2
        wordstoadd = cell(4,1);
        o_single = randperm(6);
        tagstoadd = [];
        for j = 1:4         
            if(samestimuli == 0)
                wordstoadd{j} = SWORD{o_single(j),singlecounts(o_single(j))};
            else
                wordstoadd{j} = SWORD{o_single(j),tokentouse};
            end
            singlecounts(o_single(j)) = singlecounts(o_single(j))+1;
            tagstoadd = [tagstoadd single_words(o_single(j))];
        end        
        
        % Concatenate words by adding white noise sequence in the
        % beginning, between, and after words.
        cbsize = max(cellfun(@max,data));
        o = randperm(4);
        data_train{utterance} = randi(cbsize,noiselength,1);
        for k = 1:4
            data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1);wordstoadd{o(k)}];
        end
        data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1)];
        
        tags_train(utterance,1:4) = tagstoadd;
    end
    

    for utterance = 3:16
        wordstoadd = cell(4,1);
        tagstoadd = [];
        
        scount = 0;
        dcount = 0;
        ncount = 0;
        j = 1;
        while length(tagstoadd) < 4 % Run until four words are chosen
            
                
                o_single = randi(6);
                % Check that the word does not already exist in the set
                if(isempty(intersect(single_words(o_single),tagstoadd)) && scount < 2)
                    if(singlecounts(o_single(1)) < 7)
                        if(samestimuli == 0)
                            wordstoadd{j} = SWORD{o_single(1),singlecounts(o_single(1))};
                        else
                            wordstoadd{j} = SWORD{o_single(1),singlecounts(o_single(1))};
                        end
                        singlecounts(o_single(1)) = singlecounts(o_single(1))+1;
                        tagstoadd = [tagstoadd single_words(o_single(1))];
                        j = j+1;
                        scount = scount+1;
                    end
                end
            
            
            if(dcount == 0) % add double word if less than four words currently
                o_double = randi(6);
                
                % Check that the double word does not exist in the same set
                % already (neither of the two referents).
                
                if(doublecounts(o_double(1)) < 7)
                    if(samestimuli == 0)
                        wordstoadd{j} = DWORD{o_double(1),doublecounts(o_double(1))};
                    else
                        wordstoadd{j} = DWORD{o_double(1),tokentouse};
                    end
                        
                    doublecounts(o_double(1)) = doublecounts(o_double(1))+1;                    
                    tagstoadd = [tagstoadd double_words(o_double(1))];                    
                    tagstoadd = [tagstoadd new_double_word_indices(o_double(1))];                    
                    dcount = dcount+1;
                    j = j+1;
                end
            
            end
            
             if(ncount == 0) % add noise word if less than four words currently
                o_noise = randi(6);
                
                % Check that the double word does not exist in the same set
                % already (neither of the two referents).
                
                if(noisecounts(o_noise(1)) < 7)
                    if(samestimuli == 0)
                        wordstoadd{j} = NWORD{o_noise(1),noisecounts(o_noise(1))};
                    else
                        wordstoadd{j} = NWORD{o_noise(1),tokentouse};
                    end
                        
                    noisecounts(o_noise(1)) = noisecounts(o_noise(1))+1;                                        
                    ncount = ncount+1;
                    j = j+1;
                end
            
            end
            
            
            
            
            count = count+1;
            if(count > 200) % Stop iterating if does not end up with proper set. Retry at calling level.
                error('fail')
            end
      
            
        end
                      
        
        % Concatenate words by adding white noise sequence in the
        % beginning, between, and after words.
        cbsize = max(cellfun(@max,data));
        o = randperm(4);
        data_train{utterance} = randi(cbsize,noiselength,1);
        for k = 1:4
            data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1);wordstoadd{o(k)}];
        end
        data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1)];        
        tags_train(utterance,1:4) = tagstoadd;        
    end
    
    for utterance = 17:27
        wordstoadd = cell(4,1);
        tagstoadd = [];
        
        scount = 0;
        dcount = 0;
        ncount = 0;
        j = 1;
        while length(tagstoadd) < 4 % Run until four words are chosen
            
            
            if(dcount < 2) % add double word if less than four words currently
                
                o_double = randi(6);
                
                % Check that the double word does not exist in the same set
                % already (neither of the two referents).
                if(isempty(intersect(double_words(o_double),tagstoadd)) && isempty(intersect(new_double_word_indices(o_double),tagstoadd)))
                if(doublecounts(o_double(1)) < 7)
                    if(samestimuli == 0)
                        wordstoadd{j} = DWORD{o_double(1),doublecounts(o_double(1))};
                    else
                        wordstoadd{j} = DWORD{o_double(1),tokentouse};
                    end
                    doublecounts(o_double(1)) = doublecounts(o_double(1))+1;                    
                    tagstoadd = [tagstoadd double_words(o_double(1))];                    
                    tagstoadd = [tagstoadd new_double_word_indices(o_double(1))];                    
                    dcount = dcount+1;
                    j = j+1;
                end
                end
            
            end
            
             if(ncount < 2) % add double word if less than four words currently
                o_noise = randi(6);
                
                % Check that the double word does not exist in the same set
                % already (neither of the two referents).
                
                if(noisecounts(o_noise(1)) < 7)
                    if(samestimuli == 0)
                        wordstoadd{j} = NWORD{o_noise(1),noisecounts(o_noise(1))};
                    else                        
                        wordstoadd{j} = NWORD{o_noise(1),tokentouse};
                    end
                    noisecounts(o_noise(1)) = noisecounts(o_noise(1))+1;                                        
                    ncount = ncount+1;
                    j = j+1;
                end            
            end
            
            
            count = count+1;
            if(count > 200) % Stop iterating if does not end up with proper set. Retry at calling level.
                error('fail')
            end            
        end
        
        % Concatenate words by adding white noise sequence in the
        % beginning, between, and after words.
        cbsize = max(cellfun(@max,data));
        o = randperm(4);
        data_train{utterance} = randi(cbsize,noiselength,1);
        for k = 1:4
            data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1);wordstoadd{o(k)}];
        end
        data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1)];        
        tags_train(utterance,1:4) = tagstoadd;        
    end
    
    dataorder = randperm(27);
    
    data_train = data_train(dataorder);
    tags_train = tags_train(dataorder,:);
    
    taginds_double = [double_words' new_double_word_indices'];
    
    %% Generate test set
    % 6 tokens of each word type
    data_test = cell(72,1);
    tags_test= zeros(72,4);
    utterance = 1;
    for word = 1:6
        for token = 1:6
            if(samestimuli == 0)
                data_test{utterance} = SWORD{word,token+6};
            else                
                data_test{utterance} = SWORD{word,tokentouse};
            end
            tags_test(utterance,1) = single_words(word);
            
            tmp = setxor(1:6,word);
            daa = randperm(5);
            tags_test(utterance,2:4) = single_words(tmp(daa(1:3)));
            utterance = utterance+1;
            if(samestimuli == 0)
                data_test{utterance} = DWORD{word,token+12};
            else                
                data_test{utterance} = DWORD{word,tokentouse};
            end
            tags_test(utterance,1) = double_words(word);
            tags_test(utterance,2) = new_double_word_indices(word);
            
            tmp = setxor(1:6,word);
            o = randperm(5);
            
            tmp = tmp(o(1:2));
            r = randi(2,2,1);
            incorrect_doubleref(1) = taginds_double(tmp(1),r(1));
            incorrect_doubleref(2) = taginds_double(tmp(2),r(2));
            
            tags_test(utterance,3:4) = incorrect_doubleref;
            
            utterance = utterance+1;
        end
    end
    
    taginds = [single_words double_words noise_words new_double_word_indices];
    taginds_single = single_words;
    taginds_double = [double_words' new_double_word_indices'];
    
    testpoints = 27;
    filename = [curdir '/data/' sprintf('exp1set_iter%d',iter)];
    
    save(filename,'data_train','tags_train','data_test','tags_test','taginds','train_filenames','test_filenames','testpoints','taginds_double','taginds_single','SWORD','DWORD');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% EXPERIMENT 2 STARTS HERE
elseif(exp_number == 2)
    
    available_words = 1:50;  % Keywords 1-50
    
    % Choose single words
    tmp = randperm(length(available_words));
    single_words = available_words(tmp(1:6));
    available_words(single_words) = [];
    % Choose double words
    tmp = randperm(length(available_words));
    double_words = available_words(tmp(1:6));
    for k = 1:length(double_words)
        available_words(available_words == double_words(k)) = [];
    end
    
    % Get referent tags for new words
    for k = 1:6
        new_double_word_indices = available_words(1:6);
    end
    
    % Extract single words
    SWORD = cell(6,12);
    word = 1;
    while word < 7
        [rows,cols] = find(tags == single_words(word));
        rows = unique(rows);
        token = 1;
        j = 1;
        while token < 13
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
    
    % Extract double words
    DWORD = cell(6,18);
    word = 1;
    while word < 7
        [rows,cols] = find(tags == double_words(word));
        rows = unique(rows);
        token = 1;
        j = 1;
        while token < 19
            bounds = round(annotated_bounds{rows(j),1}.*100);
            reftags = annotated_words(rows(j),:);
            reftags(reftags == 0) = [];
            reftags = annotated_wordnames(reftags);
            truetag_name = tagnames(double_words(word));
            tmp = find(strncmp(reftags,truetag_name,length(truetag_name)) == 1);
            starttime = bounds(tmp);
            endtime = bounds(tmp+1);
            if(endtime-starttime > word_minlen)
                DWORD{word,token} = data{rows(j)}(starttime:endtime);
                token = token+1;
            end
            j = j+1;
        end
        word = word+1;
    end
    
    tags_train = zeros(27,5);
    data_train = cell(27,1);
    
    
    
    singlecounts = ones(6,1);
    doublecounts = ones(6,1);
    count = 1;
    
    for utterance = 1:27
        wordstoadd = cell(4,1);
        tagstoadd = [];
        
        j = 1;
        while length(tagstoadd) < 4 % Run until four words are chosen
            if(randi(2) == 2)   % Take a single word every second loop (on average) time (2/3 are double words)
                
                o_single = randi(6);
                % Check that the word does not already exist in the set
                if(isempty(intersect(single_words(o_single),tagstoadd)))
                    if(singlecounts(o_single(1)) < 7)
                        if(samestimuli == 0)
                            wordstoadd{j} = SWORD{o_single(1),singlecounts(o_single(1))};
                        else
                            wordstoadd{j} = SWORD{o_single(1),tokentouse};
                        end
                        singlecounts(o_single(1)) = singlecounts(o_single(1))+1;
                        tagstoadd = [tagstoadd single_words(o_single(1))];
                        j = j+1;
                    end
                end
            end
            
            if(length(tagstoadd) < 4) % add double word if less than four words currently
                o_double = randi(6);
                
                % Check that the double word does not exist in the same set
                % already (neither of the two referents).
                if(isempty(intersect(double_words(o_double),tagstoadd)) && isempty(intersect(new_double_word_indices(o_double),tagstoadd)))
                    if(doublecounts(o_double(1)) < 13)
                        if(samestimuli == 0)
                            wordstoadd{j} = DWORD{o_double(1),doublecounts(o_double(1))};
                        else
                            wordstoadd{j} = DWORD{o_double(1),tokentouse};
                        end
                        doublecounts(o_double(1)) = doublecounts(o_double(1))+1;
                        if(rem(doublecounts(o_double(1)),2) == 0)
                            tagstoadd = [tagstoadd double_words(o_double(1))];
                        else
                            tagstoadd = [tagstoadd new_double_word_indices(o_double(1))];
                        end
                        j = j+1;
                    end
                end
            end
            count = count+1;
            if(count > 200) % Stop iterating if does not end up with proper set. Retry at calling level.
                error('fail')
            end            
        end
        
        % Concatenate words by adding white noise sequence in the
        % beginning, between, and after words.
        cbsize = max(cellfun(@max,data));
        o = randperm(4);
        data_train{utterance} = randi(cbsize,noiselength,1);
        for k = 1:4
            data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1);wordstoadd{o(k)}];
        end
        data_train{utterance} = [data_train{utterance};randi(cbsize,noiselength,1)];
        
        tags_train(utterance,1:4) = tagstoadd;
        
    end
    
    taginds_double = [double_words' new_double_word_indices'];
    
    %% Generate test set
    % 6 tokens of each word type
    data_test = cell(72,1);
    tags_test= zeros(72,4);
    utterance = 1;
    for word = 1:6
        for token = 1:6
            if(samestimuli == 0)
                data_test{utterance} = SWORD{word,token+6};
            else
                
                data_test{utterance} = SWORD{word,tokentouse};
            end
            tags_test(utterance,1) = single_words(word);
            
            tmp = setxor(1:6,word);
            daa = randperm(5);
            tags_test(utterance,2:4) = single_words(tmp(daa(1:3)));
            utterance = utterance+1;
            if(samestimuli == 0)
                data_test{utterance} = DWORD{word,token+12};
            else
                
                data_test{utterance} = DWORD{word,tokentouse};
            end
            tags_test(utterance,1) = double_words(word);
            tags_test(utterance,2) = new_double_word_indices(word);
            
            tmp = setxor(1:6,word);
            o = randperm(5);
            
            tmp = tmp(o(1:2));
            r = randi(2,2,1);
            incorrect_doubleref(1) = taginds_double(tmp(1),r(1));
            incorrect_doubleref(2) = taginds_double(tmp(2),r(2));
            
            tags_test(utterance,3:4) = incorrect_doubleref;
            
            utterance = utterance+1;
        end
    end
    
    taginds = [single_words double_words new_double_word_indices];
    taginds_single = single_words;
    taginds_double = [double_words' new_double_word_indices'];
    
    testpoints = 27;
    if(samestimuli == 1)
        filename = [curdir '/data/' sprintf('exp2set_iter%d_same',iter)];
    else
        filename = [curdir '/data/' sprintf('exp2set_iter%d_different',iter)];
    end
    
    save(filename,'data_train','tags_train','data_test','tags_test','taginds','train_filenames','test_filenames','testpoints','taginds_double','taginds_single','SWORD','DWORD');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% EXPERIMENT 3 STARTS HERE
elseif(exp_number == 3)
    
    if(samestimuli == 1)
        filename = [curdir '/data/' sprintf('exp2set_iter%d_same',iter)];
    else
        filename = [curdir '/data/' sprintf('exp2set_iter%d_different',iter)];
    end
    load(filename);
    
    % Load experiment 2 dataset and reorder labeling
    
    % Rewrite tags
    
    for k = 1:6
        a = find(tags_train == taginds_double(k,2));
        tags_train(a) = taginds_double(k,1);
    end
    
    for k = 1:6
        [rows,cols] = find(tags_train == taginds_double(k,1));
        [rows,ord] = sort(rows,'ascend');
        cols = cols(ord);
        for j = round(length(rows)/2)+1:length(rows)         % Replace every second with the another index
            tags_train(rows(j),cols(j)) = taginds_double(k,2);
        end
    end
    
end

