function [bounds,tags] = getSegments(labels_train)


bounds = zeros(1,2);
tags = zeros(1,1);

curloc = 1;
n = 1;

while(curloc < length(labels_train))
    
    curind = labels_train(curloc);
    
    a = find(labels_train(curloc:end) ~= curind,1)-1;
    if(~isempty(a))
    bounds(n,1) = curloc;
    bounds(n,2) = curloc+a-1;
    tags(n) = curind;
    n = n+1;
    curloc = curloc+a;
    else
        bounds(n,1) = curloc;
        bounds(n,2) = length(labels_train);
        tags(n) = curind;
        curloc = length(labels_train);
    end
    
end





