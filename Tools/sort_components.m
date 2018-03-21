function [outfiles,id] = sort_components(filelist)
%sort filelist such that seismograms are ordered as East, North, Vertical
% RWP edit adds mseed2sac functionality and allows components 1 and 2 to be
% aliased as E and N

global config

outfiles = filelist(1);
for n=1:size(filelist,1)
    %comp = sl_lh(filelist(n),'KCMPNM')
    fstr = char(filelist(n,:));

    switch config.FileNameConvention
        case 'RDSEED'
            %dynamic searching, since sometime a quality letter is given...
            dot  = findstr(fstr,'.');
            pos  = dot(end-1) - 1;
            % letter position of Component descriptor in filename
            % here: letter before second but last point
            % use for last letter: comp = fstr(end);
            % eg: 1994.130.06.35.24.9000.GR.GRA1..BHZ.D.SAC
            %     dot is [5 9 12 15 18 23 26 31 32 36 38]
            %     thus, pos would be 35
        
        case 'SEISAN'
            pos = length(fstr)-5;
            
        case 'mseed2sac1'
            % mseed2sac1 format: QT.ANIL.00.HHZ.D.2012,321,18:00:00.SAC  
            dot  = strfind(fstr,'.');
            pos  = dot(4) - 1;
        case 'mseed2sac2'
            % mseed2sac2 format: QT.ANIL.00.HHZ.D.2012.321.180000.SAC
            dot = strfind(fstr,'.');
            pos = dot(4)-1;
        case {'YYYY.MM.DD-hh.mm.ss.stn.sac.e', 'YYYY.JJJ.hh.mm.ss.stn.sac.e', '*.e; *.n; *.z', 'stn.YYMMDD.hhmmss.e', 'YYYY_MM_DD_hhmm_stnn.sac.e'}
            pos = length(fstr); %using last letter
        
        otherwise
                error('Component descriptor unknown! Abborting')
                return
    end



    comp = fstr(pos);
    switch upper(comp)
        case 'E'
            i=1;
        case 'N'
            i=2;
        case 'Z'
            i=3;
        case '1'
            i=1;
        case '2'
            i=2;
        otherwise
            thisfile = mfilename('fullpath');
            thisfile = strrep(thisfile, '\','\\');
            commandwindow
            error(strcat([' Unknown component description "' comp '" in file:\n'],...
                ['     ' fstr(1:pos-1) '<a href="">' fstr(pos) '</a>' fstr(pos+1:end)] ,...
                ['\n Assumed letter position of Component indicator: ' num2str(pos)],...
                [ '\n error in <a href="matlab:edit(''' thisfile ''')">sort_components</a>']),'\n')
    end

    outfiles(i)=filelist(n);
    id(i)=n;
end
