function [imgGrid] = extractGridColors(img, cellNum, color_space, number_bins)
% clc;
% cellNum = 9;
% color_space = 'rgb';
% number_bins = 32;
% img = imread('test.jpg');

[nRows nCols ~] = size(img);
[row,col] = deal(1);

for index = 1:cellNum
    endRows = round(nRows/sqrt(cellNum))*row;
    endCols = round(nCols/sqrt(cellNum))*col;
    if (col==sqrt(cellNum))     endCols = nCols; endRows = nRows;
    elseif (col==sqrt(cellNum)) endCols = nCols;
    elseif (row==sqrt(cellNum)) endRows = nRows; end
    
    imgPatch = img(round(nRows/sqrt(cellNum))*(row-1)+1:endRows,...
               round(nCols/sqrt(cellNum))*(col-1)+1:endCols,:);

    col = col+1;
    if (col>sqrt(cellNum))
        col = 1;
        row = row+1;
    end
    colorHist = colorhist( imgPatch,color_space,number_bins );
    [~,maxInd(index)] = max(colorHist);
end
load('colormaps.mat');
map = eval([color_space 'map' num2str(number_bins)]);
imgGrid = map(maxInd',:);


