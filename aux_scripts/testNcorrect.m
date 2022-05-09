function [true_correct_single,true_correct_either,true_correct_both] = testNcorrect(correct_single,total_single,correct_either,correct_both,total_double)


% Do single case

n = correct_single; % correct responses 
p = 0.25; % probability of correct in single words

k = 1:n;

y = binopdf(n-k,total_single-k,p);

[prob,true_correct_single] = max(y);



% Do double case

n = correct_either;
m = correct_both;

for kd1 = 1:total_double
    for kd2 = 1:total_double
        y(kd1,kd2) = binopdf(n-kd1-kd2,total_double-kd1-kd2,0.5)*binopdf(m-kd2,n-kd2,1/3);
    end
end

[true_correct_either,true_correct_both] = find(y == max(y(:)),1);
