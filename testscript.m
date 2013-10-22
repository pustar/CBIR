function [ ] = testscript
load('test_local.mat');
color_feat={'colorhistrgb32',...
    'colorhistrgb64',...
    'colorhistrgb128',...
    'colorhistrgb256',...
    'colorhisthsv32',...
    'colorhisthsv64',...
    'colorhisthsv128',...
    'colorhisthsv256',...
    'csd32',...
    'csd64',...
    'csd128',...
    'csd256',''};
texture_feat= {'','EHD','HTD','wave','tamura'};

clusters={test.cluster};
for i=1:numel(clusters)
    temp_ind=find(strcmp(clusters,clusters{i}));
    temp_ind(temp_ind==i)=[];
    relevance{i}=temp_ind;
end
k=1;
for ii=1:numel(color_feat)
    
    for jj=1:numel(texture_feat)
        option=[color_feat{ii} texture_feat{jj}];
        if ~isempty(option)
            options{k}=[option '_local'];
            k=k+1;
        end
    end
end



for i=1:numel(options)
    disp(['Computing F-measure for option ' num2str(i) ': {' options{i} '} ...']);
    evalc(['data=cell2mat({test.' options{i} '}'')']);
    Dist=squareform(pdist(data,'euclidean'));
    [v,ind]=sort(Dist,2);
    [precision{i},recall{i},F{i}]= compute_f(ind,relevance);
    
%     h=figure('Visible','off');
%     for k=1:10
%         for id1=1:10
%             for id2=1:10
%                 subplot(10,10,(id1-1)*10+id2);imshow(imread(test(ind(id1+(k-1)*10,id2)).filename));title(num2str(v(id1+(k-1)*10,id2)),'fontsize',5);
%             end
%         end
%         print(h,['Results_' options{i} filesep num2str(k)  '.jpg'],'-djpeg');
%         k
%     end
end
save('F-measure_local.mat', 'precision','recall','F');
figure(10);
cc=hsv(numel(options));
for i=1:numel(options)
hold on;
h=plot([1:100],F{i},'color',cc(i,:));
legend(h,num2str(i),'location','southeast');
end
title('F-measure ');
hold off;

figure(20);
cc=hsv(numel(options));
for i=1:numel(options)
hold on;
h=plot([1:100],precision{i},'color',cc(i,:));
legend(h,num2str(i),'location','southeast');
end
title('Precision');
hold off;

figure(30);
cc=hsv(numel(options));
for i=1:numel(options)
hold on;
h=plot([1:100],recall{i},'color',cc(i,:));
legend(h,num2str(i),'location','southeast');
end
title('Recall');
hold off;

end

