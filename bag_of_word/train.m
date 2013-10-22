function train()
load('features.mat');
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
for i=1:numel(color_feat)
    data_color=[];
    if ~isempty(color_feat{i})
        evalc(['data_color=cell2mat({Features.' color_feat{i} '}'')']);
    end
    for j=1:numel(texture_feat)
        data_texture=[];
        if ~isempty(texture_feat{j})
            evalc(['data_texture=cell2mat({Features.' texture_feat{j} '}'')']);
        end
        data=[data_color data_texture];
        if ~isempty(data)
            tic;
            [~,C] = kmeans(data,50,'emptyaction','drop');
            disp(['Clustring for option {'  color_feat{i}  texture_feat{j} '} done in:' num2str(toc)]);
            evalc(['keywords.' color_feat{i} texture_feat{j} '=C']);
        end
        
    end
end
save('keywords.mat','keywords');
disp('Data Summarization Done.');

% for c=1:50
%     cluster_items=Features(find(IDX==c));
%     cluster_data=cell2mat({cluster_items.feat }');
%     Dist=calcDist(C(c,:),'euclidean', cluster_data);
%     [~, id]=min(Dist);
%     keywords(c).feat=cluster_items(id).feat;
%     keywords(c).filename=cluster_items(id).filename;
%
%     h=figure('Visible','off');
%     for i=1:min(100,numel(cluster_items));
%         image=imread(cluster_items(i).filename);
%         subplot(10,10,i);imshow(image);
%     end
%     print(h,['Clusters/'  num2str(c) '.jpg'],'-djpeg');
%     disp(['Ploting cluster: ' num2str(c) ' done.']);
% end
end

