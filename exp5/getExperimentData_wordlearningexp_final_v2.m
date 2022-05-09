function [data_train,tags_train,data_test,tags_test,taginds,train_filenames,test_filenames,testpoints,testinds] = getExperimentData_wordlearningexp(exp_number,tags,data,filenames,tagnames,noiselevel)

if nargin <6
    noiselevel =0;
end
% Input: experiment number, CAREGIVER Y2 tags, labels, and filenames.
%
% Output: data, tags and filenimes divided into training and testing data
% testpoints: moments where performance is probed

if(exp_number == 1) % Basic test with N tags and M referents
      % Randomize data order each time
    fileinds = 1:size(tags,1);
    orderi = randperm(size(tags,1));
    tags = tags(orderi,:);
    data = data(orderi);
    filenames = filenames(orderi);
    fileinds = fileinds(orderi);
    
    % Remove all signals with only one referent
    meh = tags;
    meh(meh > 0) = 1;    
    a = find(sum(meh,2) > 1);
    tags = tags(a,:);
    data = data(a);
    filenames = filenames(a);
    fileinds = fileinds(a);
    
    % Divide into training and testing data from middle (ensure that a same
    % utterance is not in the training and testing set)
    half = round(size(tags,1)./2);
    tags_train = tags(1:half,:);
    tags_test = tags(half+1:end,:);
    data_train = data(1:half);
    data_test = data(half+1:end);
    testinds = fileinds(half+1:end);
    
    taginds = 1:50;
    
    train_filenames = filenames(1:half);
    test_filenames = filenames(half+1:end);
    
    % Add noise to tags
    
    a = find(tags_train > 0);
    o = randperm(length(a));
    tonoise = round(noiselevel.*length(a));
    tags_train(a(o(1:tonoise))) = randi(50,tonoise,1);
    
        
    testpoints = round([1 0.01*length(data_train) 0.05*length(data_train) 0.1*length(data_train)  0.2*length(data_train)  0.5*length(data_train) length(data_train)]);
    %testpoints = round([0.1*length(data_train) length(data_train)]);

elseif(exp_number == 2) % Full ACORNS Y2 data
        
    % Randomize data order each time
    fileinds = 1:size(tags,1);
    orderi = randperm(size(tags,1));
    tags = tags(orderi,:);
    data = data(orderi);
    filenames = filenames(orderi);
    fileinds = fileinds(orderi);
    
    % Divide into training and testing data from middle (ensure that a same
    % utterance is not in the training and testing set)
    half = round(size(tags,1)./2);
    tags_train = tags(1:half,:);
    tags_test = tags(half+1:end,:);
    data_train = data(1:half);
    data_test = data(half+1:end);
    testinds = fileinds(half+1:end);
          
    taginds = 1:50;
    
    train_filenames = filenames(1:half);
    test_filenames = filenames(half+1:end);
        
    testpoints = round([1 0.01*length(data_train) 0.05*length(data_train) 0.1*length(data_train)  0.2*length(data_train)  0.5*length(data_train) length(data_train)]);
        
else
    error('unknown experiment number');
end

