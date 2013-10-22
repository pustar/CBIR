%%% Script to segment the training images using a grid approach
%read all images in sub training directories
tic;
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
    Dir=['Images',filesep,char(foldersList(i)),filesep,'train'];
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% sub-images extraction
K=[5]; % list of sub-images sizes in term of percentage of the input image (100/K(i)%)
for k=1:numel(K)
    for i=1:numel(filenames)
        cur_filename=filenames{i};
        cur_image=imread(cur_filename);
        [L,W,~]=size(cur_image);
        w1=floor(L/K(k));
        w2=floor(W/K(k));
        dim1_slide_rate=floor(w1-w1/4);
        dim2_slide_rate=floor(w2-w2/4);
        for ii=1:K(k)+1
            for jj=1:K(k)+1
                s1=1+(ii-1)*dim1_slide_rate;
                s2=1+(jj-1)*dim2_slide_rate;
                window=cur_image(s1:s1+w1,s2:s2+w2,:);
                imwrite(window, ['Subimages' num2str(100/K(k)) filesep num2str(i) '_' num2str(ii) '_' num2str(jj) '.jpg']);
            end
        end
        disp(['Extracting sub images for: {win size=' num2str(100/K(k)) '% image id:' num2str(i) '  ' cur_filename '}']);
    end
end
extraction_time=toc;
disp(['Sub Images Extraction done, time spent: ' num2str(extraction_time)]);