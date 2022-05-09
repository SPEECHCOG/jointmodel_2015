function wordorder1 = generateOrder()

wordorder1 = zeros(180,1);
counts = zeros(4,1);
for k = 1:180
    if(k > 1)
        options = setdiff(1:4,wordorder1(k-1));
        options(counts(options) > mean(counts)+3) = [];
    else
        options = 1:4;
    end    
    wordorder1(k) = options(randi(length(options)));        
    counts(wordorder1(k)) = counts(wordorder1(k))+1;
end


