function [ feat_vect ] = htd(rgb_image)
image=im2double(rgb2gray(rgb_image));
graylimits=[min(image(:)) max(image(:))];
numlevels=8;
offset=[2 3];
glcm = graycomatrix(image,'GrayLimits', graylimits, 'NumLevels', numlevels, 'Offset',offset);
stats = graycoprops(glcm,{'contrast','correlation','energy','homogeneity'});
feat_vect=[stats.Contrast stats.Correlation stats.Energy stats.Homogeneity];
feat_vect=feat_vect/sum(feat_vect);
end

