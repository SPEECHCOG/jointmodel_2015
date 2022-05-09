function [train_labels,train_weights,quant_error] = runVQ(F,codebook,n_of_streams)

if(~iscell(F))
    k = F;
    clear F
    F{1} = k;
    notcell = 1;
else
    notcell = 0;
end

if(n_of_streams > 1)
    multistream = 1;
else
    multistream = 0;    
end

N = length(F);
clusterIndices = cell(N,1);
clusterWeights = cell(N,1);
quant_error = cell(N,1);

avaruus = codebook;

for b = 1:N
    
    %procbar(b,N);
    
    segment_data = F{b};   
    inputti = zeros(size(avaruus,1),size(segment_data,1));
    mm = 1;
    for k = 1:size(segment_data,1)  
        
            inputti(:,mm) = segment_data(k,1:size(codebook,1));

            mm = mm+1;            
    end
    
            
    M = abs(pdist2(avaruus',inputti','euclidean'));
    
    
    if(multistream == 0)        
        [errors,clusterIndices{b}] = min(M);
        clusterIndices{b} = clusterIndices{b}';                              
        clusterWeights{b} = ones(length(clusterIndices{b}),1);        
        quant_error{b} = errors;
    else
        
        
        
        % Compute N best
        [cors,ind_ordering] = sort(M,'ascend');
        
        [clusterIndices{b}] = ind_ordering(1:n_of_streams,:)';
                 
        
        %////////////////////////////////////////////////////////////////
        % Multilabeling (Hernando et al.)
        %//////////////////////////////////////////////////////////////
        
        cordists = (1./cors)./repmat(sum(1./cors,1),size(cors,1),1);
        
        cordists = cordists(1:n_of_streams,:);       
        
        cordists(isnan(cordists)) = 0;
        
        a = sum(cordists) == 0;
        cordists(1,a) = 1;
        
        cordists = cordists./repmat(sum(cordists),size(cordists,1),1);
        
  
        clusterWeights{b} = cordists';
        
        
        
                
    end        
end

train_labels = clusterIndices;
train_weights = clusterWeights;

if(notcell == 1)
    k = train_labels{1};
    clear train_labels
    train_labels = k;
    k = train_weights{1};
    clear train_weights
    train_weights = k;
end
   
    
