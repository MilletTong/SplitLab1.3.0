function SL_showeqstats
%Show distribution of earhquakes in SplitLab eq-structure
%
% 1) Histogram plot with backazimuthal variation (24 bins, each 15�)
%    it also displays the 180� folded distribution, i.e. opposite
%    backazimuths are summed up and displayed in light gray
% 2) Rose plot of same data
% 3) Map with earthquake locations (eqdazim projection; centered at Station)
%    using scatterm, with colors correspondig to depth, and size to
%    magnitude Mw. If more than 700 are to be plotted, only locations are
%    plotted
%
% See also SL_eqwindow POLARGEO ROSE HIST AXESM SCATTERM

% A.W. July 2005

% Update Feb 2014 by Rob Porritt
% Checks for mapping toolbox and adjusts to work without it



global config eq
TIMEwin = config.twin;
SKSwin  = config.eqwin;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INTIALIZE FIGURE:
%load topo
[p,f] = fileparts(mfilename('fullpath'));
% Checks for existance of mapping toolkit
if license('checkout', 'MAP_Toolbox')
load coast
load plates.mat;
end

eqfig=findobj('name','Earthquake distribution','Type','Figure');
if isempty(eqfig)
    pos=get(0,'ScreenSize')+[0 40 0 -110];%
    eqfig = figure('name', 'Earthquake distribution',...
        'Renderer',        'painters',...
        'NumberTitle',     'off',...
        'MenuBar',         'none',...
        'PaperType',       config.PaperType,...
        'PaperOrientation','landscape',...
        'PaperUnits',      'normalized',...
        'PaperPosition',   [.05 .05 .9 .9],...
         'position',        pos);
else
    figure(eqfig)
    clf
end
orient landscape
        m4 = uimenu(eqfig,'Label',   'Figure');
uimenu(m4,'Label',  'Save current figure',  'Callback','exportfiguredlg(gcbf, [config.stnname ''_EQstats'' config.exportformat], config.savedir)');
uimenu(m4,'Label',  'Page setup',           'Callback','pagesetupdlg(gcbf)');
uimenu(m4,'Label',  'Print preview',        'Callback','printpreview(gcbf)');
uimenu(m4,'Label',  'Print current figure', 'Callback','printdlg(gcbf)');



pos = get(gcf,'Position');
pos = [fix(pos(3)/2-150) fix(pos(4)/2-25) 300 50];
msg = uicontrol('Style','Text','Units','Pixel','Position',pos,...
    'String','Please wait...','FontSize',20, 'BackgroundColor', get(gcf,'Color'));
drawnow

%% Map
if length(eq)==0
    errordlg({'No earthquakes in memory!', 'Please ensure that variable "eq" is global in workspaces'},'Empty variable')
elseif length(eq)>700
    simple = 1;
    stnnameColor = 'y';
    circleColor  = 'm';
else
    simple = 0;
    stnnameColor = 'k';
    circleColor  = 'k';
end
%%
ax = subplot(1,2,2,'Parent',eqfig);
axes(ax);
% Checks for existance of mapping toolkit
if license('test', 'MAP_Toolbox')
    ax             = axesm('eqdazim','origin',[config.slat,config.slong]);
    plotm(PBlat, PBlong, 'LineStyle','-','Linewidth',1,'Tag','Platebounds','Color',[1.2 1 1]*.8)
else
    %ax = axes('eqdazim','origin',[config.slat,config.slong]);
    %plot(PBlat, PBlong, 'LineStyle','-','Linewidth',1,Color',[1.2 1 1]*.8)
end

if license('test', 'MAP_Toolbox')
%     if simple==1
%         %%simple plotting; faster for large amount of eqs
%         %%use this if topography is plotted using the meshm line (see above)
%         load topo
%         m  = meshm(topo,topolegend,[180 360]);
%         demcmap(topo)
%         e = plotm ([eq(:).lat],[eq(:).long],'r.');
  %  else
        %This takes more computational time, but results in fancy plots :-)
        c    = fillm(lat   ,long  ,'FaceColor',[1 1 1]*.85,'EdgeColor','none','Tag','Continents');

        L = 20;%number of colors in colorbar
        cmap= hot(30);
        colormap(cmap(5:27,:))

        mini = floor(min([eq(:).depth])); 
        maxi = ceil(max([eq(:).depth]));
        mini= round(mini/10)*10;
        maxi= round(maxi/10)*10;
        if maxi-mini < 100
            caxis([mini mini+100]);%colorscale of markers 
        else
            caxis([mini maxi])
        end

        pos   = get(gca,'Position');
        cbheight = pos(4)*.5; %colobar options
        cbwidth  = .015;
        cbx      = (pos(1)+pos(3))*1.035;
        cby      = (pos(2))+cbheight/2;
        cb       = colorbar('ylim',caxis,'position',[cbx, cby, cbwidth, cbheight],'Ydir','reverse');
        xlabel(cb,'depth');

        la  = [eq(:).lat]';
        lo  = [eq(:).long]';
        siz = [eq(:).Mw]'.^10;    % make marker size more dependend on magnidude: enhance to power of 10
        siz = 100*siz/min(siz) + config.Mw(1)^2;% area of each marker is determined by the values (in points^2) 
        col = [eq(:).depth]';
        e = scatterm(la, lo , siz, col ,'.');
  %  end


    [latlow,lonlow]= scircle1(config.slat, config.slong, SKSwin(1));
    [latup,lonup]  = scircle1(config.slat, config.slong, SKSwin(2));
    %f(1) = plotm(latlow, lonlow, '--', 'Color',circleColor, 'linewidth',1);%SKSwindow
    %f(2) = plotm(latup , lonup , '--', 'Color',circleColor, 'linewidth',1);
plotm(latlow, lonlow, '--', 'Color',circleColor, 'linewidth',1);
plotm(latup , lonup , '--', 'Color',circleColor, 'linewidth',1);
    %station marker
    b   = plotm(config.slat, config.slong,'k^','MarkerFaceColor','r','MarkerSize',8);

    %% plot annotation
    if simple 
        stnnameColor = 'y';
    else

    end
    t(3)=textm(...
        config.slat-3, config.slong, config.stnname,...
        'color', stnnameColor,...
        'horizontalalignment','center',...
        'verticalalignment','top',...
        'FontWeight','demi');

    dates = [[eq(1).dstr] ' -- ' [eq(end).dstr]];
    wmin  = [num2str(SKSwin(1)) '\circ'];
    wmax  = [num2str(SKSwin(2)) '\circ'];
    title({['Earthquakes in window  [' wmin ' - ' wmax ,...
        ']  around station ' config.stnname],...
        [  dates ],...
        [num2str(config.Mw(1)) ' \leq M_w \leq ' num2str(config.Mw(2))],...
        [num2str(config.z_win(1)) ' \leq depth \leq ' num2str(config.z_win(2))]})

    t(1) = textm(latup(50) ,lonup(50),wmax, 'verticalalignment','top','horizontalalignment',   'center', 'Color', circleColor);
    t(2) = textm(latlow(50),lonlow(50),wmin,'verticalalignment','Bottom','horizontalalignment','center', 'Color', circleColor);

    %gridm on
    framem('FLinewidth',2,'FFaceColor','w')
    axis off
    
else  % Quick and dirty without mapping toolbox
    hold on
    % matlab structures included with this distribution
    load SL_plates.mat
    load SL_coasts.mat
    % etopo from http://www.ngdc.noaa.gov/mgg/global/global.html
%     if exist('ncread')
%       topoElevation = ncread('ETOPO1_Ice_g_gmt4_1deg.grd','z');
%       topoLatitude = ncread('ETOPO1_Ice_g_gmt4_1deg.grd','lat');
%       topoLongitude = ncread('ETOPO1_Ice_g_gmt4_1deg.grd','lon');
%       lon=repmat(topoLongitude,1,length(topoLatitude));
%       lat=repmat(topoLatitude,1,length(topoLongitude));
%       e = contourf(lon,lat',topoElevation);
%     end
    pos = get(ax,'Position');
    pos(4) = pos(4) * 0.5;
    pos(2) = pos(2) * 3;
    pos(3) = pos(3) * 1.2;
    set(ax,'Position',pos)
    colormap(gray);
    f = plot(PBlong,PBlat, 'LineStyle','-','Linewidth',1,'Tag','Platebounds','Color',[1.2 1 1]*.8);
    g = plot(ncst(:,1),ncst(:,2),'k');
    h = plot([eq(:).long],[eq(:).lat],'r.','MarkerSize',8);
    %station marker
    i = plot(config.slong, config.slat,'k^','MarkerFaceColor','r','MarkerSize',8);
    axis([-180 180 -90 90])
    ylabel('Latitude');
    xlabel('Longitude');
    legend([i,h,f],'Station','Earthquakes','Plate Boundaries');
    cb = colorbar('SouthOutside');
    xlabel(cb,'Elevation (km)');
%     pos   = get(ax,'Position');
%     cbheight = pos(4)*.5; %colobar options
%     cbwidth  = .015;
%     cbx      = (pos(1)+pos(3))*1.035;
%     cby      = (pos(2))+cbheight/2;
%     cb       = colorbar('ylim',caxis,'position',[cbx, cby, cbwidth, cbheight],'Ydir','reverse');
%     xlabel(cb,'depth');


    hold off
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Histogram
ax=subplot(2,2,1,'Parent',eqfig);
axes(ax);
bin_center = [7.5:15:352.5];
n          = hist([eq(:).bazi],bin_center);
n2         = hist(mod([eq(:).bazi],180),bin_center);
hbar       = bar(bin_center,n2,'y');
set(hbar,'Facecolor',[1 1 1]*.9 , 'edgecolor','none')
hold on
bar2 = bar(bin_center, n, 'g');
hold off
text(bin_center,n, num2str(n'),...
    'color','r',...
    'VerticalAlignment','bottom',...
    'HorizontalAlignment','center',...
    'Fontsize',7);
xlim([0 360])
set(gca,'Xtick',0:45:360)
xlabel('Backazimuth [degrees] ')
ylabel({'Number of events',['total: ' num2str(length([eq(:).lat]))]})
title({['Histogram of back-azimuthal earthquake distribution around ' config.stnname],
    ['Earthquake window: ' num2str(SKSwin)]})
legend([hbar,bar2],'Azimuth','BackAzimuth')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Polarplot
ax=subplot(2,2,3,'Parent',eqfig);
axes(ax);
[a,b] = rose([eq(:).bazi]/180*pi, bin_center/180*pi);
polargeo(a,b);
bins = findobj('Parent', gca,'Type','Line', 'Color','b');
patch(get(bins,'xdata'), get(bins,'ydata'), 'g');

set(0,'ShowHiddenHandles','on')
delete(findobj('Tag','RadiusText'))
set(0,'ShowHiddenHandles','off')


f = max(xlim)*.7;
set(gca,'xtickLabel','');
x = cos((90-bin_center)/180*pi)*f;
y = sin((90-bin_center)/180*pi)*f;

text(x,y, num2str(n'),...
    'color','r',...
    'VerticalAlignment','Middle',...
    'HorizontalAlignment','center',...
    'Fontsize',7);

%%
delete(msg)
%% This program is part of SplitLab
% � 2006 Andreas W�stefeld, Universit� de Montpellier, France
%
% DISCLAIMER:
% 
% 1) TERMS OF USE
% SplitLab is provided "as is" and without any warranty. The author cannot be
% held responsible for anything that happens to you or your equipment. Use it
% at your own risk.
% 
% 2) LICENSE:
% SplitLab is free software; you can redistribute it and/or modifyit under the
% terms of the GNU General Public License as published by the Free Software 
% Foundation; either version 2 of the License, or(at your option) any later 
% version.
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
% more details.
