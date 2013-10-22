%%% Tamura texture features %%%
function H= tamura(I)
    warning('off');
    THRESHOLD = 0.01;
    % t=cputime;
    if isrgb(I) 
        I = rgb2gray(I);
    end
    [nRows,nCols] = size(I);
    G = double(I);

    %% Roughness
    [bestSubset,E0h,E0v,E1h,E1v,E2h,E2v,E3h,E3v,E4h,E4v,E5h,E5v] = deal(zeros(nRows,nCols));
    E0h(:,2:nCols) = bsxfun(@minus, G(:,2:nCols), G(:,1:nCols-1))/2;
    E0v(1:nRows-1,:) = bsxfun(@minus, G(1:nRows-1,:),G(2:nRows,:))/2;
    % applyToGivencol = @(func, matrix, startInd, endInd) @(col) func(matrix(:,col+startInd:col+endInd)); 
    % applyToCols = @(func, matrix, startInd, endInd, a, b) arrayfun(applyToGivencol(func, matrix, startInd, endInd), a:b,'UniformOutput', false);

    if(nRows>64&&nCols>64)
        for i=1:nRows-1 
            for j=3:nCols-1 
                E1h(i,j)=sum(sum(G(i:i+1,j:j+1)))-sum(sum(G(i:i+1,j-2:j-1))); 
            end
            if (i>1 && i<nRows-1)
                for j=2:nCols 
                    E1v(i,j)=sum(sum(G(i-1:i,j-1:j)))-sum(sum(G(i+1:i+2,j-1:j))); 
                end
                for j=5:nCols-3 
                    E2h(i,j)=sum(sum(G(i-1:i+2,j:j+3)))-sum(sum(G(i-1:i+2,j-4:j-1))); 
                end
                if (i>3 && i<nRows-3)
                    for j=3:nCols-1 
                        E2v(i,j)=sum(sum(G(i-3:i,j-2:j+1)))-sum(sum(G(i+1:i+4,j-2:j+1))); 
                    end 
                    for j=9:nCols-7 
                        E3h(i,j)=sum(sum(G(i-3:i+4,j:j+7)))-sum(sum(G(i-3:i+4,j-8:j-1))); 
                    end 
                    if (i>7 && i<nRows-7)
                        for j=5:nCols-3 
                            E3v(i,j)=sum(sum(G(i-7:i,j-4:j+3)))-sum(sum(G(i+1:i+8,j-4:j+3))); 
                        end 
                        for j=17:nCols-15 
                            E4h(i,j)=sum(sum(G(i-7:i+8,j:j+15)))-sum(sum(G(i-7:i+8,j-16:j-1))); 
                        end 
                        if (i>15 && i<nRows-15)
                            for j=9:nCols-7 
                                E4v(i,j)=sum(sum(G(i-15:i,j-8:j+7)))-sum(sum(G(i+1:i+16,j-8:j+7))); 
                            end 
                            for j=33:nCols-31 
                                E5h(i,j)=sum(sum(G(i-15:i+16,j:j+31)))-sum(sum(G(i-15:i+16,j-32:j-31))); 
                            end 
                            if (i>31 && i<nRows-31)
                                for j=17:nCols-15 
                                    E5v(i,j)=sum(sum(G(i-31:i,j-16:j+15)))-sum(sum(G(i+1:i+32,j-16:j+15))); 
                                end 
                            end
                        end
                    end
                end
            end
        end    
        E1h=E1h/4;    E1v=E1v/4;
        E2h=E2h/16;   E2v=E2v/16;
        E3h=E3h/64;   E3v=E3v/64;
        E4h=E4h/256;  E4v=E4v/256;
        E5h=E5h/1024; E5v=E5v/1024;
    end

    for i=1:nRows
        for j=1:nCols
            [~,index] = max([E0h(i,j),E0v(i,j),E1h(i,j),E1v(i,j),E2h(i,j),E2v(i,j),E3h(i,j),E3v(i,j),E4h(i,j),E4v(i,j),E5h(i,j),E5v(i,j)]);
            k = floor((index+1)/2);
            bestSubset(i,j) = 2.^k;
        end
    end

    Fcoarseness = sum(sum(bestSubset))/(nRows*nCols);

    %% Contrast
    [counts,graylevels] = imhist(I);
    PI = counts/(nRows*nCols);
    averagevalue = sum(graylevels.*PI);
    u4 = sum((graylevels-repmat(averagevalue,[256,1])).^4.*PI);
    standarddeviation = sum((graylevels-repmat(averagevalue,[256,1])).^2.*PI);
    alpha4 = u4/standarddeviation^2;
    Fcontrast = sqrt(standarddeviation)/alpha4.^(1/4);

    %% Direction degree
    [deltaH,deltaV,theta] = deal(zeros(nRows,nCols));
    PrewittH = [-1 0 1;-1 0 1;-1 0 1];
    PrewittV = [1 1 1;0 0 0;-1 -1 -1];
    % Horizontal gradient
    for i=2:nRows-1
        for j=2:nCols-1
            deltaH(i,j)=sum(sum(G(i-1:i+1,j-1:j+1).*PrewittH));
        end
    end
    deltaH(1,2:nCols-1) = bsxfun(@minus, G(1,3:nCols), G(1,2:nCols-1));
    deltaH(nRows,2:nCols-1) = bsxfun(@minus, G(nRows,3:nCols), G(nRows,2:nCols-1));
    deltaH(1:nRows,1) = bsxfun(@minus, G(1:nRows,2), G(1:nRows,1));
    deltaH(1:nRows,nCols) = bsxfun(@minus, G(1:nRows,nCols), G(1:nRows,nCols-1));

    % Vertical gradient
    for i=2:nRows-1
        for j=2:nCols-1
            deltaV(i,j)=sum(sum(G(i-1:i+1,j-1:j+1).*PrewittV));
        end
    end
    deltaV(1,1:nCols) = bsxfun(@minus, G(2,1:nCols), G(1,1:nCols));
    deltaV(nRows,1:nCols) = bsxfun(@minus, G(nRows,1:nCols), G(nRows-1,1:nCols));
    deltaV(2:nRows-1,1) = bsxfun(@minus, G(3:nRows,1), G(2:nRows-1,1));
    deltaV(2:nRows-1,nCols) = bsxfun(@minus, G(3:nRows,nCols), G(2:nRows-1,nCols));

    % Gradient vector direction
    theta(cell2mat(arrayfun(@(x) find(deltaH==x & deltaV~=x),0, 'UniformOutput', false)))=pi;
    tempInd = cell2mat(arrayfun(@(x) find(deltaH~=x),0, 'UniformOutput', false));
    theta(tempInd)=atan(deltaV(tempInd')./deltaH(tempInd'))+pi/2;

    theta1 = reshape(theta,1,[]);
    phai = 0:0.0001:pi;
    HD1 = hist(theta1,phai);
    HD1 = HD1/(nRows*nCols);
    HD2 = zeros(size(HD1));

    thrInd = find(HD1>=THRESHOLD);
    HD2(thrInd) = HD1(thrInd);

    [~,index] = max(HD2);
    phaiP = index*0.0001;
    ind = find(HD2~=0);
    Fdirection = sum(((phai(ind)-phaiP).^2).*HD2(ind));

    % deltaT=cputime-t
    H=[Fcoarseness Fcontrast Fdirection]; 
end
