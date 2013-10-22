function [] = train
tic;
%%%read all images in sub training directories
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
    Dir=['Images',filesep,char(foldersList(i))];
    filelist=dir([Dir,filesep,'*.jpg']);
    names={filelist.name};
    for j=1:size(names,2)
        list{l}.file=[Dir '\' names{j}];
        list{l}.cluster=char(foldersList(i));
        l=l+1;
    end
end
liststruct=[list{:}];
filenames={liststruct.file};
clusters={liststruct.cluster};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Training options
color_spaces={'rgb', 'hsv'};
number_bins=[32 64 128 256];

%%%%%%%%%%%%%%%%%%%%


%%% Training
for i=1:numel(filenames)
    cur_filename=filenames{i};
    cur_image=imread(cur_filename);
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
    test(i).cluster=clusters{i};
    test(i).filename=cur_filename;
    disp(['Extracting all features for: {image id:' num2str(i) '  ' cur_filename '}']);
end
training_time=toc;
save('test_global.mat','test');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Features Extraction done, time spent: ' num2str(training_time)]);
