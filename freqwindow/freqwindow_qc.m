function []=qcfreqwindow(indir,outdir,unfiltdir,varargin)
%FREQWINDOW    Interactive multi-frequency QCing & windowing of event data
%
%    Usage:    qcfreqwindow(indir,outdir,unfiltdir)
%              qcfreqwindow(indir,outdir,unfiltdir,'option',value,...)
%
%    Description:
%     FREQWINDOW(INDIR,OUTDIR) provides an interface aiding in windowing &
%     quality control management of good surface wave array data for a series of
%     narrow frequency bands.  This is useful to eliminate noisy data from
%     two-plane wave analysis and get the windows "just right".  Starting
%     windows are determined using the CUB2 model and an empirical formula.
%     The surface waves are cut out using the window, tapered and then
%     subjected to SNR-based quality control.  The taper width is 0.2, the
%     SNR cutoff is 3 (using the peak2rms method), & the noise windows are
%     0.5 the signal window on either side.  Output records are written
%     under OUTDIR (see the Notes section for directory structure details)
%     and are padded with zeros so that the records extend from -2000 to
%     7000 seconds relative to the origin time.  The filter bank is created
%     using the following:
%      flipud(filter_bank([0.0055 0.055],'variable',0.2,0.1))
%     This means that filters proceed from short period to long period.
%
%     FREQWINDOW(INDIR,OUTDIR,'OPTION',VALUE,...) alters the specified
%     parameter(s) given by 'OPTION' to VALUE.  The following are valid:
%      'bank'       - filter bank (FILTER_BANK format)
%      'snrcut'     - SNR cutoff (3)
%      'snrwin'     - SNR noise window relative width (0.5)
%      'snrmethod'  - SNR method ('peak2rms')
%      'taperwidth' - Taper width (0.2)
%      'padwin'     - Zero-Padding limits ([-2000 7000])
%      'model'      - surface wave travel time model ('CUB2' - see TTSURF)
%      'wave'       - surface wave type ('Rayleigh')
%      'speed'      - surface wave speed type ('group')
%      'normstyle'  - record normalization style in plots ('single')
%
%    Notes:
%     - If OUTDIR exists the user is presented with the opportunity to
%       overwrite or delete the contents of OUTDIR or to exit the program.
%       DELETING WILL DELETE ONLY THE DIRECTORIES CORRESPONDING TO THE
%       EVENT+FILTER WHEN IT IS BEING SAVED.  This minimizes the impact of
%       this operation, allowing focused reprocessing.
%     - The directory structure should look as follows (the names are
%       allowed to be different ie. EVENTDIR1 may be 2006.044.04.03.55.9):
%        INDIR
%          |
%          --> EVENTDIR1
%          --> EVENTDIR2
%          .
%          .
%          --> EVENTDIRN
%                   |
%                   --> RECORD1
%                   --> RECORD2
%                   .
%                   .
%                   --> RECORDN
%     - The output directory structure (note the extra layer of directories
%       for each narrow-band filter):
%        OUTDIR
%           |
%           --> EVENTDIR1
%           --> EVENTDIR2
%           .
%           .
%           --> EVENTDIRN
%                    |
%                    --> 01-CPERIOD1
%                    --> 02-CPERIOD2
%                    .
%                    .
%                    --> XX-CPERIODX
%                        |
%                        --> RECORD1
%                        --> RECORD2
%                        .
%                        .
%                        --> RECORDN
%
%    Examples:
%     % Be a little stricter on noise allowance:
%     freqwindow(INDIR,OUTDIR,'snrcut',5);
%
%    See also: GOODUGLYCHECK, MAKEKERNELS, PLOTKERNELS

%     Version History:
%        Apr. 22, 2010 - major code cleanup and added documentation
%        Jan. 23, 2011 - full rewrite
%        Apr.  5, 2011 - warn on event location variation
%        Apr. 17, 2011 - normstyle option, ylimit bugfix for zero good,
%                        axes handle bugfix, userwindow bugfixes
%        June  5, 2011 - selectrecords has normstyle too
%        June  8, 2011 - fixed snr cut bug when adjusting window or moveout
%        Aug. 20, 2012 - edited original filtering and windowing script to 
%                        edit existing filtered and windowed files
%                        adaptation by Aubreya Adams
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated June  8, 2011 at 10:35 GMT

% todo:
% - single trace is not scaling properly (flatline) for shawn

% check nargin
error(nargchk(3,inf,nargin));
if(mod(nargin,3))
    error('seizmo:qcfreqwindow:uppairedOption',...
        'One (or more) input OPTION/VALUE is unpaired!');
end

% directory separator
fs=filesep;

% check indir
if(~isstringb(indir) || ~isdir(indir))
    error('seizmo:qcfreqwindow:badInput',...
        'INDIR must be a directory location!');
end

% check unfiltdir
if(~isstringb(unfiltdir) || ~isdir(unfiltdir))
    error('seizmo:qcfreqwindow:badInput',...
        'UNFILTDIR must be a directory location!');
end

% check outdir
reply='o';
if(~isstringb(outdir))
    error('seizmo:qcfreqwindow:badInput',...
        'OUTDIR must be a valid directory path!');
elseif(exist(outdir,'file') && ~isdir(outdir))
    error('seizmo:qcfreqwindow:badInput',...
        'OUTDIR location is a file!');
elseif(isdir(outdir))
    fprintf('Directory: %s\nDirectory Exists!\n',outdir);
    reply=input('Overwrite/Delete/Quit? O/D/Q [Q]: ','s');
    if(strncmpi(reply,'o',1))
        disp(['Overwriting (But Not Deleting) ' ...
            'To-Be-Selected Event Directories!']);
    elseif(strncmpi(reply,'d',1))
        % only delete selected event directories
        disp('Deleting Contents of Processed Filter Directories!');
        
        % the code below deletes the entire superdirectory (too dangerous)
        %if(~rmdir(outdir,'s'))
        %    error('seizmo:freqwindow:couldNotDelete',...
        %        'Could Not Delete Directory: %s',outdir);
        %end
    else % quiting
        disp('Quiting!');
        return;
    end
end

% default parameters / user-supplied alterations
p=parse_freqwindow_param(varargin{:});
nfilt=size(p.bank,1);

% get date directories
events=dir(indir);
events(strcmp({events.name},'.') | strcmp({events.name},'..'))=[];
events(~[events.isdir])=[];
eventlist=char(strcat({events.name}.'));

% get user selected start date
s=listdlg('PromptString','Select events:',...
          'InitialValue',1:numel(events),...
          'ListSize',[170 300],...
          'ListString',eventlist);

% loop over user selected events
for i=s(:)'
    % display event name
    disp(events(i).name);
    
    % loop over each filter (short period to long)
            skipall=false;
    j=1;
    
    while(j<=nfilt)
    %while(j<=2)
            %for j=1:nfilt
                % display filter
                 sfilt=num2str(j,'%02d');
                 evalfilt = [indir '/' events(i).name '/' sfilt '-' num2str(1/p.bank(j,1)) 's'];
                 disp(evalfilt)
                 if(isdir(evalfilt))

                   disp(['Band: ' sfilt '  Period: ' num2str(1/p.bank(j,3)) '-' ...
                        num2str(1/p.bank(j,2)) 's']);


                    % get filt data
                    seismo=dir(evalfilt);
                    seismo(strcmp({seismo.name},'.') | strcmp({seismo.name},'..'))=[];
                    disp([indir fs events(i).name fs sfilt '-' num2str(1/p.bank(j,1)) 's' fs '*']);
                    procdata=readseizmo([indir fs events(i).name fs sfilt '-' num2str(1/p.bank(j,1)) 's' fs '*']);
                    procdata=sortbyfield(procdata,'gcarc');
                    nrecs=numel(procdata);
                    
                    % get raw data
                    for k=1:nrecs
                        disp([unfiltdir '/' events(i).name '/' seismo(k).name]);
                        data(k)=readseizmo([unfiltdir fs events(i).name fs seismo(k).name]);
                        
                    end
                    data=sortbyfield(data,'gcarc');

                    % record coloring
                    cmap=hsv(nrecs);

                    % get some header info
                    [st,ev,delaz,outc,o0]=getheaderb(data,'st','ev','delaz','o utc','o');
                    outc=cell2mat(outc);
                    ev=unique(ev(:,[1 2 4]),'rows');
                    if(size(ev,1)>1)
                        warning('seizmo:qcfreqwindow:muddledHeader',...
                            'Looks like EVENT location info varies among records!');
                    elseif(any(abs(timediff(outc(1,:),outc))>0.002))
                        error('seizmo:qcfreqwindow:oUTCFieldVaries',...
                            'ORIGIN time varies among records!');
                    end

                    % get array center
                    % - kinda wonky as it changes the center with each event's
                    %   data but this makes sense for a more general case
                    [clat,clon]=arraycenter(st(:,1),st(:,2));
                    [caz,caz]=sphericalinv(ev(1),ev(2),clat,clon);

                    % "closest"/"farthest" station on event/center path
                    [minlat,minlon]=sphericalfwd(ev(1),ev(2),min(delaz(:,1)),caz);
                    [maxlat,maxlon]=sphericalfwd(ev(1),ev(2),max(delaz(:,1)),caz);
                    stlalo=[minlat minlon; maxlat maxlon];


                    % filter data
                    fdata=iirfilter(data,'bp','butter','c',p.bank(j,2:3),'o',4,'p',2);

                    % reset origin time
                    o=o0;

                    % initial window width
                    L_beat=1./(p.bank(j,3)-p.bank(j,2));
                    win=L_beat*(2.5+1000*p.bank(j,1).^2);
                    win=[-win/2 win/2];
                    xlimits=win+[-1 1]*diff(win);

                    % travel time to "closest"/"farthest"
                    tt=ttsurf(p.model,p.wave,p.speed,1/p.bank(j,1),ev(1:2),stlalo);

                    % moveout across array
                    mvin=6371*pi/180*(max(delaz(:,1))-min(delaz(:,1)))/diff(tt);

                    % loop until user is happy with this band
                    unsatisfied=true; good=true(nrecs,1); deleting=false;
                    firsttime=0;
                    while(unsatisfied)
                        if(nrecs<=1) 
                            unsatisfied=false;
                        end
                            
                        % skipping calculations if we just deleted some records
                        if(~deleting)
                            if(nrecs>1)
                            % timeshift records
                                z=o+tt(1)+(delaz(:,4)-min(delaz(:,4)))./mvin;
                            else
                                z=0;
                            end
                            fdata=timeshift(fdata,-z);
                            o=getheaderb(fdata,'o');
                            fwdata=timeshift(procdata,-z);
                            o=getheaderb(fdata,'o');
                            
                            %if flag firsttime is not zero, then rewindow data
                            %otherwise, show the previously processed data
                                % window, taper, snrcut
                                gdata=cut(fdata,win(1),win(2),'fill',true);
                                gdata=taper(gdata,p.taperwidth);
                                gdata=cut(gdata,o+p.pad(1),o+p.pad(2),'fill',true);
                                gdata=changeheader(gdata,'a',win(1),'ka','winbgn',...
                                    'f',win(2),'kf','winend');
                                twin1=[win(1) win(1)+p.taperwidth*diff(win)];
                                twin2=[win(2)-p.taperwidth*diff(win) win(2)];
                                nwin1=[win(1)-p.snrwin*diff(win) win(1)]-eps;
                                nwin2=[win(2) win(2)+p.snrwin*diff(win)]+eps;
                                bad1=p.snrcut>quicksnr(fdata,nwin1,win,p.snrmethod);
                                bad2=p.snrcut>quicksnr(fdata,nwin2,win,p.snrmethod);
                                good=~(bad1 | bad2) & good;
                            if(firsttime==0)
                                clear('gdata');
                                gdata=transpose(fwdata);
                            end
                           
                        end

                        % plot raw filtered data beside good, clean records
                        fh=figure('name',['FREQWINDOW - ' events(i).name ...
                            ' - BAND ' num2str(j) ' - ' num2str(1/p.bank(j,1)) 's'],'color','k');
                        ax=makesubplots(1,2,1,'parent',fh);
                        maximize(fh);
                        ax(1)=recordsection(fdata,'normstyle',p.normstyle,...
                            'xlim',xlimits,'ax',ax(1),'cmap',cmap);
                        ylimits1=ylim(ax(1));

                        % plotting good, cleaned records if any
                        if(sum(good))
                            % only set ylimits if sum(good)==1
                            if(sum(good)==1)
                                tmp={'ylim' ylimits1};
                            else
                                tmp={};
                            end

                            % plot good & cleaned records
                            ax(2)=makesubplots(1,2,2,'parent',fh);
                            ax(2)=recordsection(gdata(good),...
                                'xlim',xlimits,tmp{:},'normstyle',p.normstyle,...
                                'ax',ax(2),'cmap',cmap(good,:));
                            ylimits2=ylim(ax(2));

                            % get best ylimits
                            ylimits(1)=min(ylimits1(1),ylimits2(1));
                            ylimits(2)=max(ylimits1(2),ylimits2(2));

                            % fix ylimits, link axes
                            ylim(ax(1),ylimits);
                            linkaxes(ax);

                            % plot noise/taper sections
                            hold(ax(2),'on');
                            ph(1)=patch(nwin1([1 2 2 1]),ylimits([1 1 2 2]),...
                                [.3 0 0],'parent',ax(2));
                            ph(2)=patch(nwin2([1 2 2 1]),ylimits([1 1 2 2]),...
                                [.3 0 0],'parent',ax(2));
                            ph(3)=patch(twin1([1 2 2 1]),ylimits([1 1 2 2]),...
                                [.7 .6 0],'parent',ax(2));
                            ph(4)=patch(twin2([1 2 2 1]),ylimits([1 1 2 2]),...
                                [.7 .6 0],'parent',ax(2));
                            %movekids(ph,'back');
                            uistack(ph(:),'bottom');
                            hold(ax(2),'off');
                        else % no records meet conditions!
                            % would be cool to put some text in place of axes
                            warning('seizmo:qcfreqwindow:noRecordsPass',...
                                'No records meet the SNR/user specifications!');
                            ylimits=ylimits1;
                        end

                        % plot noise/taper sections
                        hold(ax(1),'on');
                        ph(1)=patch(nwin1([1 2 2 1]),ylimits([1 1 2 2]),...
                            [.3 0 0],'parent',ax(1));
                        ph(2)=patch(nwin2([1 2 2 1]),ylimits([1 1 2 2]),...
                            [.3 0 0],'parent',ax(1));
                        ph(3)=patch(twin1([1 2 2 1]),ylimits([1 1 2 2]),...
                            [.7 .6 0],'parent',ax(1));
                        ph(4)=patch(twin2([1 2 2 1]),ylimits([1 1 2 2]),...
                            [.7 .6 0],'parent',ax(1));
                        %movekids(ph,'back');
                        uistack(ph(:),'bottom');
                        hold(ax(1),'off');

                        % super title
                        axmove(ax,[],-.03);
                        supertitle(ax,{[events(i).name ' - ' ...
                            num2str(1/p.bank(j,1)) 's'] ''},'color','w');

                        % ask user
                        choice=0;
                        while(~choice)
                            choice=menu('Choose An Option:',...
                                'Write & Continue',...
                                'Delete Windowed Records',...
                                'Adjust Window',...
                                'Adjust Moveout',...
                                'Skip This Filter (wont cp other filters)',...
                                'Skip Remaining Filters (wont cp other filters)',...
                                'Jump To Filter ...');

                            switch choice
                                case 1 % write
                                    % save plot
                                    if(ishandle(fh))
                                        saveas(fh,['qcfreqwindow_' events(i).name ...
                                            '_band' sfilt '_' ...
                                            num2str(1/p.bank(j,1)) 's.fig']);
                                    end

                                    % shift to origin
                                    gdata=timeshift(gdata,-o,'io');

                                    % delete filter directory if exists
                                    % and user wanted that to happen
                                    fdir=[outdir fs events(i).name fs sfilt '-' num2str(1/p.bank(j,1)) 's' ];
                                    if(strncmpi(reply,'d',1))
                                        if(isdir(fdir))
                                            if(~rmdir(fdir,'s'))
                                                error('seizmo:qcfreqwindow:dirFail',...
                                                    'Can Not Delete Directory: %s',...
                                                    fdir);
                                            end
                                        end
                                    end
                                    %Only writes out those events that were
                                    %not deleted.
                                    writeseizmo(gdata(good),'path',fdir);
                                    unsatisfied=false;
                                    j=j+1;
                                case 2 % adjust good
                                    % Changed this to display windowed data
                                    % to allow deleting of previously
                                    % windowed data - AAdams
                                     npanels=ceil(nrecs/25)
                                     for g=1:npanels
                                        nst=(g-1)*25+1;
                                        if g==npanels
                                            ntot=nrecs-(g-1)*25;
                                            nlast=nrecs;
                                        else
                                            ntot=25;
                                            nlast=g*25;
                                        end
                                       [badb,badb,tmpax]=selectrecords(fdata(nst:nlast),'delete',...
                                            'p1',~good(nst:nlast),'xlim',xlimits,'align',true,...
                                            'xlabel',' ','ylabel',' ',...
                                            'normstyle',p.normstyle);
                                        if(ishandle(tmpax(1)))
                                            close(get(tmpax(1),'parent'));
                                        end
                                        if g==1
                                            bad=badb;
                                        else
                                            bad=vertcat(bad,badb);
                                        end
                                     end
                                     good=~bad;
                                    firsttime=2;
                                    deleting=true;
                                case 3 % adjust win
                                    [tmp,tmp,tmpax]=userwindow(fdata,win,true,@deal,...
                                        'xlim',xlimits,'normstyle',p.normstyle);
                                    if(ishandle(tmpax))
                                        close(get(tmpax,'parent'));
                                    end
                                    if(~isempty(tmp.limits))
                                        win=tmp.limits;
                                        xlimits=win+[-1 1]*diff(win);
                                        deleting=false;
                                        good=true(nrecs,1)
                                    end
                                    firsttime=1;
                                case 4 % adjust mvin
                                    mvchoice=menu(...
                                        ['ADJUST MOVEOUT WITHIN ARRAY?  (CURRENTLY '...
                                        num2str(mvin) 'km/s)'],...
                                        ['+50% = ' num2str(mvin*1.50) 'km/s)'],...
                                        ['+25% = ' num2str(mvin*1.25) 'km/s)'],...
                                        ['+10% = ' num2str(mvin*1.10) 'km/s)'],...
                                        [' +5% = ' num2str(mvin*1.05) 'km/s)'],...
                                        [' +1% = ' num2str(mvin*1.01) 'km/s)'],...
                                        [' -1% = ' num2str(mvin*0.99) 'km/s)'],...
                                        [' -5% = ' num2str(mvin*0.95) 'km/s)'],...
                                        ['-10% = ' num2str(mvin*0.90) 'km/s)'],...
                                        ['-25% = ' num2str(mvin*0.75) 'km/s)'],...
                                        ['-50% = ' num2str(mvin*0.50) 'km/s)'],...
                                        'KEEP AS IS!');
                                    adj=[1.5 1.25 1.1 1.05 1.01 .99 .95 .9 .75 .5 1];
                                    mvin=mvin*adj(mvchoice);
                                    deleting=false;
                                    good=true(nrecs,1);
                                    firsttime=1;
                                case 5 % skip one
                                    unsatisfied=false;
                                    j=j+1;
                                case 6 % skip all
                                    unsatisfied=false;
                                    skipall=true;
                                case 7 % jump to filter
                                    % present gui to user to make a choice
                                    n=cellstr(num2str((1:nfilt)','%02d'));
                                    p1=cellstr(num2str(1./p.bank(:,3),'%5.1f'));
                                    p2=cellstr(num2str(1./p.bank(:,2),'%5.1f'));
                                    cur={''}; cur=cur(ones(nfilt,1),1);
                                    cur{j}='(current)';
                                    newj=listdlg('liststring',...
                                        strcat({'BAND '},n,{':  '},...
                                            p1,'-',p2,{'s '},cur),...
                                        'selectionmode','single',...
                                        'promptstring','Jump To Filter:',...
                                        'initialvalue',j,...
                                        'listsize',[240 400]);
                                    if(isempty(newj) || newj==j)
                                        % like nothing happened
                                    else
                                        unsatisfied=false;
                                        j=newj;
                                    end                                    
                                    
                                    
                                    
                            end
                        end

                        % close window
                        if(ishandle(fh)); close(fh); end
                    end
                    
                        
                    % check skip (skip rest of event)
                 else
                     j=j+1;
                end
                if(skipall); break; end
                clear('data');
                clear('good'); 
                clear('nrecs');
                clear('fdata');
                clear('fwdata');
                clear('procdata');
                clear('seismo');
            
    end
        
end        
end



function p=parse_freqwindow_param(varargin)
%PARSE_FREQWINDOW_PARAM    Parse & default freqwindow parameters

% defaults
%      'bank'       - filter bank (FILTER_BANK format)
%      'snrcut'     - SNR cutoff (3)
%      'snrwin'     - SNR noise window relative width (0.5)
%      'snrmethod'  - SNR method ('peak2rms')
%      'taperwidth' - Taper width (0.2)
%      'padwin'     - Zero-Padding limits ([-2000 7000])
%      'model'      - surface wave travel time model ('CUB2' - see TTSURF)
%      'wave'       - surface wave type ('Rayleigh')
%      'speed'      - surface wave speed type ('group')
%      'normstyle'  - record normalization style in plots ('single')
p.taperwidth=.2;        % taper 20% on each edge of windowed signal
p.snrcut=3;             % require SNR>=3 on BOTH sides
p.pad=[-2000 7000];     % final zero padding of records
p.snrwin=.5;            % noise windows (both) are 50% of signal window
p.snrmethod='peak2rms'; % this is the typical method
p.model=[];             % use ttsurf default (CUB2)
p.wave=[];              % use ttsurf default (Rayleigh)
p.speed=[];             % use ttsurf default (group)
p.normstyle='single';   % record normalization style in plots ('single')
p.bank=flipud(filter_bank([0.0055 0.055],'variable',0.2,0.1));

% quick quit
if(~nargin); return; end

% require parameter options are strings
if(~iscellstr(varargin(1:2:end)))
    error('seizmo:gooduglycheck:badInput',...
        'OPTION must be a string!');
end

% check/assign parameters
for i=1:2:nargin
    if(isempty(varargin{i+1})); continue; end
    switch lower(varargin{i})
        case {'taperwidth' 'taper' 'taperwin' 'tapwin'}
            if(~isreal(varargin{i+1}) || numel(varargin{i+1})>2 ...
                    || any(varargin{i+1}<0 | varargin{i+1}>.5))
                error('seizmo:qcfreqwindow:badInput',...
                    'TAPERWIDTH must be valid for the TAPER function!');
            end
            p.taperwidth=varargin{i+1};
        case {'snrcut' 'snrcutoff'}
            if(~isreal(varargin{i+1}) || numel(varargin{i+1})~=1 ...
                    || varargin{i+1}<0)
                error('seizmo:qcfreqwindow:badInput',...
                    'SNRCUT must be a real-valued scalar!');
            end
            p.snrcut=varargin{i+1};
        case {'padwin'}
            if(numel(varargin{i+1})~=2 || ~isreal(varargin{i+1}) ...
                    || varargin{i+1}(1)>=varargin{i+1}(2))
                error('seizmo:useralign_quiet:badInput',...
                    'PADWIN must be 1x2 vector as [START END]!');
            end
            p.pad=varargin{i+1};
        case {'snrwin'}
            if(~isreal(varargin{i+1}) || numel(varargin{i+1})~=1 ...
                    || any(varargin{i+1}<0 | varargin{i+1}>1))
                error('seizmo:qcfreqwindow:badInput',...
                    'SNRWIN must be real-valued scalar from 0 to 1!');
            end
            p.snrwin=varargin{i+1};
        case {'snrmethod'}
            if(~isstringb(varargin{i+1}))
                error('seizmo:qcfreqwindow:badInput',...
                    'SNRMETHOD must be a string!');
            end
            p.snrmethod=varargin{i+1};
        case {'model'}
            if(~isstringb(varargin{i+1}))
                error('seizmo:qcfreqwindow:badInput',...
                    'MODEL must be a string!');
            end
            p.model=varargin{i+1};
        case {'wave'}
            validwave={'rayleigh' 'love'};
            if(~isstringb(varargin{i+1}) ...
                    || ~any(strcmpi(varargin{i+1},validwave)))
                error('seizmo:qcfreqwindow:badInput',...
                    'WAVE must be a string!');
            end
            p.wave=varargin{i+1};
        case {'speed'}
            validspeed={'group' 'phase'};
            if(~isstringb(varargin{i+1}) ...
                    || ~any(strcmpi(varargin{i+1},validspeed)))
                error('seizmo:qcfreqwindow:badInput',...
                    'SPEED must be a string!');
            end
            p.speed=varargin{i+1};
        case {'bank'}
            if(size(varargin{i+1},2)~=3 || any(varargin{i+1}(:)<=0 ...
                    | isnan(varargin{i+1}(:)) ...
                    | isinf(varargin{i+1}(:))) ...
                    || any(varargin{i+1}(:,1)<=varargin{i+1}(:,2) ...
                    | varargin{i+1}(:,3)<=varargin{i+1}(:,1)))
                error('seizmo:qcfreqwindow:badInput',...
                    'BANK must be in the format from FILTER_BANK!');
            end
            p.bank=varargin{i+1};
        case 'normstyle'
            if(~isstringb(varargin{i+1}) || ~any(strcmpi(varargin{i+1},...
                    {'single' 'individually' 'individual' 'one' ...
        	        'separately' 'group' 'together' 'all'})))
        	    error('seizmo:qcfreqwindow:badInput',...
                    'NORMSTYLE must be ''SINGLE'' or ''GROUP''!');
            end
            p.normstyle=varargin{i+1};
        otherwise
            error('seizmo:qcfreqwindow:unknownOption',...
                'Unknown Option: %s',varargin{i});
    end

end
end
