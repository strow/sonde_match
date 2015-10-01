% Code to read in gruan data and write out as rtp file that can go into klayers
% This version does not run klayers.
% A. Tangborn March 2015

addpath /asl/matlib_new/aslutil
addpath /asl/matlib_new/h4tools
addpath /asl/matlib_new/rtptools 
addpath /asl/packages/time
addpath /home/strow/Git/rtp_prod2/grib
addpath /home/strow/Git/rtp_prod2/util
addpath /home/strow/Git/rtp_prod2/emis
addpath /home/strow/Matlab/Math

loc='LIN'; 
gruan_year_path=['/asl/data/sondes/Gruan/' loc]; 
% Don't yet know how to make multiple years work.
years=dir(fullfile(gruan_year_path,'20*')); 
nyears=length(years); 
yyyy=9;  
year='2013'; 
nfiles_total=0; 
for iyear=yyyy:yyyy  % set up the initial prof structure for all years
    gruanpath=['/asl/data/sondes/Gruan/' loc,'/',years(iyear).name];
    gfiles=dir(fullfile(gruanpath,'*.nc'));
    nfiles=length(gfiles);
    nfiles_total_old=nfiles_total; 
    nfiles_total=nfiles_total+nfiles; 
end 
% Loop through each year of gruan data
%fid=fopen('gruan_2011.dat');
prof.plevs = NaN(101,nfiles_total);
prof.ptemp = NaN(101,nfiles_total);
prof.gas_1 = NaN(101,nfiles_total);
prof2.u_rh = NaN(101,nfiles_total); 
prof2.u_temp = NaN(101,nfiles_total); 
prof2.plevs = NaN(101,nfiles_total); 
nfiles=0; 
nfiles_old=0; 
for iyear=yyyy:yyyy  
    nfiles_old=nfiles_old+nfiles; 
    gruanpath=['/asl/data/sondes/Gruan/' loc,'/',years(iyear).name]; 
    gfiles=dir(fullfile(gruanpath,'*.nc')); 
    nfiles=length(gfiles); 
    
    load airslevels.dat
% Standard level set is 101, AIRS levels
% Later re-compile klayers to take more levels, then make plevs
% those new levels, interpolated from airslevels.
plevs = airslevels;


for i=1:nfiles; 
   i_total=i+nfiles_old; 
   file_temp=gfiles(i).name
   fname=fullfile(gruanpath,file_temp)
%   mtime = datetime([fname(58:65) fname(67:68)],'InputFormat','yyyyMMddHH')
   mtime = datetime([file_temp(26:33) file_temp(35:38)],'InputFormat','yyyyMMddHHmm');
   ptime = dtime2tai(mtime); 

   % Read GRUAN data
   s = read_netcdf_lls(fname); 
   % Assign rtp
%   idx=diff([99999.99;s.press]) ==0.0;   % Find duplicate pressures 
%   prof.nlevs(i_total) = NaN; 
   if max(diff(s.press)) < 0 
   for ilev=1:size(s.rh)
      if s.rh(i)==0 
        s.rh(i)=NaN
      end  
   end 
% From Larrabee's TWP code 
% jj, jj2 and jj3 appear to be identical.
    [jj x] = remove_nan(s.press);
    [jj2 x2] = remove_nan(s.temp);
    [jj3 x3] = remove_nan(s.rh);
    if ((length(jj) == length(jj2)) & (length(jj2) == length(jj3) ))
       s.press = s.press(jj);
       s.temp = s.temp(jj2);
       s.rh = s.rh(jj3);
% Add in uncertainties to the structure
       s.u_temp = s.u_temp(jj2); 
       s.u_rh = s.u_rh(jj3);

       
    else
       disp('bad profiles')
    end

   tmp_t  = interp1(s.press,s.temp,plevs,'pchip',-999);
   tmp_rh = interp1(s.press,s.rh,plevs,'pchip',-999);
   tmp_u_t = interp1(s.press,s.u_temp,plevs,'pchip',-999);
   tmp_u_rh = interp1(s.press,s.u_rh,plevs,'pchip',-999);
% Also interpolate uncertainties to AIRS heights:

   k = find( tmp_t ~= -999 & tmp_rh ~= -999 );
   kn = length(k);
   istart = k(1); istop = k(end);
   prof.plevs(1:kn,i_total) = plevs(k);
   prof.nlevs(i_total) = length(k);
   prof.plevs(1:kn,i_total) = plevs(istart:istop);
   prof.ptemp(1:kn,i_total) = tmp_t(k);
   prof.gas_1(1:kn,i_total) = tmp_rh(k);

   prof2.plevs(1:kn,i_total) = plevs(k);
   prof2.nlevs(i_total) = length(k);
   prof2.plevs(1:kn,i_total) = plevs(istart:istop);
   prof2.ptemp(1:kn,i_total) = tmp_t(k);
   prof2.gas_1(1:kn,i_total) = tmp_rh(k);
   prof2.u_temp(1:kn,i_total) = tmp_u_t(k);
   prof2.u_rh(1:kn,i_total) = tmp_u_rh(k)./tmp_rh(k);
   end 
   prof.plat(i_total) = nanmean(s.lat);
   prof.plon(i_total) = nanmean(s.lon);
   prof.ptime(i_total) = ptime;

   prof2.plat(i_total) = nanmean(s.lat);
   prof2.plon(i_total) = nanmean(s.lon);
   prof2.ptime(i_total) = ptime;
end
%   We need a second rtp structure that doesn't pass through klayers:
%   This also includes the uncertainties.

%   tmp_u_t = interp1(s.press,s.u_temp,plevs,'pchip',-999);
%   tmp_u_rh = interp1(s.press,s.u_rh,plevs,'pchip',-999);
% Use the same k here, since we want it to be identical to the structure above
%   istart = k(1); istop = k(end);
%   prof2.plevs(1:kn,i_total) = plevs(k);
%   prof2.nlevs(i_total) = length(k);
%   prof2.plevs(1:kn,i_total) = plevs(istart:istop);
%   prof2.ptemp(1:kn,i_total) = tmp_t(k);
%   prof2.gas_1(1:kn,i_total) = tmp_rh(k);
%   end
%   prof2.plat(i_total) = nanmean(s.lat);
%   prof2.plon(i_total) = nanmean(s.lon);
%   prof2.rtime(i_total) = rtime;
%   prof2.u_temp(i_total) = tmp_u_t(k); 
%   prof2.u_rh(i_total) = tmp_u_rh(k); 

end  % for ifiles=
% Rtp headers
head.pfields = 1; 
head.ngas = 1; 
head.nchan = 0; 
head.gasid = 1; 
head.gunit = 41; 
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
prof_era.ptime = prof.ptime;

% All this is moved to airs_gruan_matchup.m 
   
%[prof_era head_era]=fill_era(prof_era, head_era);  

% Need a surface pressure or klayers will barf.  Use ERA, can't find one in sonde data
%prof.spres = prof_era.spres;
%prof.stemp = prof_era.stemp;



%junk=find(prof.nlevs > 0);
%[head_new prof_new]=subset_rtp(head,prof,[],[],junk);
%[head_era_new prof_era_new]=subset_rtp(head_era,prof_era,[],[],junk); 
%good_wv=find(min(prof_new.gas_1)>0);
%[head_wv prof_wv]=subset_rtp(head_new,prof_new,[],[],good_wv); 
%[head_era_wv prof_era_wv]=subset_rtp(head_era_new, prof_era_new,[],[],good_wv); 
% Subset prof2 so that it only inclues profiles where nlevs>0.
%prof2_sub=rtp_sub_prof(prof2,junk);
%prof2_wv=rtp_sub_prof(prof2_sub,good_wv); 


%  Move everthing to this point to airs_gruan matchup. 

% Write out rtp for sonde prof

fileout_prof = [loc,'_',year,'.rtp']; 
rtpwrite(fileout_prof,head,{},prof,{});

% Write out the rtp for prof2 (Sonde uncertainties) 

fileout_prof2 = [loc,'_',year,'_uncert.rtp'];
rtpwrite(fileout_prof2,head,{},prof2,{});

% Write out the rtp for ERA. At this point, ERA is filled with NaN mostly.  

fileout_era = [loc,'_ERA_',year,'.rtp']; 
rtpwrite(fileout_era,head_era,{},prof_era,{}); 



