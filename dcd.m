function [F I1]= dcd(Img,NumDomColors)
[Rows Cols Ch] = size(Img);
Img2 = double (reshape (Img, Rows * Cols, Ch));

[centroids,U] = fcm(Img2, NumDomColors,[2.0 30 1e-5 0]);
centroids = uint8(centroids);

maxU = max(U);
probClust=zeros(1,NumDomColors);
SegImg=zeros(Rows*Cols,3);
SegImg2=zeros(Rows*Cols,1);
for i=1:NumDomColors
    % Find the data points with highest grade of membership in cluster i
    index = find(U(i,:) == maxU);
    % Set the cluster probability as number of members / number of data points
    probClust(i) = length(index)/(Rows*Cols);
    % Assign each pixel to its closest dominant color
    for j=1:length(index)
        SegImg(index(j), :) = centroids(i,:);
        SegImg2(index(j))=i; 
    end
end

F.c = centroids;
F.p = probClust;
F.n = NumDomColors;
%F.v = computeVariance(centroids,Img2,SegImg);

% Reshape the data points to an image with pixels assigned to corresponding
% dominant color
%I1=uint8(reshape(SegImg, Rows, Cols,Ch));
%I2=uint8(reshape(SegImg2, Rows, Cols));
%spatialCoherence=imgspatialCoherence(centroids,probClust,I2);
%F.s=spatialCoherence;
end