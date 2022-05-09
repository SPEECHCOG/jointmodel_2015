function [seg_errors,seg_lens] = evaSegCorrect(p,locs,bounds,truetags)

% Find segmentation points

[maxvalues,winners] = max(p,[],2);


bounds_frame = round([bounds(:,1);bounds(end,2)].*100);

%seg_errors = zeros(length(locs),2);
seg_errors = zeros(1,2);
seg_lens = zeros(1,2);
n = 1;


chance_level = mean(p,2)+2.*std(p,[],2);

%figure(6);plot(p);
for word = 1:length(locs)
   
    
    
    [value,model] = max(p(locs(word),:));
    
    if(intersect(model,truetags))
    
%     % Good way to do it
    endpoint = locs(word)+find(winners(locs(word):end) ~= model,1)-1;       
    startpoint = locs(word)-find(flipud(winners(1:locs(word))) ~= model,1)+1;
    if(isempty(startpoint))
        startpoint = 1;
    end
    if(isempty(endpoint))
        endpoint = size(p,1);
    end
    
    
    % Bad way to do it
%     endpoint = locs(word)+find(p(locs(word):end,model)-chance_level(locs(word):end) < 0,1);
%     startpoint = locs(word)-find(flipud(p(1:locs(word),model))-flipud(chance_level(1:locs(word))) < 0,1)+1;
%     if(isempty(startpoint))
%         startpoint = 1;
%     end
%     if(isempty(endpoint))
%         endpoint = size(p,1);
%     end
%     
%     
    %hold on;
    %line([startpoint startpoint],[min(p(:)) max(p(:))]);
    %line([endpoint endpoint],[min(p(:)) max(p(:))]);
    
    seg_lens(n) = endpoint-startpoint;
    
    d = endpoint-bounds_frame;
    smallest_dist = find(abs(d) == min(abs(d)),1);
    %seg_errors(word,2) = d(smallest_dist);    
    seg_errors(n,2) = d(smallest_dist);    
    
    d = startpoint-bounds_frame;
    smallest_dist = find(abs(d) == min(abs(d)),1);
    %seg_errors(word,1) = d(smallest_dist);    
    seg_errors(n,1) = d(smallest_dist);    
    n = n+1;
    end
    
end




% Find amount of oversegmentation


% Get distances from each boundary


% Should focus on individual boundary?









