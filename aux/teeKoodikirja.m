function codebook = teeKoodikirja(F,cbsize,n_items,dcloud)
if nargin <3
    n_items = 5000;
end
streams = ['S' 'V' 'A'];



streamsizes = [cbsize 150 150];



if nargin <4
    dim = size(F{1},2);
    data_cloud = zeros(dim,8000000);
    %
    F = F(randperm(length(F)));
    % dim = length(F{1}{1}.onset);
    %
    kek = 1;
    for k = 1:length(F)
        for j = 1:size(F{k},1);
            
            data_cloud(1:dim,kek) = F{k}(j,1:dim);
            
            kek = kek+1;
        end
    end
    
    data_cloud(:,kek:end) = [];
    if(length(data_cloud) > n_items);
    data_cloud = data_cloud(:,1:n_items);
    end
else
    dim = size(dcloud,1);
    
    data_cloud = dcloud;
    data_cloud = data_cloud(:,randperm(length(data_cloud)));
    data_cloud = data_cloud(:,1:n_items);
end

size(data_cloud)
find(isnan(data_cloud) == 1)
find(isinf(data_cloud) == 1)
tic;
codebook = cell(1,1);
for str=1:1
	disp(['training codebook for stream ' streams(str)]);    
    if(str == 1)
        feat = data_cloud(1:dim,:);
        %dim = 12;
    elseif(str == 2)
        feat = data_cloud(14:26,:);
        dim = 12;
    elseif(str == 3)
        dim = 12;
        feat = data_cloud(27:39,:);
    end
%	feat = data_cloud((str-1)*dim+(1:dim), :);
dim = size(feat,1);
	prot = mean(feat,2);                              %one single prototype in the middle of the data 'cloud' of that stream
	membership = ones(1,size(feat,2));                %all points are assigned to that prototype (I carefully avoid the word 'cluster' here)

	while size(prot,2)<streamsizes(str)
		cv = cell(1,size(prot,2));                        %covariance matrices of the points assigned to all prototypes
		detcv = zeros(1,size(prot,2));
		scv = zeros(1,size(prot,2));

		main_dir = zeros(dim,size(prot,2));
		for k = 1:size(prot,2)
			cv{k} = cov(feat(:,membership==k)');
			detcv(k) = det(cv{k});
			[U,S,V] = svd(cv{k});
			main_dir(:,k) = U(:,1);                  %the direction in which the datapoint-'cloud' assigned to the k'th prototype is the longest
			scv(k) = sqrt(S(1,1));
		end
		[dummy, k] = max(detcv);                         %determine the biggest 'cloud'

		prot = [prot prot(:,k)+1e-2*scv(k)*main_dir(:,k)];	
		prot(:,k) = prot(:,k)-1e-2*scv(k)*main_dir(:,k);            %split the prototype along the main direction
 		disp(size(prot,2));

		[prot,esq,membership] = kmeans(feat,prot,15);                %perform 15 kmeans-iterations
	end

	[prot,esq,membership] = kmeans(feat,prot,200);
	codebook{str} = prot;
end
toc;
codebook = codebook{1};