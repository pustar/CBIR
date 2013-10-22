function [grid] = bestColMatch(grid, color_space, number_bins)
% clc;
% grid = {[1 2 3] [3 4 5] []};
% map = [1 2 3;2 3 4;4 5 6];
% color_space = 'rgb';
% number_bins = 32;

load('colormaps.mat');
map = eval([color_space 'map' num2str(number_bins)]);
emptyCells = cellfun(@isempty,grid);
dist = cellfun(@(test)calcDist(test,'euclidean',map), grid(~emptyCells), 'UniformOutput', false);
[~,minInd] = cellfun(@min, dist);
grid = map(minInd,:);


