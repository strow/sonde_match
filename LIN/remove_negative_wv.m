addpath /asl/matlib_new/aslutil
addpath /asl/matlib_new/h4tools
addpath /asl/matlib_new/rtptools
addpath /asl/packages/time
addpath ~/Git/rtp_prod2/grib
addpath ~/Git/rtp_prod2/util
addpath ~/Git/rtp_prod2/emis
addpath ~/Matlab/Math

loc='LIN';

file=[loc,'_AIRS.rtp']; 
file_era=[loc,'_era_AIRS.rtp']; 
file_unc=[loc,'_AIRS_uncert.rtp']; 
[h ha p pa]=rtpread(file); 
[h_era ha_era p_era pa_era]=rtpread(file_era); 
[h_unc ha_unc p_unc pa_unc]=rtpread(file_unc); 

good_wv=find(min(p.gas_1)>0);
[h_wv p_wv]=subset_rtp(h,p,[],[],good_wv); 
[h_era_wv p_era_wv]=subset_rtp(h_era,p_era,[],[],good_wv); 
p_unc_wv = rtp_sub_prof(p_unc,good_wv);

p_wv.co2ppm=co2_vs_time(tai2dtime(p_wv.ptime));


file_out=[loc,'_AIRS_wv.rtp']; 
file_era_out=[loc,'_era_AIRS_wv.rtp']; 
file_unc_out=[loc,'_AIRS_uncert_wv.rtp']

rtpwrite(file_out,h_wv,{},p_wv,{});
rtpwrite(file_era_out,h_era_wv,{},p_era_wv,{}); 
rtpwrite(file_unc_out,h_unc,{},p_unc_wv,{}); 
