function config=SL_defaultconfig
%set the main variables for spliting toolbox

config.version ='SplitLab1.2.1';

 if ispc
    config.host= getenv('COMPUTERNAME');
    user = getenv('USERNAME');
    home =  getenv('USERPROFILE');
else
    config.host = getenv('HOSTNAME');
    user= getenv('USER');
    home= getenv('HOME');
 end



[p,f] = fileparts(mfilename('fullpath'));  % directory of Splitlab

%% default locations: change to your needs
config.project  = 'default_project.pjt';
config.datadir     = home;
config.projectdir  = home;
config.savedir     = home;
config.calcphase   = true;
config.calcEnergy  = true;
config.showstats   = true;
%% Change to your needs.... 
config.stnname  = '???';     % Name of seimic station
config.netw     = '??';     % Seimmic network code of the station
config.locid    = '*';
config.slat     = [0];     % Latitude of station
config.slong    = [1];     % Longitude of station
config.elev     = [];
config.rotation = 0;% station is rotated? in degrees clockwise from north
config.SwitchEN = false; %East and North components have been exchanged?
config.signE    = 1; % 1: East componenent points East (the standard);     -1 == East componenent points West 
config.signN    = 1; % 1: North componenent points North(the standard);    -1 == North componenent points South 
config.serviceDataCenter = 'http://service.iris.edu';
config.ChannelSet = 'BHE,BHN,BHZ';
config.requestedSampleRate = 20;
config.fetchOriginOffset = '0';
config.fetchDuration = '3600';
config.requestedResponseRemoval = 'No Removal';
config.restrictedAccessUserName = 'Joe.Seismologist';
config.restrictedAccessPassword = 'Default_Password';
config.restrictedAccess = cell(1,2);

config.eqwin    = [90 130];   % search window in degrees around station
config.z_win    = [0 1000];   % search window depth in km
                 d = datevec(now);
config.twin     = [03 01 1976 ,d(3) d(2) d(1)]; % timewindow 
config.Mw      = [5  9.75];        % [minimum maximum] magnitude (Mw) of earthquake

config.catalogue= fullfile(p,'GLOBALCMT.mat');
config.catformat='CMT';
config.FileNameConvention = 'RDSEED';
config.searchstr= '*.SAC'; % ['*.' config.stnname '*.sac'];
config.searchdt = 420; %== 7 minutes search interval for filetime/hypotime match
config.offset   = 0;%

config.request.label     = 'label'; 
config.request.format    = 'NetDC';
% config.request.reqfile  = 'splitlab.req';
config.request.reqtime   = [-60 40*60]; %buffer time (sec) of request before hypotime; eg: [-60 40*60] is 60s before hypo and 40 minute duration
config.request.comp      ='BH?';
config.request.timestamp ='???';

config.request.user     = user; %'defaultuser';
config.request.usermail = [config.request.user '@'];
config.request.institut = '';
config.request.adress   = '99 Example Road, 12345 Mytown, Mycountry'; %breqfast request required
config.request.phone    = '';
config.request.fax      = '';

% add or delete datacenters as cell entries: they will be displayed in selection menu
config.request.DataCenters={'breq_fast@gfz-potsdam.de';'breq_fast@iris.washington.edu';'netdc@fdsn.org';'netdc@ipgp.jussieu.fr';'netdc@knmi.nl';'netdc@iris.washington.edu';'autodrm@iris.washington.edu'};
config.request.mailto   = char(config.request.DataCenters(2));
config.phases   = {'P','PP','PPP','Pdiff','PKS','PcP','PcS','SP','S','SS','SKS','SKKS','SKiKS','ScS','sSKS','pSKS','SKP','pPKS'};
config.earthmodel='iasp91';%'prem'

config.PaperType    = 'A4';
config.exportformat = '.pdf'; % default figure export format 
                              % valid strings :
                              %'.ai','.eps', '.fig', '.jpg',  '.pdf',
                              %'.ps','.png', '.tiff'
                              
config.comment='';
config.UseHeaderTimes   = 0;% extract file beginning from file name (0) or from header (1) 
config.tablesortcolumn  = 1;% column by which to sort data per default in Database viewer
config.splitoption      = 'Minimum Energy';
config.inipoloption     = 'fixed'; %for EV method: initial fixed (from backazimuth) or estimated from wave form  
config.resamplingfreq   = 'raw'; %resample seismogram frequncy; give as string
config.maxSplitTime     = 4; %maximum time to search for delay in inversion
config.db_index         = []; 



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
