function []=preprocess
%preprocess do extract all  possible features needed to learn the dictionary for the "bag of word" concept 
%   The following features are extracted:
%   - Color Features
%       1) Color hist: in RGB and HSV color sapces and using [32 64 128 256] bins
%       2) Color Structure Descriptor (CSD): in HMMD color space and using [32 64 128 256] bins
%   -Texture Features
%       1) Edge Histogram Descriptor (EHD)
%       2) Wavelet
%       3) Homogeneous Texture Descriptor (HTD) 

% read all the training sub-images: Subimages20\*.JPG
tic;
files = dir('Subimages20\*.JPG');
filenames={files.name};
%%%%Training options
color_spaces={'rgb', 'hsv'};
number_bins=[32 64 128 256];

%%%%%%%%%%%%%%%%%%%%

%%% Training
for i=1:numel(filenames)
    cur_filename=['Subimages20\' filenames{i}];
    cur_image=imread(cur_filename);
    for nb=1:numel(number_bins)
        for cs=1:numel(color_spaces)
            evalc(['Features(i).colorhist' color_spaces{cs} num2str(number_bins(nb)) '=colorhist(cur_image,color_spaces{cs},number_bins(nb) )']);
        end%%Color hist features
        evalc(['Features(i).csd' num2str(number_bins(nb)) '=CSD(cur_image,''hmmd'',number_bins(nb) )']);
    end    
    evalc('Features(i).EHD=ehd(cur_image,0.1)');
    evalc('Features(i).HTD=htd(cur_image)');
    evalc('Features(i).wave=wvmeanstd(cur_image,2,''rgb'')');
    evalc('Features(i).tamura=tamura(cur_image)');
    disp(['Extracting all features for: {image id:' num2str(i) '  ' cur_filename '}']);
end
training_time=toc;
save('features.mat','Features');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Features Extraction done, time spent: ' num2str(training_time)]);

end

