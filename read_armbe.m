% Read in TWP sonde data, create rtp structure, combine with ERA and 
% pass through Klayers.
% A. Tangborn April, 2015

addpath /asl/matlib_new/aslutil
addpath /asl/matlib_new/h4tools
addpath /asl/packages/time
addpath ~/Git/rtp_prod2/grib
addpath ~/Git/rtp_prod2/util
addpath ~/Git/rtp_prod2/emis
addpath ~/Matlab/Math

loc = 'twp';

% fid=fopen('twp.dat');
% twp_files=textscan(fid,'%s');
% [nfiles junk]=size(twp_files{1});
%nfiles=5; 
armpath=['/Users/strow/Work/Sondes/Armbe/' loc];
afiles = dir(fullfile(armpath,'*.cdf'));
nfiles = length(afiles);

load airslevels.dat
% Standard level set is 101, AIRS levels
% Later re-compile klayers to take more levels, then make plevs
% those new levels, interpolated from airslevels.
plevs = airslevels;

prof.plevs = NaN(101,nfiles);
prof.ptemp = NaN(101,nfiles);
prof.gas_1 = NaN(101,nfiles);
prof.wspeed = NaN(101,nfiles);
prof.alts = NaN(101,nfiles);

%Loop through twp sonde files 
for i=1:nfiles

    file_temp        = afiles(i).name;
    fname            = fullfile(armpath,file_temp);
    mtime            = datetime([file_temp(11:18) file_temp(20:23)],'InputFormat','yyyyMMddHHmm');
    rtime            = dtime2tai(mtime);
    lat              = ncread(fname,'latSite');
    lon              = ncread(fname,'lonSite');
    otime            = ncread(fname,'overpassTime'); 
    altitude         = ncread(fname,'altitude'); 
    timesonde        = ncread(fname,'timeSonde1'); 
    presssonde       = ncread(fname,'pressureSonde1'); 
    temperaturesonde = ncread(fname,'temperatureSonde1'); 
    rhsonde          = ncread(fname,'mwr_rhSonde1'); 
    wvsonde          = ncread(fname,'mwr_wvSonde1'); 
    latsonde         = ncread(fname,'latSonde1'); 
    lonsonde         = ncread(fname,'lonSonde1'); 
    wspdsonde        = ncread(fname,'wspdSonde1'); 
    wdirsonde        = ncread(fname,'wdirSonde1'); 

   % Assign rtp
% sonde vars can contain NaNs, *assume* only at end!!
    [jj x] = remove_nan(presssonde);
    [jj2 x2] = remove_nan(temperaturesonde);
    [jj3 x3] = remove_nan(rhsonde);
    if ((length(jj) == length(jj2)) & (length(jj2) == length(jj3) ))
       presssonde = presssonde(jj);
       temperaturesonde = temperaturesonde(jj2);
       rhsonde = rhsonde(jj3);
    else
       disp('bad profiles')
    end

    tmp_t  = interp1(presssonde,temperaturesonde,plevs,'pchip',-999);
    tmp_rh = interp1(presssonde,rhsonde,plevs,'pchip',-999);
    tmp_wspeed = interp1(presssonde,wspdsonde,plevs,'pchip',-999);
    tmp_alts = interp1(presssonde,altitude,plevs,'pchip',-999);
    
    k = find( tmp_t ~= -999 & tmp_rh ~= -999 );
    kn = length(k);
    
    istart = k(1); istop = k(end);
    
    prof.plevs(1:kn,i) = plevs(k);
    prof.nlevs(i)      = length(k);
    prof.plevs(1:kn,i) = plevs(istart:istop);
    prof.ptemp(1:kn,i) = tmp_t(k);
    prof.gas_1(1:kn,i) = tmp_rh(k);
    prof.wspeed(1:kn,i) = tmp_wspeed(k);
    prof.alts(1:kn,i) = tmp_alts(k);
    prof.plat(i)       = nanmean(latsonde);
    prof.plon(i)       = nanmean(lonsonde);
    prof.rtime(i)      = rtime;
end 


% Rtp headers
head.pfields = 1;
head.ngas = 1;
head.nchan = 0;
head.gasid = 1;
head.gunit = 40;
head.ptype = 0;
head.glist = 1;
head.pmin = min(prof.plevs(:));
head.pmax = max(prof.plevs(:));

% Get ERA matching data
head_era.pfields = 1;
head_era.ngas = 2;
head_era.nchan = 0;

prof_era.plat = prof.plat;
prof_era.plon = prof.plon;
prof_era.rlat = prof.plat;
prof_era.rlon = prof.plon;
prof_era.rtime = prof.rtime;

[prof_era head_era]=fill_era(prof_era, head_era);
%[prof_era head_era]=fill_ecmwf(prof_era, head_era);

% Need a surface pressure or klayers will barf.  Use ERA, can't find one in sonde data
prof.spres = prof_era.spres;
prof.stemp = prof_era.stemp;


klayers = '/asl/packages/klayersV205/BinV201/klayers_airs_wetwater';
% Call Klayers for ERA
% 
fip = 'era_prof.ip.rtp';
fop = ['era_' loc '.rtp'];
rtpwrite(fip,head_era,{},prof_era,{});
klayerser = ['!' klayers ' fin=' fip ' fout=' fop ' > /dev/null'];
eval(klayerser)

% Call Klayers for arm data 
fip_twp = [loc '_prof.ip.rtp'];
fop_twp = [loc '.rtp'];

rtpwrite(fip_twp,head,{},prof,{});

klayerser_twp =['!' klayers ' fin=' fip_twp ' fout=' fop_twp ' > /dev/null'];
eval(klayerser_twp)


