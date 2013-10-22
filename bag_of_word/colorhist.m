function [ color_histogram ] = colorhist( rgb_image,color_space,number_bins )
load('colormaps.mat');
image=im2double(rgb_image);
color_space=lower(color_space);
if strcmp(color_space,'hsv')
    image=rgb2hsv(image);
end
map=eval([color_space 'map' num2str(number_bins)]);
ind_image=rgb2ind(image,map);
color_histogram=imhist(ind_image,map)';
color_histogram=color_histogram/sum(color_histogram);

end

