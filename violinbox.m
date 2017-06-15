% violinbox by Brad Hartl
% version 06/07/2017

% Example code:
% data1=rand(100,8); % first data set, columns represent the different variables
% data2=rand(100,8); % second data set (leave as [] if not comparing two data sets)
% color = 1; % sets color scheme to use
%     % []: defaults to misc colors
%     % scalar: selects from pre-defined colors below
%     % matrix: specifies color inputs (must be 3 columns and at least 1 rows, RGB ranging from 0 to 1.0)
% type = 1; % coloring mode (easier to just run code to see visually)
%     % 1: Color1 = all left plots, Color2 = all right plots
%     % 2: Color1 = 1st plot (L&R), Color2 = 2nd plot (L&R), ... etc.
%     % 3: Same as 2, but all right plots show up faded
%     % 4: Color1 = 1st plot (L), Color2 = 1st plot (R), Color2 = 2nd plot (L), ... etc.
% names = {'a','b','c','d','e','f','g','i'}; % x-axis labels (leave as [] if not used)
% violinbox(data1,data2,color,type,names)
% figure; for type = 1:4; subplot(4,1,type); violinbox(data1,data2,1,type,names); end % plots all 4 color schemes

% See ColorBrewer for more color schemes (colorbrewer2.org)
% Very easy to create new schemes by copy/pasting RGB values on website into 'colors' cell

function violinbox(data1,data2,clr,type,names)
% Creates variety of color schemes to choose from
% colors{1} = [55,126,184;228,26,28;77,175,74;152,78,163;255,127,0;255,255,51;166,86,40;247,129,191]/255;
% colors{2} = [146 197 222;190,174,212;127,201,127;253,192,134;56,108,176;255,138,195;191,91,23;102,102,102]/255;
% colors{3} = [5 113 176;146 197 222;217,95,14;202 0 32;123,50,148;194,165,207;166,219,160;0,136,55]/255;
% colors{4} = [35 48 62; 46 79 77; 55 115 89; 61 153 95; 132 170 80; 189 189 60; 243 209 16]/255; % bitone gradient
% colors{5} = [187 187 55; 57 76 96]/255;
% colors{6} = [26 79 99; 6 133 135; 111 176 127; 252 176 60; 252 91 63]/255;
% colors{7} = [5 113 176;217,95,14;202 0 32;123,50,148;194,165,207;166,219,160;0,136,55]/255;
% colors{8} = [190,174,212;141,211,199;252,187,161;251,106,74;203,24,29;255,127,0;255,255,51;166,86,40]/255;
% colors{9} = [55,126,184;217,95,14;146 197 222;202 0 32;123,50,148;194,165,207;166,219,160;0,136,55]/255;
% colors{10} = [152,78,163;252,187,161;251,106,74;203,24,29;255,127,0;255,255,51;166,86,40]/255;
% colors{11} = [5 113 176;217,95,14;152,78,163;202 0 32]/255;
% save 'colors.mat' colors

% handles the color input
load('colors.mat')
if size(clr) == [1 1]
    color = colors{clr};
elseif isempty(clr)
    color = colors{1};
    % color = rand(8,3); % random colors
else
    if size(clr,2) ~= 3 || max(max(clr)) > 1
        error('Wrong color matrix input')
    end
    color = clr;
end

% Misc variables that could be changed for future use
A = 1;  % Alpha value of all histogram colors
A2 = 1; % Alpha value of right histogram colors
hwid1 = 0.75; % histogram width
hwid2 = 0.9; % histogram width (compare mode)
bwiddiv = 3; % ratio of histogram width to boxplot width
bcolor = [1 1 1]; % boxplot background color
textrot = 45; % degrees text is rotated

% Adjusting color scheme
if type==1
    color = repmat([color(1,:) color(2,:)],[8 1]);
elseif type==2
    color = repmat(color,[1 2]);
elseif type==3
    color = repmat(color,[1 2]);
    A2 = 4;
elseif type==4
    if ~mod(size(color,2),2)
        error('Wrong color matrix input')
    else
        color = repmat(reshape(color',6,[])',[2 1]);
%         color = repmat([color(1,:) color(2,:); color(3,:)  color(4,:); ...
%             color(5,:) color(6,:); color(7,:)  color(8,:)],[2 1]);
    end
end
color = repmat(color,[ceil(size(data1,2)/size(color,1)) 1]);

% Reshaping data based on plot type
if isempty(data2)
    data = data1;
else
    if size(data1,2) ~= size(data2,2)
        error('Data set sizes do not match')
        return
    end
    data = NaN(max([size(data1,1) size(data2,1)]),size(data1,2)+size(data2,2));
    data(1:size(data1,1),1:2:size(data,2)) = data1;
    data(1:size(data2,1),2:2:size(data,2)) = data2;
end

% Fitting curves to histograms
dataout = cell(size(data,2),1);
f = figure;
krn = 100;
for i = 1:size(data,2)
    if sum(~isnan(data(:,i))) > 0
        figure(f); h = histfit(data(:,i),krn,'kernel'); title(num2str(i)); % subplot(1,4,i);
        dataout{i,1}(:,1) = h(2).XData;
        dataout{i,1}(:,2) = h(2).YData/sum(h(2).YData)/(h(2).XData(end)-h(2).XData(1));
    end
end
close(f)

if isempty(data2)
    bwid=hwid1/bwiddiv;
    % Plotting histograms (sinlge mode)
    hold on;
    for i=1:size(data,2)
        if sum(~isnan(data(:,i))) > 0
            patch_x = [dataout{i,1}(:,1); flipud(dataout{i,1}(:,1))];
            patch_y = [dataout{i,1}(:,2); zeros(length(dataout{i,1}(:,2)),1)]/max(dataout{i,1}(:,2))*hwid1;
            h(i) = patch(i-patch_y,patch_x,color(i,1:3),'facealpha',A,'edgecolor','none');
        else
            h(i) = patch([0 0 0 0],[0 0 0 0],color(i,1:3),'facealpha',0,'edgecolor','none');
        end
    end
    % Plotting boxplots (single mode)
    bx = boxplot(data,'Symbol','','colors','k','Widths',ones(1,size(data,2))*bwid); %'PlotStyle','compact', ,'BoxStyle','filled'
    h = findobj(gca,'Tag','Box');
    for j=1:length(h)
        patch(get(h(j),'XData'),get(h(j),'YData'),bcolor,'FaceAlpha',1,'edgecolor','none');
    end
    delete(bx);
    bx = boxplot(data,'Symbol','','colors','k','Widths',ones(1,size(data,2))*bwid);
    set(bx,'LineWidth',2);
    set(gca,'XTickLabel',names,'XTickLabelRotation',textrot);
else
    bwid=hwid2/bwiddiv;
    % Plotting histograms (compare mode)
    hold on;
    for i=1:size(data,2)
        if mod(i,2)==1
            patch_x = [dataout{i,1}(:,1); flipud(dataout{i,1}(:,1))];
            patch_y = [dataout{i,1}(:,2); zeros(length(dataout{i,1}(:,2)),1)]/max(dataout{i,1}(:,2))*hwid2;
            h(i) = patch(ceil(i/2)*2-1-patch_y,patch_x,color(ceil(i/2),1:3),'facealpha',A,'edgecolor','none'); %,'edgecolor','none'
        else
            patch_x = [dataout{i,1}(:,1); flipud(dataout{i,1}(:,1))];
            patch_y = [dataout{i,1}(:,2); zeros(length(dataout{i,1}(:,2)),1)]/max(dataout{i,1}(:,2))*hwid2;
            h(i) = patch(ceil(i/2)*2-1+patch_y,patch_x,color(ceil(i/2),4:6),'facealpha',A/A2,'edgecolor','none');
        end
    end
    % Plotting boxplots (compare mode)
    pos = ceil((1:size(data,2))/2)*2-1;
    pos(1:2:size(data,2)) = pos(1:2:size(data,2))-bwid/2;
    pos(2:2:size(data,2)) = pos(2:2:size(data,2))+bwid/2;

    bx = boxplot(data,'positions',pos,'Symbol','','colors','k','Widths',ones(1,size(data,2))*bwid); %'PlotStyle','compact', ,'BoxStyle','filled'
    h = findobj(gca,'Tag','Box');
    for j=1:length(h)
        patch(get(h(j),'XData'),get(h(j),'YData'),bcolor,'FaceAlpha',1,'edgecolor','none');
    end
    delete(bx);
    bx = boxplot(data,'positions',pos,'Symbol','','colors','k','Widths',ones(1,size(data,2))*bwid);
    set(bx,'LineWidth',2);
    set(gca,'XTick',[1:2:size(data,2)-1]);
    set(gca,'XTickLabel',names,'XTickLabelRotation',textrot);
end

% Plot adjustments
xlim([0.75-bwid*3 size(data,2)+bwid]);
minmax = [nanmin([dataout{:}]);nanmax([dataout{:}])];
minmax = minmax(:,1:2:size([dataout{:}],2));
dif = max(minmax(2,:))-min(minmax(1,:));
ylim([min(minmax(1,:))-dif*0.1 max(minmax(2,:))+dif*0.1]);
end