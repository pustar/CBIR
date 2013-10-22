function extract_features()
%EXTRACT_FEATURES extract the "bag of word" representation for the testing
%set
tic1=tic;
load('keywords.mat');
folders=dir('Images');
k=1;
for i=1:length(folders)
    if folders(i).isdir && ~strcmp(folders(i).name,'.') && ~strcmp(folders(i).name,'..')
        foldersList{k}=folders(i).name;
        k=k+1;
    end
end
l=1;
for i=1:length(foldersList)
    Dir=['Images',filesep,char(foldersList(i)),filesep,'test'];
    filelist=dir([Dir,filesep,'*.jpg']);
    names={filelist.name};
    for j=1:size(names,2)
        list{l}.file=[Dir,filesep,names{j}];
        list{l}.cluster=char(foldersList(i));
        l=l+1;
    end
end
liststruct=[list{:}];
filenames={liststruct.file};
clusters={liststruct.cluster};

K=[5];
color_spaces={'rgb', 'hsv'};
number_bins=[32 64 128 256];

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

for i=1:numel(filenames)
    tic2=tic;
    cur_filename=filenames{i};
    cur_image=imread(cur_filename);
    [L,W,~]=size(cur_image);
    for k=1:numel(K)
        
        w1=floor(L/K(k));
        w2=floor(W/K(k));
        dim1_slide_rate=floor(w1-w1/4);
        dim2_slide_rate=floor(w2-w2/4);
        l=1;
        for ii=1:K(k)+1
            for jj=1:K(k)+1
                s1=1+(ii-1)*dim1_slide_rate;
                s2=1+(jj-1)*dim2_slide_rate;
                window=cur_image(s1:s1+w1,s2:s2+w2,:);
                for nb=1:numel(number_bins)
                    for cs=1:numel(color_spaces)
                        evalc(['cur_feat(l).colorhist' color_spaces{cs} num2str(number_bins(nb)) '=colorhist(window,color_spaces{cs},number_bins(nb) )']);
                    end%%Color hist features
                    evalc(['cur_feat(l).csd' num2str(number_bins(nb)) '=CSD(window,''hmmd'',number_bins(nb) )']);
                end
                evalc('cur_feat(l).EHD=ehd20(window,0.1)');
                evalc('cur_feat(l).HTD=htd(window)');
                evalc('cur_feat(l).wave=wvmeanstd(window,2,''rgb'')');
                evalc('cur_feat(l).tamura=tamura(window)');
                l=l+1;
            end
        end
        %%%voting
        for ii=1:numel(color_feat)
            cur_color=[];
            if ~isempty(color_feat{ii})
                evalc(['cur_color=cell2mat({cur_feat.' color_feat{ii} '}'')']);
            end
            for jj=1:numel(texture_feat)
                cur_texture=[];
                if ~isempty(texture_feat{jj})
                    evalc(['cur_texture=cell2mat({cur_feat.' texture_feat{jj} '}'')']);
                end
                data=[cur_color cur_texture];
                if ~isempty(data)
                    evalc(['test(i).' color_feat{ii} texture_feat{jj} '_local=vote(data,cell2mat({keywords.' color_feat{ii} texture_feat{jj} '}''))']);
                end
                
            end
        end
        
        disp(['Extracting local features for: {win size=' num2str(100/K(k)) '% image id:' num2str(i) '  ' cur_filename '} , time spent: ' num2str(toc(tic2))]);
    end
    
    for nb=1:numel(number_bins)
        for cs=1:numel(color_spaces)
            evalc(['test(i).colorhist' color_spaces{cs} num2str(number_bins(nb)) '_global=colorhist(cur_image,color_spaces{cs},number_bins(nb) )']);
        end%%Color hist features
        evalc(['test(i).csd' num2str(number_bins(nb)) '_global=CSD(cur_image,''hmmd'',number_bins(nb) )']);
    end
    evalc('test(i).EHD_global=ehd(cur_image,0.1)');
    evalc('test(i).HTD_global=htd(cur_image)');
    evalc('test(i).wave_global=wvmeanstd(cur_image,2,''rgb'')');
    evalc('test(i).tamura_global=tamura(cur_image)');
    test(i).filename=cur_filename;
    test(i).cluster=clusters{i};
end
save('test_local.mat','test');
disp(['Test feat Extraction done, time spent: ' num2str(toc(tic1))]);

end

function hist=vote(cur_feat,keywords)
hist=zeros(1,size(keywords,1));
for i=1:size(cur_feat,1)
    Dist=calcDist(cur_feat(i,:),'euclidean', keywords);
    [~,id]=min(Dist);
    hist(id)=hist(id)+1;
end
hist=hist/sum(hist);
end
