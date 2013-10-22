function dist=pemd(image,data)
l=length(data);
m=1;
dist=zeros(m,l);
for i=1:m
    [n ,~]=size(image);
    for j=1:l
        y=cell2mat(data(j));
        [m ,~]=size(y);
        if m>0;
            [~ ,dist(i,j)]=emd(image, y, ones(n,1), ones(m,1), @gdf);
        else
            dist(i,j)=Inf;
        end
        j
    end
end
end