function distVec = calcDist(orgVec, dist, targetVec) 

    applyToGivenRow = @(func, matrix) @(row) func(matrix(row, :),orgVec);
    createPairs = @(func, matrix) arrayfun(applyToGivenRow(func, matrix), 1:size(matrix,1),'uniformoutput',false)';
    distVec = arrayfun(@(test)phdist(test,dist),createPairs(@vertcat, targetVec)');
end

%%
function [Y] = phdist(data,distance)
    data= cell2mat(data);
    m=size(data,1);
    Y=zeros(1, m*(m-1)/2);
    K=0;
    W = [repmat(0.5,1,80) repmat(0.3,1,65) repmat(0.2,1,5)];
    switch lower(distance)
        case 'euclidean'
            Y=pdist(data,'euclidean');
        case 'weuclidean'
            weuc = @(XI,XJ,W)(sqrt(bsxfun(@minus,XI,XJ).^2 *W'));
            Y = pdist(data, @(Xi,Xj) weuc(Xi,Xj,W));
        case 'quadratic'
            for i=1:m-1
                h1=data(i,:);
                H1=cumsum(data(i,:));
                for j=i+1:m
                    h2=data(j,:);
                    H2=cumsum(data(j,:));
                    d=sqrt(bsxfun(@minus,h1',h2).^2);
                    A=1-d/max(d(:));
                    A(logical(eye(size(A))))=1;
                    K=K+1;
                    Y(K) = sqrt((H1-H2)*A*(H1-H2)');
                end
            end
        case 'ks'
            for i=1:m-1
                H1=cumsum(data(i,:));
                for j=i+1:m
                    H2=cumsum(data(j,:));
                    K=K+1;
                    Y(K) = max(abs(H1-H2));
                end
            end
        case 'chi2'
            for i=1:m-1
                h1=data(i,:);
                for j=i+1:m
                    h2=data(j,:);
                    K=K+1;
                    Temp=(h1-h2).^2./(h1+h2);
                    Temp(isnan(Temp) == 1)=0;
                    Y(K) = sum(Temp);
                end
            end
        case 'kl'
            for i=1:m-1
                h1=data(i,:);
                for j=i+1:m
                    h2=data(j,:);
                    K=K+1;
                    Temp=h1.*log(h1./h2);
                    Temp(isnan(Temp) == 1)=0;
                    Temp(isinf(Temp) == 1)=0;
                    Y(K) = sum(Temp);
                end
            end

        otherwise
            error(['Unknown distance ''' distance '''.']) ;
    end
end