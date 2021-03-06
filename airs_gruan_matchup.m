function [] = airs_gruan_matchup(loc);

gruan = false;
inst  = 'AIRIBRAD';

addpath /asl/packages/time
addpath /asl/matlib/aslutil
addpath /asl/matlib/h4tools
addpath /asl/matlib/rtptools
addpath /asl/packages/l1indexing/airs
addpath /asl/matlab2012/airs/readers/
addpath /asl/packages/rtp_prod2/emis
addpath /asl/packages/rtp_prod2/util 
addpath ~/Git/rtp_prod2/grib
addpath ~/Matlab/Math

load('/home/strow/Matlab/Airs/airs_f');
freq = f;

rfile = [loc '/' loc '.rtp'];

% Sonde profiles "_s"
[head_s, hattr_s, prof_s, pattr_s] = rtpread(rfile);
nprof = length(prof_s.plat);

% Read in uncertainty profile
if gruan
   rfile2=[loc,'_',year,'_uncert.rtp'];
   [head_unc, hattr_unc, prof_unc, pattr_unc] = rtpread(rfile2);
end

% Find matchups and fill prof_era with AIRS data, etc
k = 1;
for i = 1:nprof
   current_time=datestr(tai2dnum(prof_s.ptime(i)))
   [prof_s.plat(i), prof_s.plon(i)];

   dt = 60 * 60 * 2;  % time window
   t1 = tai2airs(prof_s.ptime(i)) - dt;
   t2 = tai2airs(prof_s.ptime(i)) + dt;

   opt = struct;
   opt.lat = prof_s.plat(i);
   opt.lon = prof_s.plon(i);
   opt.rad = 12;    % lat/lon radius

% Find Closest obs in time and space (If any).
   flist = find_gfile(inst, t1, t2, opt)
   if size(flist) > 0
      fn=flist{1};   % flist{1} is the first AIRS data file in flist. 
      [eq_x_tai, f, gdata, attr] = xreadl1b_all(fn);

% Find closest Granule(s) 
      [junk nobs]=size(gdata.zobs);
      gran_dist=sqrt( (prof_s.plat(i) - gdata.rlat).^2 + (prof_s.plon(i) - gdata.rlon).^2);
      [distg dist_index]=sort(gran_dist);

% Include in RTP structure. dist_index(1) is closest observation
      prof_era.robs1(:,k)=gdata.robs1(:,dist_index(1));
      prof_era.satzen(k)=gdata.satzen(dist_index(1));
      prof_era.atrack(k)=gdata.atrack(dist_index(1));
      prof_era.xtrack(k)=gdata.xtrack(dist_index(1));
      prof_era.zobs(k)=gdata.zobs(dist_index(1));
      prof_era.calflag(:,k)=gdata.calflag(:,dist_index(1));
      prof_era.scanang(k)=gdata.scanang(dist_index(1));
      prof_era.satazi(k)=gdata.satazi(dist_index(1));
      prof_era.solzen(k)=gdata.solzen(dist_index(1));
      prof_era.solazi(k)=gdata.solazi(dist_index(1));
      prof_era.salti(k)=gdata.salti(dist_index(1));
      prof_era.landfrac(k)=gdata.landfrac(dist_index(1));
      prof_era.robsqual(k)=gdata.robsqual(dist_index(1));
      prof_era.rlat(k)=double(gdata.rlat(dist_index(1)));
      prof_era.rlon(k)=double(gdata.rlon(dist_index(1)));
      prof_era.findex(k) = gdata.findex(dist_index(1));
      prof_era.rtime(k) = gdata.rtime(dist_index(1));
      prof_era.upwell(k) = 1;
      prof_era.iudef(4,k) = gdata.iudef(4,dist_index(1));

      iuse(k) = i;
      k = k + 1;

   end  % end if size(flist) > 0  
end % for i=1:nprof

% Get ERA profiles
prof_era.ptime = prof_s.ptime(iuse);
[prof_era head_era]=fill_era(prof_era, head_s);  

% Put everything in ERA into sonde rtp, then re-load sonde fields
pst = prof_s;   % temporary holder for sonde specific data
prof_s = prof_era;
% Now put sonde data back into prof_s
prof_s.plevs = pst.plevs(:,iuse);
prof_s.ptemp = pst.ptemp(:,iuse);
prof_s.gas_1 = pst.gas_1(:,iuse);
prof_s.nlevs = pst.nlevs(iuse);
prof_s.plat  = pst.plat(iuse);
prof_s.plon  = pst.plon(iuse);
prof_s.ptime = pst.ptime(iuse);

clear pst

% Subset uncert file for iuse
if gruan
   prof_unc = rtp_sub_prof(prof_unc,iuse);
end

% Remove bad profiles
k = find(prof_s.nlevs > 0);
if k < length(prof_s.nlevs)
   [head_s,prof_s] = subset_rtp(head_s,prof_s,[],[],k);
   [head_era,prof_era] = subset_rtp(head_era,prof_era,[],[],k);
   [head2,prof2] = subset_rtp(head2,prof2,[],[],k);
end

if min(prof_s.gas_1(:)) < 0
   disp('negative water');
end

head_s.ichan = (1:2378)';
head_s.vchan = f(:);
head_s.nchan = 2378;
head_s.pfields = 5;

head_era.pfields = 5;
head_era.ichan = (1:2378)';
head_era.vchan = f(:);
head_era.nchan = 2378;

% Must set first before calling rtp_add_emis
pattr_s   = set_attr('profiles','robs1','AIRSL1b');
pattr_era = set_attr('profiles','robs1','AIRSL1b');

[prof_s, pattr_s] = rtp_add_emis(prof_s,pattr_s);
[prof_era, pattr_era] = rtp_add_emis(prof_era,pattr_era);

% Write out RTP File for combined AIRS and Sonde data
outfile=[loc '/' loc,'_AIRS.rtp'];
rtpwrite(outfile,head_s,{},prof_s,{});

% Write out RTP File for combined AIRS and ERA data
outfile_era=[loc '/' loc,'_era_AIRS.rtp']; 
rtpwrite(outfile_era,head_era,{},prof_era,{}); 

% Write out RTP file for sonde uncertainties a the same times/locations
% There is no AIRS data in these files, but they are restricted to AIRS matchups.
if gruan
   outfile2=[loc '/' loc '_AIRS_',year,'_uncert.rtp']; 
   rtpwrite(outfile2,head_unc,{},prof_unc,{});
end

