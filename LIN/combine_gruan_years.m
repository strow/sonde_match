% Combine several years of Gruan data at a single site.



loc='LIN'; 
years=[ 2006 2008 2009 2010 2011 2012 2013 2014]; 


addpath /asl/packages/time
addpath /asl/matlib_new/aslutil
addpath /asl/matlib_new/h4tools
addpath /home/tangborn/gruan_proc/airsind/
addpath /asl/matlab2012/airs/readers/

[junk nyears]=size(years); 
nobs_tot=0; 

pcrtm_p = load('/home/sergio/PCRTM_XIANGLEI/PCRTM_V2.1/code_changed/InputDir/Atm_prof/lev-101_nMol-6/pbnd.dat');
pcrtm = load('/home/sergio/PCRTM_XIANGLEI/PCRTM_V2.1/code_changed/InputDir/par_constant.dat');

co2ppm=pcrtm(:,1); 


for iyear=1:nyears
   year=years(iyear); 
   rfile = [loc ,'_AIRS_',num2str(year),'.rtp'];
   [h_year ha_year p_year pa_year] = rtpread(rfile); 
   [junk nobs]=size(p_year.rlat);
   nobs_tot=nobs_tot+nobs;  

   fnames = fieldnames(p_year);
   nnames = length(fnames);
   if iyear == 1
      for j=1:nnames
        p_all.(fnames{j}) = p_year.(fnames{j});
      end
   end
   if iyear > 1
      for j=1:nnames
         p_all.(fnames{j}) = [p_all.(fnames{j}) p_year.(fnames{j})];
      end
   end

   p_all.upwell = ones(size(p_all.rlon));

   for iprof=nobs_tot-nobs+1:nobs_tot
      p_all.gas_2(:,iprof)=co2ppm(:); 
   end 
end % iyear 

   wfile = [loc ,'_AIRS_all.rtp'];
   rtpwrite(wfile,h_year,{},p_all,{});
