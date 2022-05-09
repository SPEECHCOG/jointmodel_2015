function [prot,esq,best] = kmeans(input, init_prot, max_iter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based on a routine by Chuck Anderson, anderson@cs.colostate.edu, 1996
%      Copyright (C) Mike Brookes 1998
%
%      Last modified Mon Jul 27 15:48:23 1998
%
%   VOICEBOX home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
block_size=1e5;
if nargin<3,
	max_iter=inf;
end

[dim,npoints] = size(input);
prot=init_prot;
nclu=size(prot,2);
old_prot = prot+1;

iter=0;
while any(prot(:) ~= old_prot(:))
	iter=iter+1;
	fprintf('iteration %d ',iter);
	min_dx=zeros(1,npoints);best=min_dx;
	kk=0;
	while kk<npoints,
		sel=kk+1:min(kk+block_size,npoints);
		dx = eucl_dx(input(:,sel),prot);
		[min_dx(sel),best(sel)] = min(dx,[],1);
		kk=kk+block_size;
	end
	old_prot = prot;
	to_be_removed=logical(zeros(1,nclu));
	for i=1:nclu
		s = (best==i); % select the data points for which i is the best prototype
		if any(s)
			prot(:,i) = mean(input(:,s),2);
		else
			to_be_removed(i)=1;
		end
	end
	if any(to_be_removed),
		prot(:,to_be_removed)=[];
		old_prot=prot+1;
        nclu = nclu - length(find(to_be_removed));
	end
	fprintf('dx %16.9f\n',mean(min_dx));
	if iter>max_iter,
		break
	end
end
esq=mean(min_dx);
end
