function [precision,recall,F]= compute_f(ind,relevance)
tot_relvant=numel(cell2mat(relevance));
nb_relevant=[];
tot_retrieved=size(ind,1)*[1:40];
for j=1:numel(tot_retrieved)
    count=0;
    for i=1:size(ind,1)
        pcount=0;
        for k=1:j
            pcount= pcount+ sum(double(ind(i,k+1)==cell2mat(relevance(i))));
        end
        count=count+pcount;
    end
    nb_relevant(end+1)=count;
end
precision=nb_relevant./tot_retrieved;
recall=nb_relevant./tot_relvant;
F=2*precision.*recall./(precision+recall);
end

