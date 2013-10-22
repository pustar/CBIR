function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 03-Dec-2012 14:43:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_OpeningFcn, ...
    'gui_OutputFcn',  @gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
dbstop if error

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
    clc;
    %Results tab
    handles.unselectedTabColor=get(handles.tab1text,'BackgroundColor');
    handles.selectedTabColor=handles.unselectedTabColor-0.1;
    
    set(handles.tab1text,'Units','normalized')
    set(handles.tab2text,'Units','normalized')
    set(handles.Results,'Units','normalized')
    set(handles.intermResults,'Units','normalized')
    
    % Tab 1
    pos1=get(handles.tab1text,'Position');
    handles.a1=axes('Units','normalized','Box','on',...
                    'XTick',[],'YTick',[],...
                    'Color',handles.selectedTabColor,...
                    'Position',[pos1(1) pos1(2) pos1(3) pos1(4)],...
                    'ButtonDownFcn','gui(''a1bd'',gcbo,[],guidata(gcbo))');
    handles.t1=text('String','Results','Units','normalized',...
                    'Position',[(pos1(3)),pos1(2)+3*pos1(4)],...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','middle',...
                    'Margin',0.001,...
                    'FontSize',8,...
                    'Backgroundcolor',handles.selectedTabColor,...
                    'ButtonDownFcn','gui(''t1bd'',gcbo,[],guidata(gcbo))');

    % Tab 2
    pos2=get(handles.tab2text,'Position');
    pos2(1)=pos1(1)+pos1(3);
    handles.a2=axes('Units','normalized','Box','on',...
                    'XTick',[],'YTick',[],...
                    'Color',handles.unselectedTabColor,...
                    'Position',[pos2(1) pos2(2) pos2(3)+0.05 pos2(4)],...
                    'ButtonDownFcn','gui(''a2bd'',gcbo,[],guidata(gcbo))');
    handles.t2=text('String','Intermediate Results','Units','normalized',...
                    'Position',[pos2(3)/3,pos2(2)+3*pos2(4)],...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','middle',...
                    'Margin',0.001,...
                    'FontSize',8,...
                    'Backgroundcolor',handles.unselectedTabColor,...
                    'ButtonDownFcn','gui(''t2bd'',gcbo,[],guidata(gcbo))');
    % Manage panels (place them in the correct position and manage visibilities)
    pan1pos=get(handles.Results,'Position');
    set(handles.intermResults,'Position',pan1pos)
    set(handles.intermResults,'Visible','off')
    
    
    if isappdata(0,'props') rmappdata(0,'props'); end
    % Choose default command line output for gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    %Display gui in center of screen
    set( handles.figure1,'Units', 'pixels' );
    screenSize = get(0, 'ScreenSize');
    position = get( handles.figure1,'Position' );
    position(1) = (screenSize(3)-position(3))/2;
    position(2) = (screenSize(4)-position(4))/2;
    set( handles.figure1,'Position', position );

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
        Dir=['Images',filesep,char(foldersList(i)),filesep, 'test'];
        filelist=dir([Dir,filesep,'*.jpg']);
        names={filelist.name};
        for j=1:size(names,2)
            % fix path based on OS
            if ispc
                list{l}=[Dir '\' names{j}];
            elseif isunix
                list{l}=[Dir '/' names{j}];
            end
            list{l}=[Dir '/' names{j}];
            l=l+1;
        end
    end
    set(handles.dropdownFilename,'String',list);
    axes(handles.progressBar);
    xlim([0 1]);
    time = progressbar(0.0);

    axes(handles.axesResultsMid);
    htemp = setResultsDisplay_Middle(handles);
    set(htemp,'Tag','axesResultsMid');
    handles.axesResultsMid=htemp;
    axes(handles.axesResults);
    htemp = setResultsDisplay(handles);
    set(htemp,'Tag','axesResults');
    handles.axesResults=htemp;
    
    guidata(hObject, handles);
    

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in dropdownFilename.
function dropdownFilename_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns dropdownFilename contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdownFilename
    contents = cellstr(get(hObject,'String'));
    set(handles.txtFilename,'String',contents{get(hObject,'Value')});
    load_query(handles);
    set(handles.slNumResults,'Enable','off');
 
    
% --- Executes during object creation, after setting all properties.
function dropdownFilename_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function txtFilename_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of txtFilename as text
%        str2double(get(hObject,'String')) returns contents of txtFilename as a double


% --- Executes during object creation, after setting all properties.
function txtFilename_CreateFcn(hObject, eventdata, handles)
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in cmdBrowse.
function cmdBrowse_Callback(hObject, eventdata, handles)
    % hObject    handle to cmdBrowse (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [Filename,PathName,~] = uigetfile('*.jpg','Select the query image');
%     if (Filename~=0 && PathName~=0)
        imagefile=[PathName Filename];
        set(handles.txtFilename, 'String', imagefile);
        load_query(handles);
        set(handles.slNumResults,'Enable','off');
%     end


function load_query(handles)
    axes(handles.axesQuery);
    % cla;
    image=imread(get(handles.txtFilename,'String'));
    setappdata(0,'image',image);
    imshow(image);


% --- Executes on button press in cmdRetrieve.
function cmdRetrieve_Callback(hObject, eventdata, handles)
    % hObject    handle to cmdRetrieve (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if get(handles.chboxColorSketch, 'Value')
        grid = cell(1,9);
        if isappdata(0,'props')
            tempgrid = getappdata(0,'props');
            grid(1:length(tempgrid)) = tempgrid;
        end
        setappdata(0,'props',grid);
        %msgbox('You should choose a color for all cells of the grid.','Error','error'); 
        grid(cellfun(@isempty, grid)) = {[1 1 1]};
        setappdata(0,'props',grid);
        dispQueryImg(handles);
        set(handles.chboxColorFeatures, 'Value', 0);
        set(handles.chboxTextureFeatures, 'Value', 0);
        set(handles.chboxSIFT, 'Value', 0);
        set(handles.rdGlobalColor,'Value',1)
    end
    %*******************fix
    axes(handles.progressBar);
    xlim([0 1]);
    m=60;
    progressbar;
%     for i = 1:m
%       pause(0.2);
%       time = progressbar(i/m); % Update progress bar
%       set(handles.txtTime,'String',sprintf('%s',time));
%     end
%     cla;
    %*******************fix
    tStart = tic; 
    [query fusion bag_of_word]=build_options(handles);
    tElapsed1 = toc(tStart);
    for i = 1:round(m/4)
      pause(0.2);
      time = progressbar(i/m); % Update progress bar
      set(handles.txtTime,'String',sprintf('%s',sec2timestr((i/round(m/4))*tElapsed1)));
    end
    set(handles.txtTime,'String',sprintf('%s',sec2timestr(tElapsed1)));
    
    tStart = tic;
    [val,ind]=do_fusion(handles,query,fusion,bag_of_word);
    tElapsed2 = toc(tStart);
    progressbar(1/4);
    for i = round(m/4)+1:m
      pause(0.2);
      time = progressbar(i/m); % Update progress bar
      set(handles.txtTime,'String',sprintf('%s',sec2timestr(tElapsed1+(i/m)*tElapsed2)));
    end
    set(handles.txtTime,'String',sprintf('%s',sec2timestr(tElapsed1+tElapsed2)));
    set(handles.slNumResults,'Enable','on');
    
    cla;
    visualize(handles,val,ind,bag_of_word);
    save('temp.mat','val','ind','bag_of_word');


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in chboxTextureFeatures.
function chboxTextureFeatures_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of chboxTextureFeatures


% --- Executes on button press in chboxColorFeatures.
function chboxColorFeatures_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of chboxColorFeatures


function txtColorWeight_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of txtColorWeight as text
%        str2double(get(hObject,'String')) returns contents of txtColorWeight as a double


% --- Executes during object creation, after setting all properties.
function txtColorWeight_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function txtTextureWeight_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of txtTextureWeight as text
%        str2double(get(hObject,'String')) returns contents of txtTextureWeight as a double


% --- Executes during object creation, after setting all properties.
function txtTextureWeight_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dropdownDistance.
function dropdownDistance_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns dropdownDistance contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdownDistance


% --- Executes during object creation, after setting all properties.
function dropdownDistance_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dropdownNumberOfBins.
function dropdownNumberOfBins_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns dropdownNumberOfBins contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdownNumberOfBins


% --- Executes during object creation, after setting all properties.
function dropdownNumberOfBins_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [query fusion bag_of_word]=build_options(handles)
    contents = cellstr(get(handles.dropdownNumberOfBins,'String'));
    NumberOfBins=contents{get(handles.dropdownNumberOfBins,'Value')};
    bag_of_word.on=0;
    bag_of_word.both=0;

    if get(handles.rdGlobalColor,'Value')%use global color features
        if get(handles.rdColorHistogram, 'Value')
            if get(handles.rdRGB, 'Value')
                color=['colorhistrgb' NumberOfBins '_global'];
                colorFeat=['Query_Features.colorhistrgb' NumberOfBins '_global=colorhist(query_image,''rgb'',' NumberOfBins ')'];
            else
                color=['colorhisthsv' NumberOfBins '_global'];
                colorFeat=['Query_Features.colorhisthsv' NumberOfBins '_global=colorhist(query_image,''hsv'',' NumberOfBins ')'];
            end
        else
            color=['csd' NumberOfBins '_global'];
            colorFeat=['Query_Features.csd' NumberOfBins '_global=CSD(query_image,''hmmd'',' NumberOfBins ')'];
        end
    else%use local color features (bag of word)
        if get(handles.chboxColorFeatures, 'Value')
        bag_of_word.on=1;
        end
        if get(handles.rdColorHistogram, 'Value')
            if get(handles.rdRGB, 'Value')
                color=['colorhistrgb' NumberOfBins '_local'];
                colorfun=['colorhist(window,''''rgb'''',' NumberOfBins ')'];
            else
                color=['colorhisthsv' NumberOfBins '_local'];
                colorfun=['colorhist(window,''''hsv'''',' NumberOfBins ')'];
            end
        else
            color=['csd' NumberOfBins '_local'];
            colorfun=['CSD(window,''''hmmd'''',' NumberOfBins ')'];
        end
        colorFeat=['Query_Features.' color '= extract_local_features(query_image,''' color ''', {''' colorfun '''})'];
    end
    if get(handles.rdGlobalTexture,'Value')%use global texture features
        if get(handles.rdEHD, 'Value')
            texture='EHD_global';
            textureFeat='Query_Features.EHD_global=ehd(query_image,0.1)';
        end
        if get(handles.rdWavelet, 'Value')
            texture='wave_global';
            textureFeat='Query_Features.wave_global=wvmeanstd(query_image,2,''rgb'')';
        end
        if get(handles.rdHTD, 'Value')
            texture='HTD_global';
            textureFeat='Query_Features.HTD_global=htd(query_image)';
        end
        if get(handles.rdTamura, 'Value')
            texture='tamura_global';
            textureFeat='Query_Features.tamura_global=tamura(query_image)';
        end
    else%use local texture features (bag of word)
        if get(handles.chboxTextureFeatures, 'Value')
        bag_of_word.on=1;
        end
        if get(handles.rdEHD, 'Value')
            texture='EHD_local';
            texturefun='ehd20(window,0.1)';
        end
        if get(handles.rdWavelet, 'Value')
            texture='wave_local';
            texturefun='wvmeanstd(window,2,''''rgb'''')';
        end
        if get(handles.rdHTD, 'Value')
            texture='HTD_local';
            texturefun='htd(window)';
        end
        if get(handles.rdTamura, 'Value')
            texture='tamura_local';
            texturefun='tamura(window)';
        end
        textureFeat=['Query_Features.' texture '=extract_local_features(query_image,''' texture ''', {''' texturefun '''})'];
    end
    mixed_feat='';
    mixedFeat='';

    if get(handles.rdLocalColor,'Value') && get(handles.rdLocalTexture,'Value') % used when no fusion is selected
        bag_of_word.on=1;
        bag_of_word.both=1;
        mixed_feat=[color(1:end-6) texture];
        mixedFeat=['Query_Features.' mixed_feat '=extract_local_features(query_image,''' mixed_feat ''', {''' colorfun ''',''' texturefun  '''})'];
    end
    query={colorFeat,textureFeat,mixedFeat};
    fusion={color,texture,mixed_feat};


function local_hist=extract_local_features(query_image,feat,feat_code)
    load('keywords.mat');
    feat=feat(1:end-6);
    K=5;
    [L,W,~]=size(query_image);
    w1=floor(L/K);
    w2=floor(W/K);
    dim1_slide_rate=floor(w1-w1/4);
    dim2_slide_rate=floor(w2-w2/4);
    l=1;
    for ii=1:K+1
        for jj=1:K+1
            s1=1+(ii-1)*dim1_slide_rate;
            s2=1+(jj-1)*dim2_slide_rate;
            window=query_image(s1:s1+w1,s2:s2+w2,:);
            if numel(feat_code)==1
                evalc(['cur_feat(l).' feat '=' feat_code{1}]);
            else
                evalc(['cur_feat(l).' feat '=[' feat_code{1} ' ' feat_code{2} ']']);
            end
            l=l+1;
        end
    end
    %%%voting
    evalc(['data=cell2mat({cur_feat.' feat '}'')']);
    evalc(['local_hist=vote(data,cell2mat({keywords.' feat '}''))']);


function hist=vote(cur_feat,keywords)
    hist=zeros(1,size(keywords,1));
    for i=1:size(cur_feat,1)
        Dist=calcDist(cur_feat(i,:),'euclidean', keywords);
        [~,id]=min(Dist);
        hist(id)=hist(id)+1;
    end
    hist=hist/sum(hist);


function [val, ind]=do_fusion(handles,query,fusion,bag_of_word)
    if bag_of_word.on
        load('test_local.mat');
    else
        load('test_global.mat');
    end

    query_image=getappdata(0,'image');
    do_fusion=0;
    colorWeight=str2double(get(handles.txtColorWeight,'String'));
    textureWeight=str2double(get(handles.txtTextureWeight,'String'));
    contents = cellstr(get(handles.dropdownDistanceColor,'String'));
    distfuncolor=contents{get(handles.dropdownDistanceColor,'Value')};
    contents = cellstr(get(handles.dropdownDistanceTexture,'String'));
    distfuntexture=contents{get(handles.dropdownDistanceTexture,'Value')};

    if get(handles.chboxColorSketch, 'Value')
        feat=fusion{1};
        evalc(query{1});
        distfun=distfuncolor;
%         gridcolors = getappdata(0,'props');
%         if get(handles.rdRGB, 'Value') colSpace='rgb'; 
%         else colSpace='hsv'; 
%         end
%         [grid] = bestColMatch(gridcolors, colSpace, contents{get(handles.dropdownNumberOfBins,'Value')});
    elseif get(handles.chboxColorFeatures, 'Value') && get(handles.chboxTextureFeatures, 'Value')
        do_fusion=1;

        if get(handles.rdnofusion,'Value')
            if bag_of_word.both
                evalc(query{3});
                feat=fusion{3};
                do_fusion=0;
                distfun=distfuncolor;
            else
                set(handles.rdFusionFeaturesLevel,'Value',1);
                evalc(query{1});
                evalc(query{2});
            end
        else
            evalc(query{1});
            evalc(query{2});
        end
    elseif get(handles.chboxColorFeatures, 'Value') && ~get(handles.chboxTextureFeatures, 'Value')
        feat=fusion{1};
        evalc(query{1});
        distfun=distfuncolor;
    elseif ~get(handles.chboxColorFeatures, 'Value') && get(handles.chboxTextureFeatures, 'Value')
        feat=fusion{2};
        evalc(query{2});
        distfun=distfuntexture;
    end

    if ~do_fusion %%No fusion
        data=cell2mat(eval(['{test.' feat '}'])');
        sample=eval(['Query_Features.' feat ]);
        Dist = calcDist(sample, distfun, data);
        [val, ind]=sort(Dist);
    else %% fusion required
        data_color=cell2mat(eval(['{test.' fusion{1} '}'])');
        data_texture=cell2mat(eval(['{test.' fusion{2} '}'])');
        sample_color=eval(['Query_Features.' fusion{1} ]);
        sample_texture=eval(['Query_Features.' fusion{2} ]);
        if get(handles.rdFusionFeaturesLevel, 'Value')%%%Feature level fusion
            data=[colorWeight*data_color textureWeight*data_texture];
            sample=[colorWeight*sample_color textureWeight*sample_texture];
            Dist = calcDist(sample, distfuncolor, data);
            [val, ind]=sort(Dist);
        end
        if get(handles.rdFusionDistanceLevel, 'Value')%%%Distance level fusion
            Dist_color = calcDist(sample_color, distfuncolor, data_color);
            Dist_texture = calcDist(sample_texture, distfuntexture, data_texture);
            Dist=colorWeight*(Dist_color/sum(Dist_color))+textureWeight*(Dist_texture/sum(Dist_texture));
            [val, ind]=sort(Dist);

        end
        if get(handles.rdFusionSortedList, 'Value')%%%Feature sorted list fusion
            Dist_color = calcDist(sample_color, distfuncolor, data_color);
            Dist_texture = calcDist(sample_texture, distfuntexture, data_texture);
            [val_color, ind_color]=sort(Dist_color);
            [val_texture, ind_texture]=sort(Dist_texture);
            for i=1:numel(val_color)
                sortedColorInd(i) = find(ind_color==i);
                sortedTextureInd(i) = find(ind_texture==i);
                temp_ind(i)=sortedColorInd(i)+sortedTextureInd(i);
            end
            [val ind]=sort(temp_ind);
            sortedColorInd = sortedColorInd(ind);
            sortedTextureInd = sortedTextureInd(ind);
            save ('sortedResults.mat','ind_color', 'sortedColorInd', 'ind_texture', 'sortedTextureInd');
        else
            if exist('sortedResults.mat', 'file') delete('sortedResults.mat'); end
        end
    end

    function visualize(handles,val,ind,bag_of_word)
    if bag_of_word.on
        load('test_local.mat');
    else
        load('test_global.mat');
    end
    h=getappdata(0,'h');
    colors = num2cell(gray(str2num(get(handles.txtNum,'String'))),2);
    for i=1:str2num(get(handles.txtNum,'String'))
        path = test(ind(i)).filename;
        % fix path for unix
        if isunix
         path = strrep(path, '\', '/');
        end
        cur_image=imread(path);
        axes(h(i));
        cla;
        imshow(cur_image);
        th = title(num2str(val(i)),'FontSize',8,'FontWeight','bold','Color',colors{i});
        P = get(th,'Position');
        set(th,'Position',[P(1) 0.1 P(3)])
    end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.txtTextureWeight,'String',num2str(get(hObject,'Value'),2));
set(handles.txtColorWeight,'String',num2str(1-get(hObject,'Value'),2));


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in dropdownDistanceColor.
function dropdownDistanceColor_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns dropdownDistanceColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdownDistanceColor


% --- Executes during object creation, after setting all properties.
function dropdownDistanceColor_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dropdownDistanceTexture.
function dropdownDistanceTexture_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns dropdownDistanceTexture contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdownDistanceTexture


% --- Executes during object creation, after setting all properties.
function dropdownDistanceTexture_CreateFcn(hObject, eventdata, handles)
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function slNumResults_Callback(hObject, eventdata, handles)
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    val = get(hObject,'Value');
    set(handles.txtNum,'String',uint8(get(hObject,'Value')));
    
    axes(handles.axesResultsMid);
    htemp = setResultsDisplay_Middle(handles);
    set(htemp,'Tag','axesResultsMid');
    handles.axesResultsMid=htemp;
    axes(handles.axesResults);
    htemp = setResultsDisplay(handles);
    set(htemp,'Tag','axesResults');
    handles.axesResults=htemp;
    guidata(hObject, handles);
    
    if exist('temp.mat', 'file')
        load('temp.mat');
        visualize(handles,val,ind,bag_of_word);
        set(handles.txtTime,'String','0 sec');
    end
    
    displayMidResults(handles);


function slNumResults_CreateFcn(hObject, eventdata, handles)
    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


function htemp = setResultsDisplay(handles)
    numResults = str2num(get(handles.txtNum,'String'));
    if numResults>5 numCols = 5;
    else numCols = numResults; end
    numRows = ceil(numResults/numCols);
    for i=1:numResults
        h(i)=subplot(numRows,numCols,i);plot(0,0,'w');
        if i==1  htemp = ancestor(gca, 'axes');  end
        set(gca,'xcolor',get(gcf,'color'));
        set(gca,'ycolor',get(gcf,'color'));
        set(gca,'ytick',[]);
        set(gca,'xtick',[]);
    end
    setappdata(0,'h',h);
    
function htemp = setResultsDisplay_Middle(handles)
    numResults = round(str2num(get(handles.txtNum,'String'))*2);
    if numResults>5 numCols = 5;
    else numCols = numResults; end
    numRows = ceil(numResults/numCols);
%     set(handles.axesResultsMid,'NextPlot','ReplaceChildren')
    for i=1:numResults
        hMid(i)=subplot(numRows,numCols,i);plot(0,0,'w');
        if i==1  htemp = ancestor(gca, 'axes');  end
        set(gca,'xcolor',get(gcf,'color'));
        set(gca,'ycolor',get(gcf,'color'));
        set(gca,'ytick',[]);
        set(gca,'xtick',[]);
    end   
    setappdata(0,'hMid',hMid);

    
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    delete(hObject);
    close all;
    if exist('temp.mat', 'file') delete('temp.mat'); end


% --- Executes on mouse press over axes background.
function axesColors1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesColors1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%     s=peaks;
%     handle=plot(s(:,25));
    props = uisetlineprops(handles.axesColors1);
    colorGridInfo(props, 1, handles);


% --- Executes on mouse press over axes background.
function axesColors2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesColors2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    props = uisetlineprops(handles.axesColors2);
    colorGridInfo(props, 2, handles);


% --- Executes on mouse press over axes background.
function axesColors3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesColors3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    props = uisetlineprops(handles.axesColors3);
    colorGridInfo(props, 3, handles);


% --- Executes on mouse press over axes background.
function axesColors4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesColors4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    props = uisetlineprops(handles.axesColors4);
    colorGridInfo(props, 4, handles);


% --- Executes on mouse press over axes background.
function axesColors5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesColors5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    props = uisetlineprops(handles.axesColors5);
    colorGridInfo(props, 5, handles);


% --- Executes on mouse press over axes background.
function axesColors6_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesColors6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    props = uisetlineprops(handles.axesColors6);
    colorGridInfo(props, 6, handles);


% --- Executes on mouse press over axes background.
function axesColors7_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesColors7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    props = uisetlineprops(handles.axesColors7);
    colorGridInfo(props, 7, handles);


% --- Executes on mouse press over axes background.
function axesColors8_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesColors8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    props = uisetlineprops(handles.axesColors8);
    colorGridInfo(props, 8, handles);


% --- Executes on mouse press over axes background.
function axesColors9_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesColors9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    props = uisetlineprops(handles.axesColors9);
    colorGridInfo(props, 9, handles);

    
function colorGridInfo(props, pos, handles)
    if isappdata(0,'props')
        prevProps = getappdata(0,'props');
        prevProps{pos} = props.color;
    else
        prevProps{pos} = props.color;
    end
    setappdata(0,'props',prevProps);
    set(handles.slNumResults,'Enable','off');
    
    
% Text object 1 callback (tab 1)
function t1bd(hObject,eventdata,handles)
    set(hObject,'BackgroundColor',handles.selectedTabColor)
    set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
    set(handles.a1,'Color',handles.selectedTabColor)
    set(handles.a2,'Color',handles.unselectedTabColor)
    set(handles.Results,'Visible','on')
    set(handles.intermResults,'Visible','off')


% Text object 2 callback (tab 2)
function t2bd(hObject,eventdata,handles)
    set(hObject,'BackgroundColor',handles.selectedTabColor)
    set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
    set(handles.a2,'Color',handles.selectedTabColor)
    set(handles.a1,'Color',handles.unselectedTabColor)
    set(handles.intermResults,'Visible','on')
    set(handles.Results,'Visible','off')
    displayMidResults(handles);
    
    
    % Axes object 1 callback (tab 1)
function a1bd(hObject,eventdata,handles)
    set(hObject,'Color',handles.selectedTabColor)
    set(handles.a2,'Color',handles.unselectedTabColor)
    set(handles.t1,'BackgroundColor',handles.selectedTabColor)
    set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
    set(handles.Results,'Visible','on')
    set(handles.intermResults,'Visible','off')


% Axes object 2 callback (tab 2)
function a2bd(hObject,eventdata,handles)
    set(hObject,'Color',handles.selectedTabColor)
    set(handles.a1,'Color',handles.unselectedTabColor)
    set(handles.t2,'BackgroundColor',handles.selectedTabColor)
    set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
    set(handles.intermResults,'Visible','on')
    set(handles.Results,'Visible','off')
    displayMidResults(handles);
    
function displayMidResults(handles)
    if get(handles.rdFusionSortedList, 'Value')
        if exist('sortedResults.mat', 'file')
            load('sortedResults.mat');
            load('test_global.mat', 'test' )
            hMid=getappdata(0,'hMid');
%             colors = num2cell(gray(str2num(get(handles.txtNum,'String'))),2);
            axes(handles.axesResultsMid);
            for i=1:round(str2num(get(handles.txtNum,'String')))
                %Color
                path = test(ind_color(i)).filename;
                if isunix path = strrep(path, '\', '/'); end
                cur_image=imread(path);
                axes(hMid(i));
                cla;
                imshow(cur_image);
                th = title(num2str(sortedColorInd(i)),'FontSize',7.5,'FontWeight','bold');
                P = get(th,'Position'); set(th,'Position',[P(1) 0.1 P(3)])
                %Texture
                path = test(ind_texture(i)).filename;
                if isunix path = strrep(path, '\', '/'); end
                cur_image=imread(path);
                axes(hMid(i+round(str2num(get(handles.txtNum,'String')))));
                cla;
                imshow(cur_image);
                th = title(num2str(sortedTextureInd(i)),'FontSize',7.5,'FontWeight','bold');
                P = get(th,'Position'); set(th,'Position',[P(1) 0.1 P(3)])
            end
        end
    end


% --- Executes on button press in chboxSIFT.
function chboxSIFT_Callback(hObject, eventdata, handles)
% hObject    handle to chboxSIFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chboxColorSketch.
function chboxColorSketch_Callback(hObject, eventdata, handles)
% hObject    handle to chboxColorSketch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function dispQueryImg(handles)
    gridImg = ones(9,9,3);
    grid = getappdata(0,'props');
    [row,col]=deal(1);
    for index=1:9
       gridImg(3*(row-1)+1:3*(row),3*(col-1)+1:3*(col),:)=repmat(reshape(cell2mat(grid(index)),1,1,3),[3,3,1]); 
       col = col+1;
        if (col>3)
            col = 1; row = row+1;
        end
    end
    axes(handles.axesQuery);
    cla;
    setappdata(0,'image',gridImg);
    imshow(gridImg);
%     imshow(padarray(gridImg,[1 1]));

function timestr = sec2timestr(sec)
    % Convert a time measurement from seconds into a human readable string.
    % Convert seconds to other units
    w = floor(sec/604800); sec = sec - w*604800;% Weeks
    d = floor(sec/86400);  sec = sec - d*86400;% Days
    h = floor(sec/3600);   sec = sec - h*3600;% Hours
    m = floor(sec/60);     sec = sec - m*60;% Minutes
    s = sec; % Seconds
    format long g
    % Create time string
    if w > 0
        if w > 9 timestr = sprintf('%d week', w);
        else timestr = sprintf('%d week, %d day', w, d);
        end
    elseif d > 0
        if d > 9 timestr = sprintf('%d day', d);
        else timestr = sprintf('%d day, %d hr', d, h);
        end
    elseif h > 0
        if h > 9 timestr = sprintf('%d hr', h);
        else timestr = sprintf('%d hr, %d min', h, m);
        end
    elseif m > 0
        if m > 9 t = num2str(m); 
            if (length(t)>5)
                tend = 5;%timestr = sprintf('%d min', m);
            else
                tend = length(t);
            end
            timestr = [t(1:tend) ' min'];
        else t1 = num2str(m); t2 = num2str(s); 
            if (length(t1)>5&&length(t2)>5)
                tend=min(length(t1),length(t2));%timestr = sprintf('%d min, %d sec', m, s);
            else
                tend=5;
            end
            timestr = [t1(1:end) ' min' t2(1:end) ' sec'];
        end
    else
%         timestr = sprintf('%.3d sec', num2str(s));
        t = num2str(s);
        if length(t)>5 
            tend = 5;
        else
            tend = length(t);
        end
        timestr = [t(1:tend) ' sec'];       
    end


% --- Executes on button press in cmdSIFT.
function cmdSIFT_Callback(hObject, eventdata, handles)
% hObject    handle to cmdSIFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('test_global');
data={test.sift_global};
query_image=getappdata(0,'image');
I1=downsample(im2double(rgb2gray(query_image)),3,1);
I = (downsample(I1',3,1))';
[ ~, ~, ~, desc ]=SIFT( I, 4, 2, ones(size(I)), 0.05, 5.0, 0);
Dist=pemd(desc,data);
[val ind]=sort(Dist);
bag_of_word.on=0;
visualize(handles,val,ind,bag_of_word);
save('temp.mat','val','ind','bag_of_word');
