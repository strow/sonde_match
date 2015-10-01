% Combine several years of Gruan data at a single site.
% Data is on levels.


loc='LIN'; 
years=[2006 2008 2009 2010 2011 2012 2013 2014 ]; 


addpath /asl/packages/time
addpath /asl/matlib_new/aslutil
addpath /asl/matlib_new/h4tools
addpath /home/tangborn/gruan_proc/airsind/
addpath /asl/matlab2012/airs/readers/

[junk nyears]=size(years); 
nobs_tot=0; 
for iy=1:nyears
   year=years(iy) 
   rfile = [loc ,'_AIRS_',num2str(year),'.rtp'];
   [h_year ha_year p_year pa_year] = rtpread(rfile); 
   [junk nobs]=size(p_year.rlat);
   nobs_tot=nobs_tot+nobs;  
   p_all.plat(nobs_tot-nobs+1:nobs_tot)=p_year.plat(1:nobs);
   p_all.plon(nobs_tot-nobs+1:nobs_tot)=p_year.plon(1:nobs);
   p_all.ptime(nobs_tot-nobs+1:nobs_tot)=p_year.rtime(1:nobs);
   p_all.stemp(nobs_tot-nobs+1:nobs_tot)=p_year.stemp(1:nobs); 
   p_all.salti(nobs_tot-nobs+1:nobs_tot)=p_year.salti(1:nobs);
   p_all.spres(nobs_tot-nobs+1:nobs_tot)=p_year.spres(1:nobs);
   p_all.landfrac(nobs_tot-nobs+1:nobs_tot)=p_year.landfrac(1:nobs);
   p_all.landtype(nobs_tot-nobs+1:nobs_tot)=NaN %p_year.landtype(1:nobs);
   p_all.wspeed(nobs_tot-nobs+1:nobs_tot)=p_year.wspeed(1:nobs);
   p_all.nemis(nobs_tot-nobs+1:nobs_tot)=p_year.nemis(1:nobs);
   p_all.nlevs(nobs_tot-nobs+1:nobs_tot)=p_year.nlevs(1:nobs);
   p_all.plevs(:,nobs_tot-nobs+1:nobs_tot)=p_year.plevs(:,1:nobs);
%   p_all.palts(:,nobs_tot-nobs+1:nobs_tot)=p_year.palts(:,1:nobs);
   p_all.ptemp(:,nobs_tot-nobs+1:nobs_tot)=p_year.ptemp(:,1:nobs);
%   pall.upwell = ones(size(pall.rlon)); 
   p_all.gas_1(:,nobs_tot-nobs+1:nobs_tot)=p_year.gas_1(:,1:nobs);
%   p_all.gas_2(:,nobs_tot-nobs+1:nobs_tot)=p_year.gas_2(:,1:nobs);
%   p_all.gas_3(:,nobs_tot-nobs+1:nobs_tot)=p_year.gas_3(:,1:nobs);
%   p_all.gas_4(:,nobs_tot-nobs+1:nobs_tot)=p_year.gas_4(:,1:nobs);
%   p_all.gas_5(:,nobs_tot-nobs+1:nobs_tot)=p_year.gas_5(:,1:nobs);
%   p_all.gas_6(:,nobs_tot-nobs+1:nobs_tot)=p_year.gas_6(:,1:nobs);
%   p_all.gas_9(:,nobs_tot-nobs+1:nobs_tot)=p_year.gas_9(:,1:nobs);
%   p_all.gas_12(:,nobs_tot-nobs+1:nobs_tot)=p_year.gas_12(:,1:nobs);
%   p_all.gtotal(:,nobs_tot-nobs+1:nobs_tot)=p_year.gtotal(:,1:nobs);
%   p_all.gxover(:,nobs_tot-nobs+1:nobs_tot)=p_year.gxover(:,1:nobs);
%   p_all.txover(:,nobs_tot-nobs+1:nobs_tot)=p_year.txover(:,1:nobs);
%   p_all.co2ppm(nobs_tot-nobs+1:nobs_tot)=p_year.co2ppm(1:nobs);
%   p_all.clrflag(nobs_tot-nobs+1:nobs_tot)=p_year.clrflag(1:nobs);
%   p_all.ctype(nobs_tot-nobs+1:nobs_tot)=p_year.ctype(1:nobs);
%   p_all.cfrac(nobs_tot-nobs+1:nobs_tot)=p_year.cfrac(1:nobs);
%   p_all.cprtop(nobs_tot-nobs+1:nobs_tot)=p_year.cprtop(1:nobs);
%   p_all.cprbot(nobs_tot-nobs+1:nobs_tot)=p_year.cprbot(1:nobs);
%   p_all.cngwat(nobs_tot-nobs+1:nobs_tot)=p_year.cngwat(1:nobs);
%   p_all.cpsize(nobs_tot-nobs+1:nobs_tot)=p_year.cpsize(1:nobs);
%   p_all.cstemp(nobs_tot-nobs+1:nobs_tot)=p_year.cstemp(1:nobs);
%   p_all.ctype2(nobs_tot-nobs+1:nobs_tot)=p_year.ctype(1:nobs);
%   p_all.cfrac2(nobs_tot-nobs+1:nobs_tot)=p_year.cfrac2(1:nobs);
%   p_all.pobs(nobs_tot-nobs+1:nobs_tot)=p_year.pobs(1:nobs);
   p_all.zobs(nobs_tot-nobs+1:nobs_tot)=p_year.zobs(1:nobs);
   p_all.upwell(nobs_tot-nobs+1:nobs_tot)=p_year.upwell(1:nobs);
   p_all.scanang(nobs_tot-nobs+1:nobs_tot)=p_year.scanang(1:nobs);
   p_all.satzen(nobs_tot-nobs+1:nobs_tot)=p_year.satzen(1:nobs);
   p_all.satazi(nobs_tot-nobs+1:nobs_tot)=p_year.satazi(1:nobs);
   p_all.solzen(nobs_tot-nobs+1:nobs_tot)=p_year.solzen(1:nobs);
   p_all.solazi(nobs_tot-nobs+1:nobs_tot)=p_year.solazi(1:nobs);
%   p_all.sundist(nobs_tot-nobs+1:nobs_tot)=p_year.sundist(1:nobs);
%   p_all.glint(nobs_tot-nobs+1:nobs_tot)=p_year.glint(1:nobs);
   p_all.rlat(nobs_tot-nobs+1:nobs_tot)=p_year.rlat(1:nobs);
   p_all.rlon(nobs_tot-nobs+1:nobs_tot)=p_year.rlon(1:nobs);
   p_all.rtime(nobs_tot-nobs+1:nobs_tot)=p_year.rtime(1:nobs);
   p_all.robs1(:,nobs_tot-nobs+1:nobs_tot)=p_year.robs1(:,1:nobs); 
   p_all.findex(nobs_tot-nobs+1:nobs_tot)=p_year.findex(1:nobs);
   p_all.atrack(nobs_tot-nobs+1:nobs_tot)=p_year.atrack(1:nobs);
   p_all.xtrack(nobs_tot-nobs+1:nobs_tot)=p_year.xtrack(1:nobs); 
%   p_all.ifov(nobs_tot-nobs+1:nobs_tot)=p_year.ifov(1:nobs);
   p_all.robsqual(nobs_tot-nobs+1:nobs_tot)=p_year.robsqual(1:nobs);
%   p_all.freqcal(nobs_tot-nobs+1:nobs_tot)=p_year.freqcal(1:nobs);
%   p_all.pnote(:,nobs_tot-nobs+1:nobs_tot)=p_year.pnote(:,1:nobs);
%   p_all.udef(:,nobs_tot-nobs+1:nobs_tot)=p_year.udef(:,1:nobs);
   p_all.iudef(:,nobs_tot-nobs+1:nobs_tot)=p_year.iudef(:,1:nobs);
%   p_all.itype(nobs_tot-nobs+1:nobs_tot)=p_year.itype(1:nobs);
   p_all.robs1(:,nobs_tot-nobs+1:nobs_tot)=p_year.robs1(:,1:nobs);
   p_all.calflag(:,nobs_tot-nobs+1:nobs_tot)=p_year.calflag(:,1:nobs);
%   p_all.cloud_flag(nobs_tot-nobs+1:nobs_tot)=p_year.cloud_flag(1:nobs);
   p_all.efreq(:,nobs_tot-nobs+1:nobs_tot)=p_year.efreq(:,1:nobs);
   p_all.emis(:,nobs_tot-nobs+1:nobs_tot)=p_year.emis(:,1:nobs);
   p_all.nrho(nobs_tot-nobs+1:nobs_tot)=p_year.nrho(1:nobs);
   p_all.rho(:,nobs_tot-nobs+1:nobs_tot)=p_year.rho(1:nobs);
end % iy

%   pall.upwell = ones(size(pall.rlon));

   wfile = [loc,'/',loc ,'_AIRS.rtp'];
   rtpwrite(wfile,h_year,{},p_all,{});
